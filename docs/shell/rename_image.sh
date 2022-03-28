#!/bin/bash
cd /Users/hhh/workspace/gitbook/docs/shell/image
count=1
for img in *.[Jj][Pp][Gg] *.png; do
    new=image-$count.${img##*.}
    mv "$img" "$new" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo Rename "$img" To "$new"
        let count++
    fi
done


