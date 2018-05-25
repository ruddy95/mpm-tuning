#!/bin/bash

_PIDS=(`pgrep httpd`)
_PROC_COUNT=${#_PIDS[@]}

_MEMORY_TOTAL=`free | grep Mem | awk '{print $2;};'`
_RSS_TOTAL=0
_SHARED_TOTAL=0

for _PID in ${_PIDS[@]}; do
    _SMAPS=`cat /proc/$_PID/smaps`
    _RSS=`echo "$_SMAPS" | grep Rss | awk '{value += $2} END {print value;};'`
    _SHARED=`echo "$_SMAPS" | grep Shared | awk '{value += $2} END {print value;};'`
    _RSS_TOTAL=`expr $_RSS_TOTAL + $_RSS`
    _SHARED_TOTAL=`expr $_SHARED_TOTAL + $_SHARED`
done

_RSS_AVERAGE=`expr $_RSS_TOTAL / $_PROC_COUNT`
_SHARED_AVERAGE=`expr $_SHARED_TOTAL / $_PROC_COUNT`
_PROC_MEMORY=`expr $_RSS_AVERAGE - $_SHARED_AVERAGE`
_CALCED_MAX_CLIENTS=`expr $_MEMORY_TOTAL / $_PROC_MEMORY`
_THREAD_PER_CHILD=`expr $_CALCED_MAX_CLIENTS / 3`
_MAX_CLIENTS=$_THREAD_PER_CHILD * 3

echo "MaxClients (=MinSpareThreads =MaxSpareThreads) = $_MAX_CLIENTS"
echo "ThreadPerChild (=ThreadLimit)                  = $_THREAD_PER_CHILD"
echo "MaxConnectionPerChild                          = 4000"

exit 0
