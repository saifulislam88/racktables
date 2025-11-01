### racktables
RackTables is a nifty and robust solution for datacenter and server room asset management. It helps document hardware assets, network addresses, space in racks, networks configuration and much much more!

## 📁 Project Structure
Your working directory should look like this:

```
racktables/
├── docker-compose.yml
├── Dockerfile
├── Dockerfile.db
├── db_data/                    # Persistent MySQL data
├── db_init/                    # Optional: DB initialization scripts
│   └── init.sql               
├── racktables_data/            # To persist secret.php
│   └── secret.php
└── README.md
```

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



# ⚙️ Step 1: Clone and Build the Project

```bash
git clone https://github.com/saifulislam88/racktables.git
cd racktables
docker-compose build
docker-compose up -d --build
docker-compose logs -f
docker-compose ps
```

This will build and start two containers:
- `app` → RackTables PHP + Nginx container
- `db` → MariaDB container

---

## 🌐 Step 2: Access the RackTables Installer

Open the installer in your browser:
```
http://<server-ip>/
```
Example:
```
http://172.17.6.163/
```

Follow the setup wizard until you reach the message:
> “The /var/www/html/racktables/wwwroot/inc/secret.php file is not writable by web-server.”

---

## 🧩 Step 3: Create and Grant Permissions for secret.php

Run this command inside the `app` container:
```bash
docker exec -it racktables_app_1 sh -c "touch '/var/www/html/racktables/wwwroot/inc/secret.php' && chmod a=rw '/var/www/html/racktables/wwwroot/inc/secret.php'"
```

This creates the required configuration file and makes it writable by the web server.

---

## 🔐 Step 4: Secure the secret.php File

After completing installation (once credentials are written), lock down file permissions:
```bash
docker exec -it racktables_app_1 sh -c "chown www-data:nogroup '/var/www/html/racktables/wwwroot/inc/secret.php' && chmod 440 '/var/www/html/racktables/wwwroot/inc/secret.php'"
```

This ensures only the web server can read it.

---

## 💾 Step 5: Persist the secret.php File

Create a local folder to hold the persistent file:
```bash
mkdir -p racktables_data
docker cp racktables_app_1:/var/www/html/racktables/wwwroot/inc/secret.php ./racktables_data/
```

Now your secret file is safe on the host system.

---

## 🧱 Step 6: Enable Persistence in docker-compose.yml

Open the `docker-compose.yml` file and **add this volume mapping** under the `app` service:

```yaml
volumes:
  - ./racktables_data/secret.php:/var/www/html/racktables/wwwroot/inc/secret.php
```

Then restart your containers to apply:
```bash
docker-compose down
docker-compose up -d
```

✅ Now, even if you stop, rebuild, or restart containers, your `secret.php` file will remain persistent.

---

## 🧩 docker-compose.yml Example

```yaml
services:
  db:
    build:
      context: .
      dockerfile: Dockerfile.db
    environment:
      MYSQL_ROOT_PASSWORD: tktpracktables#28
      MYSQL_DATABASE: racktables
      MYSQL_USER: racktables_user
      MYSQL_PASSWORD: tktpracktables#28
    volumes:
      - ./db_data:/var/lib/mysql
      - ./db_init:/docker-entrypoint-initdb.d
    networks:
      - racktables_network

  app:
    build: .
    ports:
      - "80:80"
    environment:
      RACKTABLES_DB_HOST: db
      RACKTABLES_DB_USERNAME: racktables_user
      RACKTABLES_DB_PASSWORD: tktpracktables#28
      RACKTABLES_DB_NAME: racktables
    depends_on:
      - db
    networks:
      - racktables_network
    volumes:
      - ./racktables_data/secret.php:/var/www/html/racktables/wwwroot/inc/secret.php

networks:
  racktables_network:
    driver: bridge
```

---

## 🧠 Best Practices

- Always persist:
  - `db_data/` (MariaDB data)
  - `racktables_data/secret.php`
- Never persist `/var/www/html/racktables/` entirely — only configuration files.
- After installation, lock `secret.php` permissions (`chmod 440`).
- For upgrades, backup both:
  - `db_data/`
  - `racktables_data/secret.php`
