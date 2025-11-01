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

## ⚙️ Step 1: Clone and Build the Project

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

<img width="500" height="350" alt="RackTables Setup Step 1" src="https://github.com/user-attachments/assets/bb7c2f13-dd82-4650-8a02-d422737a0e59" />

---

<img width="500" height="285" alt="RackTables Database Config" src="https://github.com/user-attachments/assets/ec5cdea1-b4a8-4c9f-806a-5c63f6362028" />

---

<img width="500" height="481" alt="RackTables Login Page" src="https://github.com/user-attachments/assets/310a2ecf-3ee6-4d4d-b4dc-e8cad655aaa3" />

---


## 🧩 Step 3: Create and Grant Permissions for secret.php

<img width="500" height="355" alt="{D4406BC0-7141-4710-BE6F-CEE296021932}" src="https://github.com/user-attachments/assets/de18af3d-1b9b-4bc9-bb3e-e570ad1bf4b3" />

Run this command inside the `app` container:
```bash
docker exec -it racktables_app_1 sh -c "touch '/var/www/html/racktables/wwwroot/inc/secret.php' && chmod a=rw '/var/www/html/racktables/wwwroot/inc/secret.php'"
```
<img width="500" height="506" alt="{32BDA086-6E18-4ACC-9C3D-5B31B55A5385}" src="https://github.com/user-attachments/assets/54524513-20ce-439b-b636-cdbbc1fd773e" />

This creates the required configuration file and makes it writable by the web server.

---

## 🔐 Step 4: Secure the secret.php File

After completing installation (once credentials are written), lock down file permissions:

<img width="500" height="385" alt="{4A2A9E62-B818-497B-BAE7-0662D5641E4D}" src="https://github.com/user-attachments/assets/cfb41a7d-23fa-44d5-b054-c437d5bd9c1f" />


```bash
docker exec -it racktables_app_1 sh -c "chown www-data:nogroup '/var/www/html/racktables/wwwroot/inc/secret.php'"
docker exec -it racktables_app_1 sh -c "chmod 440 '/var/www/html/racktables/wwwroot/inc/secret.php'"
```

This ensures only the web server can read it.
<img width="500" height="296" alt="{33AF0405-F0C3-4B24-B0E9-D25F43155F79}" src="https://github.com/user-attachments/assets/5fb69b02-a9c5-47f2-b7af-b95326852cb7" />

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
