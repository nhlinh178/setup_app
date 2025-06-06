#!/bin/bash

# Remove old versions of Docker if any
sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

# Install necessary plugins for DNF
sudo dnf -y install dnf-plugins-core

# Add Docker's official repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install Docker and related components
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and Start Docker service
sudo systemctl enable docker --now
# Stop Docker service to prepare for directory change
sudo systemctl stop docker

# Move Docker directory to /data/docker
sudo cp -r /var/lib/docker /var/lib/docker.bak
sudo mv /var/lib/docker /data/

# Overwrite daemon.json with new configuration
echo '{
    "bip": "55.55.1.1/24",
    "data-root": "/data/docker"
}' | sudo tee /etc/docker/daemon.json

# Enable and start Docker service
sudo systemctl enable --now docker
sudo usermod -aG docker isofh
# Verify Docker installation
sudo docker --version
# Install Cadvisor
docker run  --volume=/:/rootfs:ro   --volume=/var/run:/var/run:ro   --volume=/sys:/sys:ro   --volume=/data/docker/:/var/lib/docker:ro   --volume=/dev/disk/:/dev/disk:ro   --publish=9092:8080   --detach=true   --restart always   --name=cadvisor   --privileged   --device=/dev/kmsg   gcr.io/cadvisor/cadvisor:latest
# Add funtion 
echo "alias his='cd /data/server/emr/td-production/his'
function commitId() {
    echo http://${3:-127.0.0.1}:${2:-2301}/api/${1:-his}/v1/utils/commitId
    curl http://${3:-127.0.0.1}:${2:-2301}/api/${1:-his}/v1/utils/commitId
}
function log() {
  find log* -maxdepth 1 -type f -name "*.tmp" -mmin +60 -delete
  if [ -n "$1" ]; then
    suffix="-*-*${1}*"
  else
    suffix=""
  fi
  log_file=$(find log* -maxdepth 1 -type f -name "*${suffix}.log" -printf "%f %T@ %p\n" | awk '{ print length($1), $2, $3 }' | sort -k1,1n -k2,2nr | head -n 1 | awk '{print $3}')
  if [ -z "$log_file" ]; then
    echo Không tìm được file log: *${suffix}.log
  else
    echo File log: ${log_file}
    if [[ "${2}" == "3" ]]; then
      less $log_file
    elif [[ "${2}" == "2" ]]; then
      less +G $log_file
    else
      tail -f $log_file
    fi
  fi
}

alias dils='docker image ls'
alias dirm='docker image rm'

alias dcls='docker container ls -a --size'
alias dcrm='docker container rm'

alias dcb='docker build . -t'

alias dr='docker restart'

alias dl='docker logs'

alias ds='docker stats'

alias din='docker inspect'

alias dcc='docker cp'

alias dload='docker load -i'

function dlf() {

	container=$1

    keyword1=${2:-ZZZZAAAA}

    keyword2=${3:-ZZZZAAAA}

    keyword3=${4:-ZZZZAAAA}

    if [[ -z "${container}" ]]; then
        echo Invalid container
        return
    fi

	docker logs -f --since 30s ${container} | sed --unbuffered -e 's/\(.*'${keyword1}'.*\)/\o033[31m\1\o033[39m/' -e 's/\(.*'${keyword2}'.*\)/\o033[33m\1\o033[39m/' -e 's/\(.*'${keyword3}'.*\)/\o033[32m\1\o033[39m/'
}

function dcl() {
	sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' $1)
}

function drun() {
	docker run --rm --name $2 -it $1 /bin/bash
}

function drun_network_host() {
	docker run --rm --network=host --name $2 -it $1 /bin/bash
}

function dsave() {
	docker save $1 | gzip > $2.tar.gz
}


function dexec() {
	docker exec -u 0 -it $1 /bin/bash
}

function dt() {
	for i in $( docker container ls --format "{{.Names}}" ); do
		echo Container: $i
		docker top $i -eo pid,ppid,cmd,uid
	done
}" | sudo tee -a /home/isofh/.bashrc 

docker load -i /data/server/app-image/rabbitmq_1.0.tar

docker load -i /data/server/app-image/centos7_java8_spring_1.5.tar

docker load -i /data/server/app-image/ubuntu_java17_spring_1.2.tar

docker load -i /data/server/app-image/zipkin_latest.tar

docker images
