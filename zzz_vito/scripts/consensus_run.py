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
COIN   = [2, 4, 6, 8] # 2, 4, 6, 8
CAPK   = [0, 1, 2, 3, 4, 9] # 0, 1, 2, 3, 4, 9
# SPEC
P      = [1, 2]
# all processes finish
#  1) P>=1 [ F "finished" ]
# all processes finish with coins all equal (P>=1 never works)
#  2) Pmax=? [ F "finished"&"agree" ]

REPORTS_DIR = '../reports'
REPORT_FILE = os.path.join(REPORTS_DIR, 'report_consensus.txt')
STRATEGIES_DIR = '../strategies/consensus'

def run_all():
  if not os.path.exists(REPORTS_DIR):
    os.makedirs(REPORTS_DIR)
  if not os.path.exists(STRATEGIES_DIR):
    os.makedirs(STRATEGIES_DIR)


  f = open(REPORT_FILE,'w')
  for ci in COIN:
    for capki in CAPK:
      for pi in P:
        if TIMED_OUT and pi > 1:
          # timed out during lower p
          continue
        if ci >= 8 or (ci >= 6 and capki >= 4):
          # not finished within 10 min
          continue

        str_name = ('coin%d_K%d__p%s' %
                    (ci, capki, pi))
        str_full_path = os.path.join(STRATEGIES_DIR,
                                     ('%s.prism' % str_name))
        print(str_name)

        command_parts = ['../../prism/bin/prism -javamaxmem 4g -cuddmaxmem 2g',
                         '-noprob0 -noprob1',
                         '../models/consensus/coin%d.nm' % ci,
                         '../models/consensus/coin.pctl',
                         '-const K=%d' % (capki),
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

