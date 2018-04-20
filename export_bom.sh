#!/bin/bash

if [ -z "$1" ]; then
	>&2 echo "error: argument for bom file is required"
	exit 1
fi

echo "Item, Part, Qty, Value, Description"
tail +2 $1 | awk '
	BEGIN {
		FS = ",";
		PROCINFO["sorted_in"] = "@ind_str_asc";
	}

	function registerItem(part, parentPart, val, description) {
		if (part == "\"\"") {
			children["\"\""][""][""];
			return;
		}

		if (!(parentPart in children))
			registerItem(parentPart, "\"\"", "\"<UNKNOWN>\"", "\"<UNKNOWN>\"");

		if (!(part in children))
			children[part][""][""];

		if (part in children[parentPart]) {
			children[parentPart][part]["qty"]++;
		} else {
			children[parentPart][part]["qty"]         = 1;
			children[parentPart][part]["val"]         = val;
			children[parentPart][part]["description"] = description;
		}
	}

	function currIDStr() {
		s = "";
		for (i = 0; i <= currLevel; i++) {
			if (i != 0)
				s = s ".";
			s = s id[i];
		}
		return s;
	}

	function printItem(part, parentItem) {
		if (part == "")
			return;
		id[currLevel]++;
		print currIDStr() "\t" part "\t" children[parentItem][part]["qty"] "\t" children[parentItem][part]["val"] "\t" children[parentItem][part]["description"];
		currLevel++;
		for (child in children[part])
			printItem(child, part);
		id[currLevel] = 0;
		currLevel--;
	}

	{
		registerItem($5, $6, $2, $3);
	}

	END {
		currLevel = 0;
		id[currLevel] = 0;
		for (part in children["\"\""]) {
			printItem(part, "\"\"");
		}
	}
'
