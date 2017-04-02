# =============================================================================
# Bash Script
#
# NAME: selinux/install_module_from_te.sh
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.05
#
# PURPOSE: Install an selinux module.
#
# NOTES:
#   Idea repurposed from: http://bit.ly/2mbanmT
#

NAME=$1
checkmodule -M -m -o ${NAME}.mod ${NAME}.te
semodule_package -m ${NAME}.mod -o ${NAME}.pp
semodule -i ${NAME}.pp
