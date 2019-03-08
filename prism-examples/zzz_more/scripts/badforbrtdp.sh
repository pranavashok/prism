#../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase1.nm -pf "Pmax=?[ F (x=3) ]" -timeout 900 -heuristic BRTDP -heuristic_verbose -next_state MAX_DIFF
#../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase1.nm -pf "Pmax=?[ F (x=3) ]" -timeout 900 -ucb1constant 0.5 -heuristic MCTS_BRTDP -heuristic_verbose -mctsheuristic VCB -next_state MAX_DIFF
#../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase1.nm -pf "Pmax=?[ F (x=3) ]" -timeout 900 -ucb1constant 5 -heuristic MCTS_BRTDP -heuristic_verbose -mctsheuristic VCB -next_state MAX_DIFF
#../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase1.nm -pf "Pmax=?[ F (x=3) ]" -timeout 900 -ucb1constant 20 -heuristic MCTS_BRTDP -heuristic_verbose -mctsheuristic VCB -next_state MAX_DIFF
#../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase1.nm -pf "Pmax=?[ F (x=3) ]" -timeout 900 -ucb1constant 20 -heuristic MCTS_BRTDP -heuristic_verbose -mctsheuristic UCB1 -next_state MAX_DIFF
#../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase1.nm -pf "Pmax=?[ F (x=3) ]" -valiter

# Result within 10^-4 in 900 seconds
#../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase2.nm -pf "Pmax=?[ F (l=4 & ip=1 & x=3) ]" -timeout 900 -const "reset=false,err=0.1,N=200,K=100" -ucb1constant 1 -heuristic MCTS_BRTDP -heuristic_verbose -mctsheuristic VCB -next_state MAX_DIFF

# Result within 10^-4 in 1085 seconds
# ../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase2.nm -pf "Pmax=?[ F (l=4 & ip=1 & x=3) ]" -timeout 1500 -const "reset=false,err=0.1,N=200,K=100" -ucb1constant 5 -heuristic MCTS_BRTDP -heuristic_verbose -mctsheuristic UCB1 -next_state MAX_DIFF -heuristic_epsilon 10e-4

# Value Iteration
../../../prism/bin/prism -ex ../models/badforbrtdp/worstcase2.nm -pf "Pmax=?[ F (l=4 & ip=1 & x=3) ]" -timeout 1800 -const "reset=false,err=0.1,N=200,K=100" -valiter
