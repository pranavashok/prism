#!/bin/bash
MODEL="../models/zeroconf/zeroconf.nm"
PROPS="../models/zeroconf/zeroconf.pctl"
HEURISTICS="../../../prism/bin"

for l in `seq 1 3`; do
LOG="../logs"
LOG=$LOG/exp$l;
echo "Creating folder " $LOG
mkdir $LOG
for k in 2 4 6 8 10 12 14 16 18; do
	for h in "RTDP_UNBOUNDED"; do
		for n in "DETERMINISTIC" "HIGH_PROB" "MAX_DIFF"; do
			echo K=$k h=$h n=$n heuristics 
			time $HEURISTICS/prism $MODEL $PROPS -ex -const reset=false,K=$k,N=20,err=0.1,k=1 -prop 1 -heuristic $h -next_state $n -heuristic_verbose -heuristic_epsilon 1e-6 > $LOG/zeroconf\_heuristic\_K\_$k\_h\_$h\_n\_$n.log	
		done
	done
	for c in "0.707" "1" "2" "4" "8" "16" "32" "64" "128"; do
		for h in "MCTS_RTDP_UNBOUNDED"; do
			for n in "DETERMINISTIC" "HIGH_PROB" "MAX_DIFF"; do
				echo K=$k h=$h n=$n c=$c heuristics 
				time $HEURISTICS/prism $MODEL $PROPS -ex -const reset=false,K=$k,N=20,err=0.1,k=1 -prop 1 -heuristic $h -next_state $n -heuristic_verbose -heuristic_epsilon 1e-6 -ucb1constant $c > $LOG/zeroconf\_heuristic\_K\_$k\_h\_$h\_n\_$n\_c\_$c.log	
			done
		done
	done
	#echo K=$k trunk
	#time $HEURISTICS/prism $MODEL $PROPS -const reset=false,K=$k,N=20,err=0.1,k=1 -prop 1 -absolute -epsilon 1e-8 -hybrid > $LOG/zeroconf\_trunk\_hybrid\_K\_$k.log	
	#time $HEURISTICS/prism $MODEL $PROPS -const reset=false,K=$k,N=20,err=0.1,k=1 -prop 1 -absolute -epsilon 1e-8 -mtbdd > $LOG/zeroconf\_trunk\_mtbdd\_K\_$k.log
	#time $HEURISTICS/prism $MODEL $PROPS -const reset=false,K=$k,N=20,err=0.1,k=1 -prop 1 -absolute -epsilon 1e-8 -sparse > $LOG/zeroconf\_trunk\_sparse\_K\_$k.log
done
done
