#!/bin/bash

# VCAP_SERVICES=`cat vcap.json`
# First argument ($1) is the application name
# VCAP_SERVICES must be retrieved; if login to the IBM Cloud Public, you can use the following line:
if [[ ! -z $1 ]]; then 
  VCAP_SERVICES=`ibmcloud cf env $1 | awk '/VCAP_SERVICES/{flag=1;next} /VCAP_APPLICATION/{flag=0} flag' | sed  -e '$d' | sed -e '$d' | sed -e ‘$d’`
elif [[ -z $VCAP_SERVICES ]]; then
  echo "Either you provide the application name as the first argument while logging in to ibmcloud of you supply VCAP_SERVICES variable"
  exit 100
fi

IFS=$'\n'
if [[ ! -z "$VCAP_SERVICES" ]]; then
  # Inject VCAP_SERVICES to server.xml
  # Modify runtime-vars.xml
  echo "<server>"
  for class in $(echo $VCAP_SERVICES |  jq -r 'keys []')
  do
    # echo $class
    for ix in $(echo $VCAP_SERVICES | jq --arg c $class '.[$c] | keys []' )
    do
      # echo $ix
      sname=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."name"'`
      iname=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."instance_name"'`
      lname=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."label"'`
      echo "  <variable name='cloud.services.$sname.name' value='$sname'/>"
      echo "  <variable name='cloud.services.$sname.instance_name' value='$iname'/>"
      echo "  <variable name='cloud.services.$sname.label' value='$lname'/>"
      credlist=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix '.[$c][$i] | ."credentials" | keys []'`
      for fld in $credlist
      do
        fldval=`echo $VCAP_SERVICES | jq -r --arg c $class --argjson i $ix --arg f $fld '.[$c][$i] | ."credentials" | .[$f]'`
        echo "  <variable name='cloud.services.$sname.connection.$fld' value='$fldval'/>"
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
  echo "</server>"
fi
