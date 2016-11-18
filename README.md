# Ghost + Nginx + Lets Encrypt (production ready)

### 1. Prerequisit:
- ubuntu
- docker & docker-compose
- a DNS (ec.satoshi.tech in this example) pointing to your server IP

### 2. Build and run

Copy code from repo:

    git clone https://github.com/gregbkr/ghost-nginx-docker blog

Use lets encrypt to get the certificate (replace domain and email with your own)

    docker run -it --rm -p 443:443 -p 80:80 --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" quay.io/letsencrypt/letsencrypt:latest certonly --standalone --domain ec.satoshi.tech --email gregbkr@outlook.com --quiet --noninteractive --rsa-key-size 4096 --agree-tos --standalone-supported-challenges http-01
    # --force-renewal   <-- add this flat to force renew a way before expiration  

Edit configs with your settings:

    nano nginx/blog.conf  <-- url & email
    nano ghost/config.js  <-- server_name

Run docker

    docker-compose up -d --build


### 3. Templates

Throught GUI or in command line below:

Get a template

    git clone https://github.com/phongtruongg/Cle templates/Cle

Copy in ghost & restart
 
    docker cp templates/Cle blog_ghost_1:/var/lib/ghost/themes/

Now template Cle is available in settings/general


### 4. Backup and restore

We just need to backup the folder /var/lib/ghost while the ghost container is stopped (for data persistency).

With script:

    scripts/backup.sh

With crontab

```
# Backup Ghost Blog: daily at 12:00 (noon)
23 14 * * * /bin/bash -c "docker stop blog_ghost_1 && tar -zcvf /root/backup/ghost/ghost-$(date +\%A).tar.gz -C /var/lib/docker/volumes/blog_ghost/_data/ . && docker start blog_ghost_1"

# Backup Ghost Blog: weely, monday at 01:00
26 14 * * * /bin/bash -c "docker stop blog_ghost_1 && tar -zcvf /root/backup/ghost/ghost-$(date -I).tar.gz -C /var/lib/docker/volumes/blog_ghost/_data/ . && docker start blog_ghost_1"
```
