# Dockerized Magento 2 devel environment

Docker environment for Magento 2 projects development with **PHPFPM**, **Percona**, **Nginx** and **Mailhog**.


## Motivation

This project aims to offer a quick and easy solution for preparing Magento local environments for developing.

## Features included:
* **one-command** installation
* Supported OS: **Mac**, **Windows WSL**, **Ubuntu** and **Debian**  
* Magento 2 version configurable
* Multi-project: docker service names are created dynamically by project
* Xdebug ready
* Docker mounted points optimization
* Sync data from production and test server included


## Download

Clone this repo at your desired folder:

```git clone git@github.com:pablobae/dockerized-magento2-devel-environment.git .```


## Configuration
Credentials for the database server are stored at **conf** > **env** > **db.env**, and **Magento** credentials and others install parameters are stored at **conf** > **magento** > **setup_config**. 

In both cases, you can change the values as you wish, but these changes will only be applied before running the installation command.


## Installation
 
The installation process is automatic and includes the composer Magento 2 project creation of, the generation and installation of SSL certificates, the creation of images for Docker and other necessary steps to be able to run the environment.


To run a default installation execute the following command:

```bash create-project.sh --project=PROJECT_NAME --domain=LOCAL_URL --version=MAGENTO_2_VERSION```


Example:

```bash create-project.sh --project=myproject --domain=myproject.local --version=2.3.6-p1```


### Composer Authentication

During the installation process, composer will request you to provide your **Magento public and private keys**: write the username and password values with your Magento public and private keys, respectively. 
More info in [Magento official documentation][http://devdocs.magento.com/guides/v2.0/install-gde/prereq/connect-auth.html].


### SSL generation and system import

The installation process includes generating a self-signed cert to be used with the domain and its CA cert. To avoid system security warning, the CA cert is imported to your System Keychain and you will be asked for your password to do this.


### Docker mounted points and docker performance improvement
By the default all magento document root is mounted:

```
src : /var/www/html
```

This can be changed easily to improve Docker performance on Windows and Mac with these steps:

Run **bin/dockercomposeoverride** to generate a *docker-compose.override.yml* file
```
bin/dockercomposeoverride
```
Now you can edit that file to mount your desired folders and files or you can run **bin/configperformance** to configure automatically that file to include the following mounted folders and files:

```
src/app : /var/www/html/app
src/vendor : /var/www/html/vendor
```

Finally, use **bin/performance** command to enable your changes
```
bin/performance on
```

If you want disable your performance changes run
```
bin/performance off
```

You can add or remove them editing the **docker-composer.yml** file generated during the **create-project.sh** execution.

### Quick commands included
You can find a large list of useful command on **bin** folder, including:
* **bin/bash**: open bash shell container
* **bin/cli**: to execute commands inside the container
* **bin/copyfromcontainer**: copy files from container to host (useful to copy files/directories not mounted)
* **bin/copytocontainer**: copy files from host to container (useful to copy files/directories not mounted)
* **bin/xdebug**: enable or disable xdebug. By default is disabled.
* **bin/composer**: to run composer commands inside the container
* **bin/magento**: to run magento 2 cli inside the container
* **bin/databaseimport**: to import database
* **bin/sync**: to syncronyze local database with remote database
* **bin/clone**: to clone data from githubrepository
* ...

You can get detailed information of each command and how to use it running the command with the **--help** option:
```
bin/bash --help
```

## ChangeLog
[CHANGELOG.md](CHANGELOG.md)


### TODO
* Add ElasticSearch
* PHPSTORM integration
* PHP Mess detector & PHPCs

## Developers

* [Pablo Baenas](https://github.com/pablobae)

##### INSPIRATION
Project inspired on https://github.com/markshust/docker-magento

Licence
-------
[GNU General Public License, version 3 (GPLv3)](http://opensource.org/licenses/gpl-3.0)
