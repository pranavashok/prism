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
K = [1, 2, 3] # 1, 2, 3 // number of probes to send
N = [1] # 1, 2, 3 // number of abstract hosts -- this affects expected time/reward, not probability
# SPEC
P = [1] # 1, 2
# 1) Pmax=?[ F l=4 ]
# 2) Pmax=?[ F (l=4 & ip=1) ] // always very tiny values


REPORTS_DIR = '../reports'
REPORT_FILE = os.path.join(REPORTS_DIR, 'report_zeroconf.txt')
STRATEGIES_DIR = '../strategies/zeroconf'

def run_all():
  if not os.path.exists(REPORTS_DIR):
    os.makedirs(REPORTS_DIR)
  if not os.path.exists(STRATEGIES_DIR):
    os.makedirs(STRATEGIES_DIR)


  f = open(REPORT_FILE,'w')
  for ki in K:
    for ni in N:
      for pi in P:

        if (len(N) == 1):
          str_name = ('zeroconf_%d__p%s' %
                      (ki, pi))
        else:
          str_name = ('zeroconf_%d_%d__p%s' %
                      (ki, ni, pi))
        str_full_path = os.path.join(STRATEGIES_DIR,
                                     ('%s.prism' % str_name))
        print(str_name)

        command_parts = ['../../prism/bin/prism -javamaxmem 4g -cuddmaxmem 2g',
                         '-noprob0 -noprob1',
                         '../models/zeroconf/zeroconf.nm',
                         '../models/zeroconf/zeroconf.pctl',
                         '-const reset=false,N=%d,K=%d,err=0.1' % (ni, ki),
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

