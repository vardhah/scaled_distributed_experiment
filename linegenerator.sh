#!/bin/bash
# Ask the user for their name
echo enter the Number of times to repeat.
read linecount
lines=""

for (( c=1; c<=$linecount; c++ ))
do  
  echo "cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/xterm -fg cyan -bg black -l -lf $logs_directory/house3-${timestamp}.log -T \"House $c\" -geometry 140x40+600+300 -e \"java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json\" &
waitUntilJoined House $c." >> "output.sh"
done
