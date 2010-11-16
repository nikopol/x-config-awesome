#!/bin/bash
for f in *.png
do
	[[ "`file "$f" | grep '12 x 12'`" ]] && echo "$f" && convert $f -background transparent -gravity center -extent 12x16 $f
done
