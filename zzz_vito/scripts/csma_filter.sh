#!/bin/bash

STRDIR=../strategies/csma
SMALLDIR=$STRDIR/filteredSmall
BADVALUEDIR=$STRDIR/filteredBadvalue

mkdir -p $STRDIR
mkdir -p $SMALLDIR
mkdir -p $BADVALUEDIR

for filename in $STRDIR/*.prism; do
  base=$(basename $filename)
  file_size_kb=`du -k "$filename" | cut -f1`
  if (( $(echo "$file_size_kb < 5" |bc -l) )); then
    echo "$SMALLDIR/$base"
    mv $filename $SMALLDIR
  fi
done

for filename in $STRDIR/*.prism; do
  base=$(basename $filename)

  if grep -q "Value in the initial state" "$filename"; then
    initval=$(grep 'Value in the initial state' $filename | cut -d: -f2)

    #  1) Pmax=? [ !"collision_max_backoff" U "all_delivered" ]
    #  2) Pmax=? [ F min_backoff_after_success<=k ]
    if [[ $base == *"p1"* || $base == *"p2"* ]]; then
      if (( $(echo "$initval < 0.999" |bc -l) )); then
        echo "$BADVALUEDIR/$base    need: 1.0  has val:$initval"
        mv $filename $BADVALUEDIR
      fi
    fi

  elif grep -q "Property satisfied in 0" "$filename"; then
    echo "$BADVALUEDIR/$base    NOT SATISFIED IN INIT"
    mv $filename $BADVALUEDIR
  fi

done

#    #  6) Pmin=? [ F max_collisions>=k ]
#    if [[ $base == *"p6"* ]]; then
#      if (( $(echo "$initval > 0.001" |bc -l) )); then
#        echo "$BADVALUEDIR/$base    need: 0.0  has val:$initval"
#        mv $filename $BADVALUEDIR
#      fi
#    fi
