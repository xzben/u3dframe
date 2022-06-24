#!/bin/bash  
out_log="$1/Podfile.log"
#pod help >> $2
cd $1 && export LC_ALL='en_US.UTF-8' && pod install --no-repo-update --verbose >> $out_log
wait

