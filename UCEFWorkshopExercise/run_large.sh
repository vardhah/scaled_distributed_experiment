#!/bin/bash
root_directory=`pwd`
logs_directory=$root_directory/logs

fedmgr_host=127.0.0.1
fedmgr_port=8083

timestamp=`date +"%F_%T"`

function getNumberJoined {
    if (( $# != 1 ))
    then
        echo bad syntax: getNumberJoined federateType
        exit 1
    fi
    federateList=$(curl -s X GET http://$fedmgr_host:$fedmgr_port/federates -H "Content-Type: application/json")
    # JSON Query:
    #   .[] = process all values in the input object
    #   select(...) = exclude entries for resigned federates (resignTime defined) and federates that are not the desired TYPE
    #   enclosing [ ] = combine the result from the above queries into a single JSON array
    #   length = count the number of elements in the combined array
    echo $federateList | jq --arg TYPE "$1" '[.[] | select(.resignTime == null and .federateType == $TYPE)] | length'
}

function waitUntilJoined {
    if (( $# != 2 ))
    then
        echo bad syntax: waitUntilJoined federateType expectedNumber
        exit 1
    fi
    federateType=$1
    expectedNumber=$2

    if (( $expectedNumber < 1 ))
    then
        echo "illegal argument: expectedNumber of federates cannot be $expectedNumber"
        exit 1
    fi

    printf "Waiting for $expectedNumber instances of $federateType to join.."
    while (( $(getNumberJoined $federateType) != $expectedNumber))
    do
        printf "."
        sleep 5
    done
    printf "\n"
}

nc -z $fedmgr_host $fedmgr_port
if [ $? -eq 0 ]; then
    echo Cannot start the federation manager on port $fedmgr_port
    exit 1
fi

if [ ! -d $logs_directory ]; then
    echo Creating the $logs_directory directory
    mkdir $logs_directory
fi

# run the federation manager
cd $root_directory/src/WorkshopExercise_deployment
xterm -fg white -bg black -l -lf $logs_directory/federation-manager-${timestamp}.log -T "Federation Manager" -geometry 140x40+0+0 -e "export CPSWT_ROOT=`pwd` && mvn exec:java -P FederationManagerExecJava" &

printf "Waiting for the federation manager to come online.."
until $(curl -o /dev/null -s -f -X GET http://$fedmgr_host:$fedmgr_port/fedmgr); do
    printf "."
    sleep 5
done
printf "\n"

curl -o /dev/null -s -X POST http://$fedmgr_host:$fedmgr_port/fedmgr --data '{"action": "START"}' -H "Content-Type: application/json"

# run the other federates
cd $root_directory/src/Metronome/MetronomeFederate-java-federates/MetronomeFederate-impl-java/Metronome/target/
xterm -fg red -bg black -l -lf $logs_directory/metronome-${timestamp}.log -T "Metronome" -geometry 140x40+100+50 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar Metronome-0.1.0-SNAPSHOT.jar -configFile=conf/MetronomeConfig.json" &
waitUntilJoined Metronome 1

cd $root_directory/src/Weather/WeatherFederate-java-federates/WeatherFederate-impl-java/Weather/target/
cp ../tmy3.csv .
xterm -fg yellow -bg black -l -lf $logs_directory/weather-${timestamp}.log -T "Weather" -geometry 140x40+200+100 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar Weather-0.1.0-SNAPSHOT.jar -configFile=conf/WeatherConfig.json" &
waitUntilJoined Weather 1

cd $root_directory/src/Utility/UtilityFederate-java-federates/UtilityFederate-impl-java/Utility/target/
xterm -fg green -bg black -l -lf $logs_directory/utility-${timestamp}.log -T "Utility" -geometry 140x40+300+150 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar Utility-0.1.0-SNAPSHOT.jar -configFile=conf/UtilityConfig.json" &
waitUntilJoined Utility 1

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house1-${timestamp}.log -T "House 1" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 1

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house2-${timestamp}.log -T "House 2" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 2

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house3-${timestamp}.log -T "House 3" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 3

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house4-${timestamp}.log -T "House 4" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 4

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house5-${timestamp}.log -T "House 5" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 5

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house6-${timestamp}.log -T "House 6" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 6

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house7-${timestamp}.log -T "House 7" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 7

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house8-${timestamp}.log -T "House 8" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 8

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house9-${timestamp}.log -T "House 9" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 9

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house10-${timestamp}.log -T "House 10" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 10

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house11-${timestamp}.log -T "House 11" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 11

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house12-${timestamp}.log -T "House 12" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 12

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house13-${timestamp}.log -T "House 13" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 13

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house14-${timestamp}.log -T "House 14" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 14

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house15-${timestamp}.log -T "House 15" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 15

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house16-${timestamp}.log -T "House 16" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 16

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house17-${timestamp}.log -T "House 17" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 17

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house18-${timestamp}.log -T "House 18" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 18

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house19-${timestamp}.log -T "House 19" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 19

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house20-${timestamp}.log -T "House 20" -geometry 140x40+600+300 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig1.json" &
waitUntilJoined House 20

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house21-${timestamp}.log -T "House 21" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 21

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house22-${timestamp}.log -T "House 22" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig.json" &
waitUntilJoined House 22

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house23-${timestamp}.log -T "House 23" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 23

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house24-${timestamp}.log -T "House 24" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 24

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house25-${timestamp}.log -T "House 25" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 25

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house26-${timestamp}.log -T "House 26" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 26

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house27-${timestamp}.log -T "House 27" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 27

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house28-${timestamp}.log -T "House 28" -geometry 140x40+500+250 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 28

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house29-${timestamp}.log -T "House 29" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &
waitUntilJoined House 29

cd $root_directory/src/House/HouseFederate-java-federates/HouseFederate-impl-java/House/target/
xterm -fg cyan -bg black -l -lf $logs_directory/house30-${timestamp}.log -T "House 30" -geometry 140x40+400+200 -e "java -Dlog4j.configurationFile=conf/log4j2.xml -Djava.net.preferIPv4Stack=true -jar House-0.1.0-SNAPSHOT.jar -configFile=conf/HouseConfig2.json" &

##################################
# start the simulation
##################################
read -n 1 -r -s -p "Press any key to start the federation execution..."
printf "\n"

curl -o /dev/null -s -X POST http://$fedmgr_host:$fedmgr_port/fedmgr --data '{"action": "START"}' -H "Content-Type: application/json"




# terminate the simulation
read -n 1 -r -s -p "Press any key to terminate the federation execution..."
printf "\n"

curl -o /dev/null -s -X POST http://$fedmgr_host:$fedmgr_port/fedmgr --data '{"action": "TERMINATE"}' -H "Content-Type: application/json"

printf "Waiting for the federation manager to terminate.."
while $(curl -o /dev/null -s -f -X GET http://$fedmgr_host:$fedmgr_port/fedmgr); do
    printf "."
    sleep 5
done
printf "\n"

