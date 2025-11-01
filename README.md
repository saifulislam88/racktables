### racktables
RackTables is a nifty and robust solution for datacenter and server room asset management. It helps document hardware assets, network addresses, space in racks, networks configuration and much much more!

Project structure


Step:1 
git clone https://github.com/saifulislam88/racktables.git
cd racktables
docker-compose build
docker-compose up -d --build
docker-compose logs -f 
docker-compose ps

Step:2
http://172.17.6.163/

Step:3
docker exec -it racktables_app_1 sh -c "touch '/var/www/html/racktables/wwwroot/inc/secret.php' && chmod a=rw '/var/www/html/racktables/wwwroot/inc/secret.php'"


Step:4
docker exec -it racktables_app_1 sh -c "chown www-data:nogroup '/var/www/html/racktables/wwwroot/inc/secret.php' && chmod 440 '/var/www/html/racktables/wwwroot/inc/secret.php'"

Step:5 Persistant Racktables data
mkdir /racktables_data/
docker cp racktables_app_1:/var/www/html/racktables/wwwroot/inc/secret.php ./racktables_data/

Step:6 : Comment out volumes from docker-composer file for Persitant secret.php file after container down or stop

vim docker-compose.yml

volumes:
      - ./racktables_data/secret.php:/var/www/html/racktables/wwwroot/inc/secret.php


docker-compose down
docker-compose up -d
