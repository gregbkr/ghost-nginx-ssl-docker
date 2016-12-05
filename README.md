# Ghost + Nginx + Lets Encrypt (production ready)

![ghost.png](https://github.com/gregbkr/ghost-nginx-ssl-docker/raw/master/ghost-blog-letsencrypt.PNG)

An easy setup to deploy quickly your blogging platform:
- Ghost: very easy way to publish your blog (straight writing in a web page and no coding), could get some nice templates for free.
- docker-compose: portable and easy to deploy, running in one command. 
- Nginx: for proxy and easy/free SSL certificate with LetsEncrypt.

Notes: 
- Ghost official docker image for dev is working great out of the box. But for production, I couldn't find other way than create a quick build for adding the config.json for ghost (probably because of perm issue as the image is not running as root, which is great for a web-front). With this workaround you still control the setup.

More info: you can find an overview of that setup on my blog: https://greg.satoshi.tech/

### 1. Prerequisit:
- Ubuntu like OS
- docker & docker-compose
- a DNS (ec.satoshi.tech in this example) pointing to your server IP

### 2. Build and run

Copy code from repo

    git clone https://github.com/gregbkr/ghost-nginx-ssl-docker blog && cd blog

Setup SSL

    mkdir -p /etc/ssl/private /etc/ssl/certs
    openssl dhparam -out /etc/ssl/private/dhparams_4096.pem 4096     <-- Diffie Hellman Key Exchange: to improve security (this will take a while to generate)

Use lets encrypt to get the certificate (replace domain and email with your own)

    docker run -it --rm -p 443:443 -p 80:80 --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" quay.io/letsencrypt/letsencrypt:latest certonly --standalone --domain ec.satoshi.tech --email gregbkr@outlook.com --quiet --noninteractive --rsa-key-size 4096 --agree-tos --standalone-supported-challenges http-01

Or you can import your own certificate in the folder below:

   /etc/ssl/certs/your_domain.crt
   /etc/ssl/private/your_domain.key
    
Or create a selfsigned for test purpose:

    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt 
   
Edit configs with your settings:

    nano ghost/config.js <-- url
    nano nginx/blog.conf  <-- server_name & ssl_certificate & ssl_certificate_key

Run docker

    docker-compose up -d --build

### 3. Templates

My blog use the great willow free templates: https://raivis.com/willow-free-responsive-minimalist-ghost-blog-theme/ 

You can install the template throught GUI /setting/general) or in command line below:

Get a template

    git clone https://github.com/raivis-vitols/ghost-theme-willow templates/willow

Copy in ghost & restart
 
    docker cp templates/willow blog_ghost_1:/var/lib/ghost/themes/

Now template Willow is available in settings/general

You can edit the template via the GUI ghost except for the social promo links where you need to edit in the code:

     nano /var/lib/docker/volumes/blog_ghost/_data/content/themes/willow/partials/sidebar.hbs file.

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

### 5. LetsEncrypt

LetsEncrypt give you for free a certificate valid for 3 months. Many company migrated to this open CA because of price and security. The only way you can get a certificate for a domain is if this domain targets the ip where you run the command. So it means that you control the DNS and the server, that's only what we need to be sure the certificate could be delivered.

To update your certificate, you can do manually:

    docker-compose stop
    docker run -it --rm -p 443:443 -p 80:80 --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" quay.io/letsencrypt/letsencrypt:latest certonly --standalone --domain ec.satoshi.tech --email gregbkr@outlook.com --quiet --noninteractive --rsa-key-size 4096 --agree-tos --standalone-supported-challenges http-01
    docker-compose up -d --build

Or a script in a crontab.

The email you registered the certificate will be warn few weeks before the vertification will expired.

To force renew, a way before the expiration date, use the flag: --force-renewal
