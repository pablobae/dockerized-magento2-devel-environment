# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Version](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Removed

## [1.1.4] - 05-05-2022
### Added
* Added Support for ElasticSearch 7.16
### Changed
* BugFix: Fix services information displayed after installing Magento, and command bin/describe
* Bugfix: Update auth.json generation file

## [1.1.3] - 25-02-2022
### Added
* Bugfix: Sed parameter issue on Ubuntu when creating projects.

## [1.1.2] - 14-10-2021
### Added
* Added createmagentoauthjson command
* Added describe command
### Changed
* Performance improvement in performance, fixperms and copytocontainer commands
* Updated bin commands to check if the project is configured before being executed.


## [1.1.1] - 03-10-2021
### Added
* Bugfix: Elasticsearch magento cli installation parameters not available for Magento 2.3.X
* Bugfix: Unable to connect to mailhog service from Magento  
* Feature: SampleData optionally installable during the project creation 
* Added RabbitMQ service optionally installable during the project creation

## [1.1.0] - 30-09-2021
### Added
* Added support for Magento 2.4.X
* Added ElasticSearch node support
* Added Database Engine selection: Msql or MariaDB
* Added option to select versions to be installed for PHP, MariaDB, Mysql, Composer and Elasticsearch
* Added TIMEZONE variable for configure Magento timezone 
### Changed
* Create-project script updated. Now it's possible to configure the environment: PHP version, Mysql or MariaDB version, Elasticsearch ...  

## [1.0.5] - 18-04-2021
### Added
* Added support for xDebug v3+
* Bugfix: docker compose yml configuration files not found when bin commands are not called from the environment folder.

## [1.0.4] - 06-04-2021
### Added
* Added **reset** command to restore local environment files, docker data,..
* Added **dockercomposeoverride** command: generate a docker-composer.override.yml file to override
* Added **configperformance** command: customize docker-compose.override.yml with only some folders mounted between the host and the container
* Added **performance** command: enable or disable docker-compose-override file with your customizations
* Added **importdatabase** command to import database file
* Added **sync** command to synchronize local environment (database and media) from remote servers
* Added **clone** command to import data from a github repository
* Added **--help** option to all **bin/commands** to display command information
### Changed
* Updated **start** and **stop** command to support docker-compose.override files
* Updated **create-project.sh** script to support performance command
* bin/commands issue when they are called from not project root folder

## [1.0.3] - 20-03-2021
### Removed
* Auth.json generation

## [1.0.2] - 19-03-2021
### Added
* Displaying detected OS while project creation
* Displaying backend information when sucessful install
### Changed
* Improving information for SSL generation in WSL
### Removed
* Removing comments

## [1.0.1] - 12-03-2021
### Added
* Changelog file
### Changed
* Fix OS detect on create-project script
* Update documentation
## [1.0] - 29-09-2020
* First working version
