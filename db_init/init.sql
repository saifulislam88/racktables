CREATE DATABASE IF NOT EXISTS racktables CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS 'racktables_user'@'%' IDENTIFIED BY 'tktpracktables#28';
GRANT ALL PRIVILEGES ON racktables.* TO 'racktables_user'@'%';
FLUSH PRIVILEGES;
