#!/bin/bash
MODEL="../models/firewire/impl/deadline.nm"
PROPS="../models/firewire/impl/deadline.pctl"
HEURISTICS="../../../prism/bin"

for l in `seq 1 20`; do
LOG="../logs"
LOG=$LOG/exp$l;
echo "Creating folder " $LOG
mkdir $LOG
for d in 36; do
for d_d in 200 220 240 260 280; do
	for h in "RTDP_UNBOUNDED" "MCTS_RTDP_UNBOUNDED"; do
		for n in "DETERMINISTIC" "HIGH_PROB" "MAX_DIFF"; do
			echo d=$d d\_d=$d_d h=$h n=$n heuristics 
			time $HEURISTICS/prism $MODEL $PROPS -ex -const deadline=$d_d,delay=$d,fast=0.5 -prop 1 -heuristic $h -next_state $n -heuristic_verbose > $LOG/firewire\_heuristic\_deadline\_$d_d\_delay\_$d\_h\_$h\_n\_$n.log	
		done
	done
	#echo d=$d trunk
	#time $HEURISTICS/prism $MODEL $PROPS -hybrid -const deadline=$d_d,delay=$d,fast=0.5 -prop 1 -absolute -epsilon 1e-6 > $LOG/firewire\_trunk\_hybrid\_deadline\_$d_d\_delay\_$d.log
	#time $HEURISTICS/prism $MODEL $PROPS -mtbdd -const deadline=$d_d,delay=$d,fast=0.5 -prop 1 -absolute -epsilon 1e-6 > $LOG/firewire\_trunk\_mtbdd\_deadline\_$d_d\_delay\_$d.log	
	#time $HEURISTICS/prism $MODEL $PROPS -sparse -const deadline=$d_d,delay=$d,fast=0.5 -prop 1 -absolute -epsilon 1e-6 > $LOG/firewire\_trunk\_sparse\_deadline\_$d_d\_delay\_$d.log			
done
done
done
