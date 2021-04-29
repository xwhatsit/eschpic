#!/bin/bash

if [ -z "$1" ]; then
	>&2 echo "error: argument for labels file is required"
	exit 1
fi

echo -e "Sheet,Type,Label,Quantity"
tail +2 $1 | awk '
	BEGIN {
		OFS=",";
		FPAT = "([^,]*)|(\"[^\"]+\")";
		PROCINFO["sorted_in"] = "@ind_num_asc";
	}

	function registerItem(sheet, type, label) {
		if (quantity[sheet][type][label]) {
			quantity[sheet][type][label]++;
		} else {
			quantity[sheet][type][label] = 1;
		}
	}

	{
		registerItem($1, $2, $3);
	}

	END {
		for (sheet in quantity)
			for (type in quantity[sheet])
				for (label in quantity[sheet][type])
					print sheet "," type "," label "," quantity[sheet][type][label];
	}
'
