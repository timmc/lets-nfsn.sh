#!/usr/bin/env bash
Dir=`dirname $0`
RealDir=`realpath ${Dir}`
exec ${RealDir}/dehydrated/dehydrated --cron
