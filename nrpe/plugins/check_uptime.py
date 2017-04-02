# ==============================================================================
# Python Script
#
# NAME: nrpe/plugins/check_uptime.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.07
#
# PURPOSE: Nagios plugin to provide a way to check if uptime.
#
# NOTES:
#

from __future__ import absolute_import
import datetime
from uptime import boottime
from sys import exit
import argparse


def get_values():
    parser = argparse.ArgumentParser(description="This script checks for uptime greater than the args passed to it.")
    parser.add_argument('-ld', required=False, type=int, default=0, help="Number of days when under to alert at.")
    parser.add_argument('-lh', required=False, type=int, default=0, help="Number of hours when under to alert at.")
    parser.add_argument('-lm', required=False, type=int, default=0, help="Number of minutes when under to alert at.")
    parser.add_argument('-gd', required=False, type=int, default=0, help="Number of days when over to alert at.")
    parser.add_argument('-gh', required=False, type=int, default=0, help="Number of hours when over to alert at.")
    parser.add_argument('-gm', required=False, type=int, default=0, help="Number of minutes when over to alert at.")
    args = parser.parse_args()
    less_value_timedelta = datetime.timedelta(days=args.ld, hours=args.lh, minutes=args.lm)
    greater_value_timedelta = datetime.timedelta(days=args.gd, hours=args.gh, minutes=args.gm)
    return less_value_timedelta, greater_value_timedelta


less_value_timedelta, greater_value_timedelta = get_values()
less_value = int(less_value_timedelta.total_seconds()/60)
greater_value = int(greater_value_timedelta.total_seconds()/60)

now = datetime.datetime.now()
boottime = boottime()
uptime = now - boottime

less_diff = uptime - less_value_timedelta
less_diff_minutes = int(less_diff.total_seconds()/60)

greater_diff = uptime - greater_value_timedelta
greater_diff_minutes = int(greater_diff.total_seconds()/60)

if less_diff_minutes < 0:
    print('Uptime of {0} is less than {1} minutes!'.format(uptime, less_value))
    exit(2)
elif greater_diff_minutes > 0:
    print('Uptime of {0} exceeds {1} minutes!'.format(uptime, greater_value))
    exit(2)
else:
    print('Uptime is {0}.'.format(uptime))
    exit(0)
