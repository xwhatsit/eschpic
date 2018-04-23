#!/bin/bash

if [ -z "$1" ]; then
	>&2 echo "error: argument for bom file is required"
	exit 1
fi

tail +2 $1 | awk '
	BEGIN {
		FPAT = "([^,]*)|(\"[^\"]+\")"
	}

	{
		if ($1 == "")
			next;

		if (substr($5, 2, 1) == "*")
			part = "\"" substr($5, 3);
		else
			part = $5;

		count++;
		row[count]["ref"] = $1;
		row[count]["val"] = $2;
		row[count]["description"] = $3;
		row[count]["loc"] = $4;
		row[count]["part"] = part;
		row[count]["uid"] = $7;
	}

	function sortByRef(i1, v1, i2, v2, l, r) {
		l = v1["ref"]
		r = v2["ref"];
		if (l == r)
			return 0;

		match(l, /([0-9]*)([A-Za-z]+)([0-9]+)/, splitRefL);
		match(r, /([0-9]*)([A-Za-z]+)([0-9]+)/, splitRefR);

		sheetL = splitRefL[1] + 0;
		sheetR = splitRefR[1] + 0;
		designatorL = splitRefL[2];
		designatorR = splitRefR[2];
		instanceL = splitRefL[3] + 0;
		instanceR = splitRefR[3] + 0;

		if (sheetL < sheetR) {
			return -1;
		} else if (sheetL > sheetR) {
			return 1;
		} else {
			if (designatorL < designatorR) {
				return -1;
			} else if (designatorL > designatorR) {
				return 1;
			} else {
				if (instanceL < instanceR)
					return -1;
				else if (instanceL > instanceR)
					return 1;
				else
					return 0;
			}
		}
	}

	END {
		asort(row, sorted, "sortByRef");
		for (i in sorted)
			print sorted[i]["ref"] "," sorted[i]["val"] "," sorted[i]["description"] "," sorted[i]["loc"] "," sorted[i]["part"] "," sorted[i]["uid"];
	}
'
