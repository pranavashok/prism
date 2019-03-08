#!/bin/bash
MODEL="../models/wlan/wlan"
PROPS="../models/wlan/wlan.pctl"
HEURISTICS="../../bin"
LOG="../logs"

for l in `seq 1 20`; do
LOG="../logs"
LOG=$LOG/exp$l;
echo "Creating folder " $LOG
mkdir $LOG
for k in 2 3 4 5 6; do
	for h in "RTDP_UNBOUNDED"; do
		for n in "DETERMINISTIC" "HIGH_PROB" "MAX_DIFF"; do
			echo k=$k h=$h n=$n heuristics
			time $HEURISTICS/prism $MODEL$k.nm $PROPS -ex -const k=0,TRANS_TIME_MAX=10 -prop 1 -heuristic $h -next_state $n -heuristic_verbose > $LOG/wlan\_heuristic\_$k\_h\_$h\_n\_$n.log
		done
	done
	echo k=$k trunk
	time $HEURISTICS/prism $MODEL$k.nm $PROPS -const k=0,TRANS_TIME_MAX=10 -prop 1 -absolute -epsilon 1e-6 -hybrid > $LOG/wlan\_trunk\_hybrid\_$k.log
	time $HEURISTICS/prism $MODEL$k.nm $PROPS -const k=0,TRANS_TIME_MAX=10 -prop 1 -absolute -epsilon 1e-6 -mtbdd >  $LOG/wlan\_trunk\_mtbdd\_$k.log
	time $HEURISTICS/prism $MODEL$k.nm $PROPS -const k=0,TRANS_TIME_MAX=10 -prop 1 -absolute -epsilon 1e-6 -sparse > $LOG/wlan\_trunk\_sparse\_$k.log
done
done
