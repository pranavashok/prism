#!/usr/bin/env python

import os
import subprocess, shlex, signal
from threading import Timer

# Timed-out flag
TIMED_OUT = False
# Timeout in seconds (10 minutes)
TIMEOUT = 10*60


# Kills the process p if a timeout occurred - sets the flag TIMED_OUT
def kill_proc(p):
  TIMED_OUT = True
  os.killpg(os.getpgid(p.pid), signal.SIGTERM)
  print('killed')


# Runs a command and sets a timer for TIMEOUT
def run(cmd):
  TIMED_OUT = False
  p = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.PIPE, preexec_fn=os.setsid)
  timer = Timer(TIMEOUT, kill_proc, [p])
  stdout, stderr, exit_code = '', '', None
  try:
    timer.start()
    stdout, stderr = p.communicate()
    #exit_code = p.wait()
  finally:
    timer.cancel()
  return stdout, stderr, exit_code


# Parse 'bytes' output from stdout after running a command
def parse_output(output):
  parsed = []
  if TIMED_OUT:
    return ['Timed out']
  try:
    parts = output.split(b'\n')
    for pp in parts:
      parsed.append(pp.decode('utf-8'))
  except:
    parsed.append('Failed to parse the output')
  return parsed

######

# MODEL
PROCESSES = [2, 3, 4] # 2, 3, 4
BACKOFF   = [2, 4, 6] # 2, 4, 6
# SPEC
K         = [1, 2, 3, 4, 5, 6] # 1, 2, 3, 4, 5, 6
P         = [1, 2, 3, 4, 5, 6]
# all sent successfully before a collision with max backoff
#  1) P>=1 [ !"collision_max_backoff" U "all_delivered" ]
#  2) Pmax=? [ !"collision_max_backoff" U "all_delivered" ]
# message of some station eventually delivered before k backoffs
#  3) P>=1 [ F min_backoff_after_success<=k ]
#  4) Pmax=? [ F min_backoff_after_success<=k ]
# some station suffers at least k collisions
#  5) P<=0 [ F max_collisions>=k ]
#  6) Pmin=? [ F max_collisions>=k ]

REPORTS_DIR = '../reports'
REPORT_FILE = os.path.join(REPORTS_DIR, 'report_csma.txt')
STRATEGIES_DIR = '../strategies/csma'

def run_all():
  if not os.path.exists(REPORTS_DIR):
    os.makedirs(REPORTS_DIR)
  if not os.path.exists(STRATEGIES_DIR):
    os.makedirs(STRATEGIES_DIR)


  f = open(REPORT_FILE,'w')
  for pri in PROCESSES:
    for bai in BACKOFF:
      for pi in P:
        for ki in K:
          if pi <= 2 and ki > 1:
            # 1)2) do not depend on k
            continue
          if TIMED_OUT and (pi > 1 or ki > 1):
            # timed out during lower p / k
            continue
          if (pri >= 3 and bai >= 6) or (pri >= 4 and bai >= 4):
            # model was not constructed within 10 min
            continue

          str_name = ('csma%d_%d__p%s_k%d' %
                      (pri, bai, pi, ki))
          str_full_path = os.path.join(STRATEGIES_DIR,
                                       ('%s.prism' % str_name))
          print(str_name)

          command_parts = ['../../prism/bin/prism -javamaxmem 4g -cuddmaxmem 2g',
                           '-noprob0 -noprob1',
                           '../models/csma/csma%d_%d.nm' % (pri, bai),
                           '../models/csma/csma.pctl',
                           '-const k=%d' % ki,
                           '-prop %d' % pi,
                           '-explicit', # -politer
                           '-exportstrat %s:type=actions' % str_full_path]
          command = ' '.join(command_parts)
          stdout, stderr, exit_code = run(command)
          parsed_output = parse_output(stdout)

          s = open(str_full_path,'a')
          f.write('\n\n=========\n%s\n=========\n\n' % str_name)
          s.write('\n\n=========\n%s\n=========\n\n' % str_name)
          for line in parsed_output:
            f.write('%s\n' % line)
            s.write('%s\n' % line)
          s.close()

  f.close()



run_all()


# http://www.prismmodelchecker.org/manual/FrequentlyAskedQuestions/MemoryProblems

# http://www.prismmodelchecker.org/manual/ConfiguringPRISM/OtherOptions
# Precomputation: -nopre -noprob0 -noprob1

# http://www.prismmodelchecker.org/prismpp/
# Preprocessor to create benchmarks

