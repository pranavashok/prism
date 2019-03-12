#!/bin/bash

STRDIR=../strategies/consensus
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

    #  2) Pmax=? [ F "finished"&"agree" ]
    if [[ $base == *"p2"* ]]; then
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
