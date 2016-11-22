# Ghost + Nginx + Lets Encrypt (production ready)

![ghost.png](https://github.com/gregbkr/ghost-nginx-ssl-docker/raw/master/ghost.png)

An easy setup to deploy quickly your blogging platform:
- Ghost: very easy way to publish your blog (straight writing in a web page and no coding), could get some nice templates for free.
- docker-compose: portable and easy to deploy, running in one command. 
- Nginx: for proxy and easy/free SSL certificate with LetsEncrypt.

Notes: 
- Ghost official docker image for dev is working great out of the box. But for production, I couldn't find other way than create a quick build for adding the config.json for ghost (probably because of perm issue as the image is not running as root, which is great for a web-front). With this workaround you still control the setup.

### 1. Prerequisit:
- Ubuntu like OS
- docker & docker-compose
- a DNS (ec.satoshi.tech in this example) pointing to your server IP

### 2. Build and run

Copy code from repo:

    git clone https://github.com/gregbkr/ghost-nginx-ssl-docker blog && cd blog

Use lets encrypt to get the certificate (replace domain and email with your own)

    docker run -it --rm -p 443:443 -p 80:80 --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" quay.io/letsencrypt/letsencrypt:latest certonly --standalone --domain ec.satoshi.tech --email gregbkr@outlook.com --quiet --noninteractive --rsa-key-size 4096 --agree-tos --standalone-supported-challenges http-01
    # --force-renewal   <-- add this flat to force renew a way before expiration  

Edit configs with your settings:

    nano nginx/blog.conf  <-- url & email
    nano ghost/config.js  <-- server_name
    nano docker-compose.yml  <-- your cert name

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
00 12 * * * /bin/bash -c "docker stop blog_ghost_1 && tar -zcvf /root/backup/ghost/ghost-$(date +\%A).tar.gz -C /var/lib/docker/volumes/blog_ghost/_data/ . && docker start blog_ghost_1"

# Backup Ghost Blog: weely, monday at 01:00
00 01 * * 1 /bin/bash -c "docker stop blog_ghost_1 && tar -zcvf /root/backup/ghost/ghost-$(date -I).tar.gz -C /var/lib/docker/volumes/blog_ghost/_data/ . && docker start blog_ghost_1"
```
