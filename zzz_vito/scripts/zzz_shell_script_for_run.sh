#!/bin/bash
declare -a processes=(2) # 2 3 4
declare -a backoff=(2) # 2 4 6
declare -a k=(1 2 3 4 5 6) # 1 2 3 4 5 6
declare -a p=(06 08 09) # 01 02 03 04 05 06 07 08 09 10
# 06) message of some station eventually delivered before k backoffs
# Pmax=?[ F min_backoff_after_success<=k ] --- we need 1 (almost-sure)
# 08) probability all sent successfully before a collision with max backoff
# Pmax=?[ !"collision_max_backoff" U "all_delivered" ] --- we need 1 (almost-sure)
# 09) probability some station suffers at least k collisions
# Pmin=?[ F max_collisions>=k ] --- we need 0 (almost-sure)
# Access: echo "${arr[0]}", "${arr[1]}"

mkdir -p ../reports
mkdir -p ../strategies/csma/
ONEREPORT=../reports/last.txt
REPORT=../reports/report_csma.txt

for pri in "${processes[@]}"
do
for bai in "${backoff[@]}"
do
for pi in "${p[@]}"
do
for ki in "${k[@]}"
do
  if [[ "$pi" == 08 && "$ki" != 1 ]]; then
    # 08) does not depend on k
    continue
  fi

  STRFILE=csma"$pri"_"$bai"__p"$pi"_k"$ki"
  STRPATH=../strategies/csma/"$STRFILE".prism

  echo $STRFILE
  printf "\n\n=========\n$STRFILE\n=========\n\n" > $ONEREPORT
  ../../prism/bin/prism -javamaxmem 4g -cuddmaxmem 2g \
  -noprob0 -noprob1 \
  ../models/csma/csma"$pri"_"$bai".nm \
  ../models/csma/csma.pctl \
  -const k="$ki" \
  -prop "$pi" \
  -explicit  -politer \
  -exportstrat $STRPATH:type=actions \
  >> $ONEREPORT
  cat $ONEREPORT >> $REPORT
  cat $ONEREPORT >> $STRPATH
  sleep 0.1 # so one is able to stop with CTRL+C
done
done
done
done

# http://www.prismmodelchecker.org/manual/FrequentlyAskedQuestions/MemoryProblems

# http://www.prismmodelchecker.org/manual/ConfiguringPRISM/OtherOptions
# Precomputation: -nopre -noprob0 -noprob1

# http://www.prismmodelchecker.org/prismpp/
# Preprocessor to create benchmarks
