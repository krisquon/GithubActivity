#/bin/bash
function killitif {
  docker ps -a  > /tmp/yy_xx$$
  if grep --quiet $1 /tmp/yy_xx$$
    then
    echo "killing older version of $1"
    docker rm -f `docker ps -a | grep $1  | sed -e 's: .*$::'`
    docker container prune -f
 fi
}

localMachine="$(docker-machine ip default)"
port="$(docker port ecs189_proxy_1)"
port="${port:0:4}"
docker ps > /tmp/xx__yy$$
if grep --quiet web1 /tmp/xx__yy$$
  then
  killitif web2
  echo "starting up web2..."
  docker run -d --network ecs189_default --name web2 $1
  until [ "`/usr/bin/docker inspect -f {{.State.Running}} web2`"=="true" ]
    do
    sleep 1
  done
  echo "swapping to web2..."
  docker exec ecs189_proxy_1 /bin/bash /bin/swap2.sh
  killitif web1
  echo "redirecting to the service"
  until $(curl --output /dev/null --silent --head --fail http://${localMachine}:${port})
	do
    sleep 1
  done
  echo "swapped to $1"
elif grep --quiet web2 /tmp/xx__yy$$
  then
  killitif web1
  echo "starting up web1..."
  docker run -d --network ecs189_default --name web1 $1
  until [ "`/usr/bin/docker inspect -f {{.State.Running}} web1`"=="true" ]
    do
    sleep 1
  done
  echo "swapping to web1..."
  docker exec ecs189_proxy_1 /bin/bash /bin/swap1.sh
  killitif web2
  echo "redirecting to the service"
  until $(curl --output /dev/null --silent --head --fail http://${localMachine}:${port})
	do
    sleep 1
  done
  echo "swapped to $1"
else
  echo "not a swappable container"
fi