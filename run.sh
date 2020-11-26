#!/bin/bash

# From https://thesanguy.com/2018/01/24/storage-performance-benchmarking-with-fio/
# test random read/write performance at a 3:1 ratio common for database applications

fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test-iops --filename=fiodata --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75 --numjobs=2 --group_reporting | tee fio.log

echo "beginning sleep if requested"

while [ $COBOL_STILL_EXISTS ]; do
  sleep 3600
done
