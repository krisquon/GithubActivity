#/bin/bash
function killitif {
    docker ps -a  > /tmp/yy_xx$$
    if grep --quiet $1 /tmp/yy_xx$$
     then
     echo "killing older version of $1"
     docker rm -f `docker ps -a | grep $1  | sed -e 's: .*$::'`
   fi
}


# Remove any existing containers, so we don't have failure
# on the run command because of existing named containers. 

killitif proxy
killitif web1
killitif web2
docker container prune -f
docker network prune -f

# Start the compose yml thing up, but using the network name ecs189
# This is so that the other shells know where to find the containers
# to hotswap, regardless of the directories 

docker-compose -p ecs189 up -d & 

# Initially the reverse proxy points at engineering URL 
# WE first make it point at the right url, using the init.sh script

sleep 5 && echo "redirecting to the service"
localMachine="$(docker-machine ip default)"
port="$(docker port ecs189_proxy_1)"
port="${port:0:4}"
sleep 10 && docker exec ecs189_proxy_1 /bin/bash /bin/init.sh
until $(curl --output /dev/null --silent --head --fail http://${localMachine}:${port})
	do
    sleep 1
done
echo "...nginx restarted, should be ready to go!" 


