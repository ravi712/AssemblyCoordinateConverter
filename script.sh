#!/bin/bash


 input_assembly='GRCh38'
 output_assembly='GRCh37'

while getopts s:e:r:i:o: flag
do
    case "${flag}" in
       s) start_input="${OPTARG}";;
       e) end_input="${OPTARG}";;
       r) region="${OPTARG}";;
       i) input_assembly="${OPTARG}";;
       o) output_assembly="${OPTARG}";;
     esac
done

if [ -z "$start_input" ]
then
 echo "Please provide start value. Specified value can be provided with -s"
 exit 1
fi
if [ -z "$end_input" ]
then
 echo "Please provide end value. Specified value can be provided with -e"
 exit 1
fi
if [ -z "$region" ]
then
 echo "Please provide region. Specified value can be provided with -r"
 exit 1
fi


Response=`curl -s -H "Content-type:application/json" "http://rest.ensembl.org/map/human/${input_assembly}/${region}:${start_input}..${end_input}:1/${output_assembly}"| jq -c --arg region "$region" '.mappings[] | select (.mapped.seq_region_name == $region)'`


if [ -z "$Response" ]
then
 echo "No result found for specified region"
 exit 1
fi

StartOut=`echo $Response | jq -c '.mapped.start'`
EndOut=`echo $Response | jq -c '.mapped.end'`
RegionOut=`echo $Response | jq -c '.mapped.seq_region_name'`
output="{\"start\": $StartOut, \"end\": $EndOut, \"seq_region_name\": ${RegionOut} }"

echo $output
return

