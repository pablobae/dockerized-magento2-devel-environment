# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Version](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
* Added support for xDebug v3+
* Bugfix: docker compose yml configuration files not found when bin commands are not called from the environment folder.

### Changed
### Removed

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

### Removed

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
