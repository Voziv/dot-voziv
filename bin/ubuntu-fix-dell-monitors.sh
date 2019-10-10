#!/bin/bash
#
# When daisy chaining dell monitors via displayport (on nvidia?)
# the daisy chained monitor hates turning on/off. This forces it
# to wake up again (technically forces sleep, then you move your mouse)
#
xset dpms force off
