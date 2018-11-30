docker-compose down

docker build -t mykeycloak .

docker-compose up -d

docker logs mykeycloak -f
