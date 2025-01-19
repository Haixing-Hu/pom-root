#!/bin/bash

################################################################################
#
#  The script to synchronize the current branch to the dev branch.
#
#  Usage: syncdev.sh
#
#  Author: Haixing Hu (starfish.hu@gmail.com)
#
################################################################################

current=$(git branch | grep '^\*' | awk '{print $2}');
git pull && git checkout dev && git merge ${current} && git push && git checkout ${current}