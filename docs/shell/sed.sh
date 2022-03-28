:!/bin/bash
echo this is example | sed 's/\w\+/[&]/g'
echo this is digit 7 in a number | sed 's/digit \([0-9]\)/\1/'


