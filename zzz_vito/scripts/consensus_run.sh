#!/bin/bash
declare -a coin=(2) # 2 4 6 8 10
declare -a K=(1) # 1 2 3 4
declare -a k=(1) # 1 2 3 4 5 6
declare -a p=(08) # 01 02 03 04 05 06 07 08
# Access: echo "${arr[0]}", "${arr[1]}"

mkdir -p ../reports
mkdir -p ../strategies/consensus/
ONEREPORT=../reports/last.txt
REPORT=../reports/report_consensus.txt

for ci in "${coin[@]}"
do
for Ki in "${K[@]}"
do
for pi in "${p[@]}"
do
for ki in "${k[@]}"
do
   STRFILE=coin"$ci"_K"$Ki"__k"$ki"_p"$pi"
   STRPATH=../strategies/consensus/"$STRFILE".prism

   echo $STRFILE
   printf "\n\n=========\n$STRFILE\n=========\n\n" > $ONEREPORT
   ../../prism/bin/prism -javamaxmem 4g -cuddmaxmem 2g \
   -noprob0 -noprob1 \
   ../models/consensus/coin"$ci".nm \
   ../models/consensus/coin.pctl \
   -const K="$Ki",k="$ki" \
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
