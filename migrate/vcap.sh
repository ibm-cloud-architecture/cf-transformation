#!/bin/bash

# VCAP_SERVICES=`cat vcap.json`
# VCAP_SERVICES must be retrieved; if login to the IBM Cloud Public, you can use the following line:
if [[ -z $VCAP_SERVICES ]]; then
  echo "Either you provide the application name as the first argument while logging in to ibmcloud of you supply VCAP_SERVICES variable"
  exit 100
fi
TGTPATH=$1
vfile="${TGTPATH}/runtime-vars.xml"
IFS=$'\n'
if [[ ! -z "$VCAP_SERVICES" ]]; then
  # Inject VCAP_SERVICES to server.xml
  # Modify runtime-vars.xml
  echo "<server>" > ${vfile}
  for class in $(echo $VCAP_SERVICES |  jq -r 'keys []')
  do
    # echo $class
    for ix in $(echo $VCAP_SERVICES | jq --arg c $class '.[$c] | keys []' )
    do
      # echo $ix
      sname=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."name"'`
      iname=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."instance_name"'`
      lname=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."label"'`
      echo "  <variable name='cloud.services.$sname.name' value='$sname'/>"  >> ${vfile}
      echo "  <variable name='cloud.services.$sname.instance_name' value='$iname'/>" >> ${vfile}
      echo "  <variable name='cloud.services.$sname.label' value='$lname'/>"  >> ${vfile}
      credlist=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."credentials" | keys []'`
      for fld in $credlist
      do
        fldval=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix --arg f $fld '.[$c][$i] | ."credentials" | .[$f]'`
        echo "  <variable name='cloud.services.$sname.connection.$fld' value='$fldval'/>"  >> ${vfile}
      done
      case $class in
        compose_for_mysql) ;;
        compose_for_cleardb) ;;
        compose_for_mongodb) ;;
        compose_for_postgresql) ;;
        compose_for_elephantsql) ;;
        *) ;;
      esac
    done
  done
  echo "</server>" >> ${vfile}
fi
