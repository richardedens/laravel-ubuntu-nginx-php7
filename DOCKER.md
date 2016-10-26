# Create apps and router networks
docker network create --driver=overlay apps
docker network create --driver=overlay router-management
docker service create --name router-storage --network router-management redis:3.2-alpine
docker service create --name router-backend --constraint node.role==manager --mount target=/var/run/docker.sock,source=/var/run/docker.sock,type=bind --network router-management tpbowden/swarm-ingress-router:latest -r router-storage:6379 collector
docker service create --name router --mode global -p 80:8080 -p 443:8443 --network apps  --network router-management tpbowden/swarm-ingress-router:latest -r  router-storage:6379 server -b 0.0.0.0

# Create an app network
docker network create --driver=overlay app_app_network

# Create one instance
docker network create --driver=overlay app_app_network
docker service create --name app_app --label ingress=true --label ingress.dnsname=app-my.local --label ingress.targetport=80 --network app_app_network --network apps richardedens/ubuntu-nginx-php7-laravel:latest
docker service create --name app_app --label ingress=true --label ingress.dnsname=app-my.local --label ingress.targetport=80 --network apps --network app_app_network --mount target=/var/www/html,source=/local/app-laravel,type=bind richardedens/ubuntu-nginx-php7-laravel:latest
docker service create --name app_redis --network app_app_network redis:3.2-alpine
docker service create --name app_mysql -p 3306:3306 --env MYSQL_PASSWORD=appdev --env MYSQL_USER=appdev --env MYSQL_DATABASE=app_dev --env MYSQL_ROOT_PASSWORD=3rd4rd5rd --network app_app_network mysql:8

# Create one instance
docker network create --driver=overlay extra_app_network
docker service create --name extra_app --label ingress=true --label ingress.dnsname=app-bridge-my.local --label ingress.targetport=80 --network extra_app_network --network apps --mount target=/var/www/html,source=/var/www/extrapp,type=bind richardedens/ubuntu-nginx-php7-laravel:latest
docker service create --name extra_redis --network extra_app_network redis:3.2-alpine
docker service create --name extra_mysql --env MYSQL_ROOT_PASSWORD=3rd4rd5rd --network extra_app_network mysql:8
