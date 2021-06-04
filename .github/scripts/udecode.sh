#!/usr/bin/env bash

set -Ceu

DALL=0

# array which elements are two bytes hex string
tbts=($(cat ${1+"$@"} | xxd -c1 | cut -f 2 -d " "))

while [[ ${#tbts[@]} -gt 0 ]]
do
	if [[ $((0x${tbts[0]}>>7)) -eq 0 ]]
	then
		if [[ $DALL -eq 0 && $((0x${tbts[0]})) -gt 0x1F && (
		  ($((0x${tbts[0]})) -ge 0x30 && $((0x${tbts[0]})) -le 0x39)
		  || ($((0x${tbts[0]})) -ge 0x41 && $((0x${tbts[0]})) -le 0x5A)
		  || ($((0x${tbts[0]})) -ge 0x61 && $((0x${tbts[0]})) -le 0x7A)
		  ) ]]
		then
      echo -en \\u$( printf "%04x" $(( 0x${tbts[0]})) )
		else
#		  if [[
#		  ($((0x${tbts[0]})) -ge 0x21 && $((0x${tbts[0]})) -le 0x2F)
#		  || ($((0x${tbts[0]})) -ge 0x3A && $((0x${tbts[0]})) -le 0x40)
#		  || ($((0x${tbts[0]})) -ge 0x5B && $((0x${tbts[0]})) -le 0x60)
#		  || ($((0x${tbts[0]})) -ge 0x7B && $((0x${tbts[0]})) -le 0x7E)
#		  ]]; then
#		    echo -n "\u005c"
#		  fi
			echo -n \\u$( printf "%04x" $(( 0x${tbts[0]})) )
		fi
		tbts=(${tbts[@]:1})
	elif [[ $((0x${tbts[0]}>>5)) -eq 6 ]]
	then
	  echo -en "${tbts[0]}"
#		echo -n \\u$( printf "%04x" $(( (0x${tbts[0]}&31)<<6|(0x${tbts[1]}&63) )) )
		tbts=(${tbts[@]:2})
	elif [[ $((0x${tbts[0]}>>4)) -eq 14 ]]
	then
#	  echo -en "${tbts[0]}"
		echo -n \\u$( printf "%04x" $(( ((0x${tbts[0]}&15)<<6|(0x${tbts[1]}&63))<<6|(0x${tbts[2]}&63) )) )
		tbts=(${tbts[@]:3})
	elif [[ $((0x${tbts[0]}>>3)) -eq 30 ]]
	then
		utf16b=$( printf "%08x" $(( (((0x${tbts[0]}&7)<<6|(0x${tbts[1]}&63))<<6|(0x${tbts[2]}&63))<<6|(0x${tbts[3]}&63) )) )
#    echo -en "\u$utf16b"
		echo -n "\u${utf16b:0:4}"
		echo -n "\u${utf16b:4:8}"
#		echo -n \\U$( printf "%08x" $(( (((0x${tbts[0]}&7)<<6|(0x${tbts[1]}&63))<<6|(0x${tbts[2]}&63))<<6|(0x${tbts[3]}&63) )) )
		tbts=(${tbts[@]:4})
	else
		echo "Convert Error" >&2
		exit 1
	fi
done
