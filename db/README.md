# TODO

to build image: docker build -t "name:Dockerfile" .

to run image: docker run --detached imageID
to start container: docker container start containerID

Pocketbase port: 8080
to get ip: docker inspect   --format '{{ .NetworkSettings.IPAddress }}' conteinerID