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
  if (( $(echo "$file_size_kb < 10" |bc -l) )); then
    echo "$SMALLDIR/$base"
    mv $filename $SMALLDIR
  fi
done

for filename in $STRDIR/*.prism; do
  base=$(basename $filename)
  initval=$(grep 'Value in the initial state' $filename | cut -d: -f2)

  # 06) message of some station eventually delivered before k backoffs
  # Pmax=?[ F min_backoff_after_success<=k ] --- we need 1 (almost-sure)
  if [[ $base == *"p06"* ]]; then
    if (( $(echo "$initval < 0.999" |bc -l) )); then
      echo "$BADVALUEDIR/$base    need: 1.0  has val:$initval"
      mv $filename $BADVALUEDIR
    fi
  fi

  # 08) probability all sent successfully before a collision with max backoff
  # Pmax=?[ !"collision_max_backoff" U "all_delivered" ] --- we need 1 (almost-sure)
  if [[ $base == *"p08"* ]]; then
    if (( $(echo "$initval < 0.999" |bc -l) )); then
      echo "$BADVALUEDIR/$base    need: 1.0  has val:$initval"
      mv $filename $BADVALUEDIR
    fi
  fi

  # 09) probability some station suffers at least k collisions
  # Pmin=?[ F max_collisions>=k ] --- we need 0 (almost-sure)
  if [[ $base == *"p09"* ]]; then
    if (( $(echo "$initval > 0.001" |bc -l) )); then
      echo "$BADVALUEDIR/$base    need: 0.0  has val:$initval"
      mv $filename $BADVALUEDIR
    fi
  fi
done
