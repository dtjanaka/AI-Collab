#!/bin/bash

base_port=5683
base_sim_port=1071
base_video_index=0 #If you have other video devices this should be increased
address="172.17.40.64"
base_display=2 #Depends on your display numbering
num_cameras=$(cat simulator/config.yaml | grep -e "num_humans" | cut -d ' ' -f 2) #$(cat simulator/config.yaml | grep -e "num_humans" -e "num_ais" | cut -d ' ' -f 2  | paste -sd+ | bc) ---> Assuming both humans and ais use cameras
num_cameras=$((num_cameras+1)) #To account for debug camera

for (( c=0; c<$1; c++ ))
do 
	cd webrtc/
	./run_docker_detached.sh --address "$address" --port "$((base_port + c))" #Run server
	echo "docker logs $(docker ps -n 1 | cut -d ' ' -f 1 | tail -n 1)" #To get the password for each server
	cd ../simulator/
	DISPLAY=:$((base_display + c)) ./run_docker_detached.sh --address "https://$address:$((base_port + c))" --video-index $((num_cameras*c)) --sim-port $((base_sim_port + c)) #Run simulator
	cd ../
done

#To stop all containers ---->  docker ps -aq | xargs docker stop
