#!/bin/bash
for i in {1..50}; do
	./.build/debug/Conductor Tests/Resources/rules.json Tests/Resources/europe.json > /dev/null
	if [$? != 0]; then
		"ERROR+++++++++++++++++++++++++++++++++++++++++"
		 exit
	fi
done;

