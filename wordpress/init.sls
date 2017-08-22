# =============================================================================
# SaltStack State File
#
# NAME: wordpress/init.sls
# WRITTEN BY: Alek Tant of SmartAlek Solutions
# DATE  : 2017.08.19
#
# PURPOSE: Setup Wordpress with Nginx
#
# NOTES:
#


include:
  - .wordpress
  - .nginx
