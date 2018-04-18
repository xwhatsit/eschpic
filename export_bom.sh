#!/bin/bash

if [ -z "$1" ]; then
	echo "argument for bom file is required"
	exit 1
fi

echo "Sub-BOM, Part, Qty"; tail +2 $1 | sort -g | awk '
	BEGIN {
		FS = ",";
	}

	{
		partcount[$6][$5]+=1;
	}

	END {
		for (i in partcount) {
			for (j in partcount[i])
				print i", " j", " partcount[i][j];
		}
	}
' | sort -g --field-separator='"' --key=2
