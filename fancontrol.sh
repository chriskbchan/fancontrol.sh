#!/bin/bash
#
# set fan speed base on temperature
#

SMC=/usr/local/bin/smc

function getTemp {
   tp=$(${SMC} -r -k TC0D | awk '{print $3}')
   echo $(printf '%.0f\n' ${tp})
}

function getNumFans {
   ${SMC} -r -k FNum | awk '{print $4}'
}

function getTargetSpeed {
   ts=$(${SMC} -r -k "F${1}Tg" | awk '{print $3}')
   echo $(printf '%.0f\n' ${ts})
}

function fanSpeedEncoded {
   #echo `python -c "print hex($1 << 2)"`
   echo $(printf '%x\n' $((${1} << 2)))
}

abs () { echo -E "${1#-}"; }

# fan curve
fanCurve=("0,3500" "60,4500" "80,5500")
# debug only
#for fc in ${fanCurve[@]}; do
#   fcTemp=$(echo $fc | awk -F, '{print $1}')
#   fcSpeed=$(echo $fc | awk -F, '{print $2}')
#   fcSpeedEn=$(fanSpeedEncoded ${fcSpeed})
#   echo $fcTemp $fcSpeed $fcSpeedEn
#done


# start

currTemp=$(getTemp)
currTargetSpeed=$(getTargetSpeed 0)

for fc in ${fanCurve[@]}; do
   fcTemp=$(echo $fc | awk -F, '{print $1}')
   fcSpeed=$(echo $fc | awk -F, '{print $2}')
   if [ "${currTemp}" -gt "${fcTemp}" ]; then
      newTargetSpeed=${fcSpeed}
   fi
done

diffSpeed=$(abs $((newTargetSpeed - currTargetSpeed)))

echo "$(date) | Current temperature is ${currTemp} C, target Fan Speed is ${newTargetSpeed} RPM"
echo "$(date) | Current target Fan Speed is ${currTargetSpeed} RPM, difference is ${diffSpeed}"

if [ "${diffSpeed}" -gt "100" ]; then
   fcSpeedEn=$(fanSpeedEncoded ${newTargetSpeed})
   ${SMC} -k "FS! " -w 0001
   ${SMC} -k F0Tg   -w ${fcSpeedEn}
   echo "$(date) | Set target Fan Speed to ${newTargetSpeed} RPM"
fi

