### racktables
RackTables is a nifty and robust solution for datacenter and server room asset management. It helps document hardware assets, network addresses, space in racks, networks configuration and much much more!



docker-compose build
docker-compose up -d --build
docker-compose down


docker exec -it racktables_app_1 sh -c "touch '/var/www/html/racktables/wwwroot/inc/secret.php' && chmod a=rw '/var/www/html/racktables/wwwroot/inc/secret.php'"
docker exec -it racktables_app_1 sh -c "chown www-data:nogroup '/var/www/html/racktables/wwwroot/inc/secret.php' && chmod 440 '/var/www/html/racktables/wwwroot/inc/secret.php'"
