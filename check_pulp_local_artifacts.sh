#!/bin/bash

FULL_LIST="/tmp/full_list_packages.sql"
PULP_DIR="/var/lib/pulp/media/artifact"
OUTPUT="/tmp/output_list.txt"

#select "pkgId",location_href from rpm_package limit 1;
echo "select \"pkgId\",location_href from rpm_package" | su - postgres -c "psql pulpcore" >$FULL_LIST

for b in $(cat $FULL_LIST | sed '1,2d' | grep -v ^$ | grep -v ^\( | awk '{print $1}')
do
  dir=$(echo $b | cut -c1-2)
  file=$(echo $b | cut -c3-)
  if [ -f $PULP_DIR/$dir/$file ]; then
    echo "file - $PULP_DIR/$dir/$file is present" | tee -a $OUTPUT
  else
    echo "file - $PULP_DIR/$dir/$file is missing" | tee -a $OUTPUT
  fi
done

echo
echo
echo
echo "Please, check the file $OUTPUT"
echo
echo "Missing .: $(grep "is missing" $OUTPUT | wc -l)"
echo "Present .: $(grep "is present" $OUTPUT | wc -l)"
echo "Total ...: $(wc -l $OUTPUT)"
