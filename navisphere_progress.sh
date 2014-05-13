#!/bin/bash
/opt/Navisphere/bin/naviseccli -User sysadmin -Scope 0 -h $1 snapview -listclonegroup | egrep ^'Name|InSync|PercentSynced'

