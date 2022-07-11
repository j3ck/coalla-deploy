#!/bin/bash
source "/usr/local/rvm/scripts/rvm"
rvm use 1.9.3
cap production deploy rails_env=production