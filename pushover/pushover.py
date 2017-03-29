# =============================================================================
# Python Source File
#
# NAME: pushover.py
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.03.24
#
# PURPOSE: Alert with pushover directly.
#
# NOTES:
#
'''
Send a message to a Pushover user or group.

:param user:        The Pushover User or Group Key.
:param token:       The PushOver Application token.
:param title:       Title of the message.
:param message:     The message to send to the PushOver user or group.
:param device:      The specific device of a user. The default is to send it to all devices.
:param priority:    The priority of the message, defaults to 0.
:param expire:      The message should expire after N number of seconds.
:param retry:       The number of times the message should be retried.
:param sound:       The sound to associate with the message.
:param api_version: The PushOver API version, if not specified in the configuration.
:return:            Boolean if message was sent successfully.
'''

from __future__ import absolute_import
from json import dumps
from sys import exit
import requests
import argparse


def get_args():
    parser = argparse.ArgumentParser(description='This script sends messages directly to pushover')
    parser.add_argument('-user', required=True, type=str, help='The Pushover User or Group Key')
    parser.add_argument('-token', required=True, type=str, help='The Pushover Application Token')
    parser.add_argument('-title', required=True, type=str, help='The message to send to the PushOver user or group.')
    parser.add_argument('-message', required=True, type=str, help='The message to send to the PushOver user or group.')
    parser.add_argument('-device', required=False, default=None, type=str, help='The specific device of a user. The default is to send it to all devices.')
    parser.add_argument('-priority', required=False, default=None, type=int, help='The priority of the message, defaults to 0.')
    parser.add_argument('-expire', required=False, default=None, type=int, help='The message should expire after N number of seconds.')
    parser.add_argument('-retry', required=False, default=None, type=int, help='The number of times the message should be retried.')
    parser.add_argument('-sound', required=False, default=None, type=str, help='The sound to associate with the message')
    parser.add_argument('-api_version', required=False, default=1, type=int, help='Pushover API version')
    args = parser.parse_args()
    parameters = dict()
    parameters['user'] = args.user
    parameters['token'] = args.token
    parameters['title'] = args.title
    parameters['message'] = args.message
    parameters['device'] = args.device
    parameters['priority'] = args.priority
    parameters['expire'] = args.expire
    parameters['retry'] = args.retry
    parameters['sound'] = args.sound
    return parameters


def post_message(parameters):
    url = 'https://api.pushover.net/1/messages.json'
    try:
        r = requests.post(url, headers={'Content-Type': 'application/x-www-form-urlencoded'}, data=parameters)
    except Exception as err:
        print('Error: {0}'.format(err))
        exit(2)

    if r.json()['status'] == 1:
        print('Sent!')
        exit(0)
    else:
        print('Failed: {0}'.format(r.json()))
        exit(1)


if __name__ == "__main__":
    parameters = get_args()
    post_message(parameters)
