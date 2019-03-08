#!/bin/bash
MODEL="../models/zeroconf/zeroconf.nm"
PROPS="../models/zeroconf/zeroconf.pctl"
PRISM="../../../prism/bin/prism"
PRECISION="1e-8"

LOG="zeroconf_mcts_ucb_c_dependence.log"
mkdir -p "../logs"

for n in "MAX_DIFF" "HIGH_PROB" "DETERMINISTIC" ; do
	for k in 200; do
		for c in "0.1" "0.3" "0.5" "0.707" "1" "2" "4"; do
			for l in `seq 1 5`; do
				command="/usr/bin/time -f '%U' $PRISM $MODEL $PROPS
					-ex -const reset=false,K=$k,N=200,err=0.1,k=1
					-prop 1 -heuristic MCTS_RTDP_UNBOUNDED
					-next_state $n -heuristic_verbose
					-heuristic_epsilon $PRECISION -ucb1constant $c"
				echo $command
				echo -n "K=$k n=$n c=$c time="
				eval $command 2>&1 > "../logs/ucb_c_dep_K${k}_n${n}_c${c}_run${l}.log"

#				/usr/bin/time -f "%U" $PRISM "$MODEL" "$PROPS" -ex \
#					-const "reset=false,K=$k,N=20,err=0.1,k=1" \
#					-prop 1 -heuristic MCTS_RTDP_UNBOUNDED \
#					-next_state $n -heuristic_verbose -heuristic_epsilon 1e-6 \
#					-ucb1constant $c 2>&1 \
#				   	> "../logs/ucb_c_dep_K${k}_n${n}_c${c}_run${l}.log"
			done
		done
	done
done
