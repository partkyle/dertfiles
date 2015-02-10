function docker_setup
	set -g -x DOCKER_HOST tcp://192.168.59.116:2376
  set -g -x DOCKER_CERT_PATH /Users/partkyle/.boot2docker/certs/boot2docker-vm
  set -g -x DOCKER_TLS_VERIFY 1
end
