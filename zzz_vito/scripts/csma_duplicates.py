#!/usr/bin/env python

import os

STRAT_DIR = '../strategies/csma'
DUPL_DIR = os.path.join(STRAT_DIR, 'filteredDuplicates')


def compare_strategies(old_strategy, file_full_path):
  new_strategy = []
  i = -1
  same = True
  for line in open(file_full_path,'r'):
    i += 1
    if line == '\n':
      break
    if same:
      if (i >= len(old_strategy) or line != old_strategy[i]):
        same = False
    new_strategy.append(line)
  return [] if same else new_strategy


def check_duplicates():
  # Iterates over strategies and checks for duplicates with bigger k
  file_names = [f for f in os.listdir(STRAT_DIR)
                if os.path.isfile(os.path.join(STRAT_DIR, f))]
  to_move_as_duplicate = []

  current_p = ''
  current_file_name = ''
  current_strategy = []
  for file_name in sorted(file_names):
    print(file_name)
    file_full_path = os.path.join(STRAT_DIR, file_name)
    new_p = file_name.split('_')[-2]
    if new_p != current_p and int(new_p[1:]) % 2 == 1: # Even is the max/min version of same-but-P1/P0 objective
      print('"%s" is different from "%s"' % (new_p, current_p))
      current_p = new_p
      current_file_name = file_name
      current_strategy = compare_strategies([], file_full_path)
      assert(len(current_strategy) > 100)
    else:
      new_strategy = compare_strategies(current_strategy, file_full_path)
      if len(new_strategy) == 0:
        print('Same strategy as in %s' % current_file_name)
        to_move_as_duplicate.append(file_name)
      else:
        print('Different strategy, sizes %d previous vs %d now'
              % (len(current_strategy), len(new_strategy)))
        current_strategy = new_strategy
        current_file_name = file_name

  return to_move_as_duplicate


def move_duplicates(file_name_list):
  if len(file_name_list) == 0:
    print('NOTHING TO MOVE')
    return
  print('MOVING %d items' % len(file_name_list))
  if not os.path.exists(DUPL_DIR):
    os.makedirs(DUPL_DIR)
  for file_name in file_name_list:
    file_prev_path = os.path.join(STRAT_DIR, file_name)
    file_new_path = os.path.join(DUPL_DIR, file_name)
    print('%s --> %s' % (file_prev_path, file_new_path))
    try:
      os.remove(file_new_path)
    except OSError: pass
    os.rename(file_prev_path, file_new_path)


to_move = check_duplicates()
move_duplicates(to_move)

