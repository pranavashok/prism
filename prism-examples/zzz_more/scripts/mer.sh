#!/bin/bash
MODEL="../models/mer/mer2_2_full.nm"
PROPS="../models/mer/mer.pctl"
HEURISTICS="../../../prism/bin"

for l in `seq 1 20`; do
LOG="../logs"
LOG=$LOG/exp$l;
echo "Creating folder " $LOG
mkdir $LOG
for N in 1500 3000 4500; do
for x in 0.9999 0.0001; do
	for h in "LRTDP"; do
		for n in "DETERMINISTIC" "HIGH_PROB" "MAX_DIFF"; do
			echo n=$N x=$x h=$h n=$n heuristics 
			time $HEURISTICS/prism $MODEL $PROPS -ex -const n=$N,x=$x,K=30 -prop 2 -heuristic $h -next_state $n -heuristic_verbose > $LOG/mer\_heuristic\_n\_$n\_x\_$x\_h\_$h\_n\_$N.log	
		done
	done
	echo n=$n x=$x trunk hybrid
	time $HEURISTICS/prism $MODEL $PROPS -const n=$N,x=$x,K=30 -prop 2 -absolute -epsilon 1e-6 -hybrid > $LOG/mer\_trunk\_hybrid\_n\_$N\_x\_$x.log	
	echo n=$n x=$x trunk mtbdd
	time $HEURISTICS/prism $MODEL $PROPS -const n=$N,x=$x,K=30 -prop 2 -absolute -epsilon 1e-6 -mtbdd > $LOG/mer\_trunk\_mtbdd\_n\_$N\_x\_$x.log
	echo n=$n x=$x trunk sparse
	time $HEURISTICS/prism $MODEL $PROPS -const n=$N,x=$x,K=30 -prop 2 -absolute -epsilon 1e-6 -sparse > $LOG/mer\_trunk\_sparse\_n\_$N\_x\_$x.log
done
done
done
