# Phorge

* A Simple Dockerized Phorge based on Debian 11 Bullseye Slim
* [Phorge](https://we.phorge.it) is an Open Source, community driven platform for collaborating, managing, organizing and reviewing software development projects.
* M Sulchan Darmawan <bleketux@gmail.com>

## Initial Installation

* Clone this repository and prepare docker-compose

```
cd phorge-docker/
cp docker-compose.yml.dist docker-compose.yml
```

* Edit port and mysql root password as needed

```
vi docker-compose.yml
```

* Edit phabricator local configuration
* clusters.mailers: change user and password with your gmail, for sending notification purpose
* phabricator.base-uri: change with your phabricator domain/ip-address
* mysql.pass: change password with the same as in docker-compose above

```
cd conf/
cp local.json.dist local.json
vi local.json
cd ..
```

* Build and run

```
docker compose build
docker compose up -d
docker compose logs -f
docker exec mcphorge ./bin/storage upgrade --force
docker exec mcphorge ./bin/phd start
docker exec --user="www-data" mcphorge ./bin/aphlict start
```

* Open browser, create administrator and set authentication method

```
http://domain-or-ipaddress/auth
```

* Lock authentication

```
docker exec mcphorge ./bin/auth lock
```

## Maintenance

* Upgrading (don't forget to backup first)

```
docker compose down
docker compose build --no-cache
docker compose up -d
# optionally restore from last backup on this step (see backup and restore)
docker exec mcphorge ./bin/storage upgrade --force
docker exec mcphorge ./bin/phd start
docker exec --user="www-data" mcphorge ./bin/aphlict start
```

## Backup and Restore

* Backup

```
docker exec -i mcphorge-db mysqldump -uroot -p --all-databases | gzip > latest-mysql-phorge.sql.gz
tar -czvf latest-repo-phorge.tar.gz -C /path/to/root/phorge/volume repo
```

* Restore

```
gunzip -c ./latest-mysql-phorge.sql.gz | docker exec -i mcphorge-db mysql -uroot -pyourpassword
sudo mv repo repo-backup && sudo tar -xzvf latest-repo-phorge.tar.gz
```
