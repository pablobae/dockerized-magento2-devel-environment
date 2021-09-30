#!/bin/bash

OS_WSL="wsl"
OS_UBUNTU="ubuntu"
OS_DEBIAN="debian"
OS_MAC="mac"


for i in "$@"
do
case $i in
    -v=*|--version=*)
    VERSION="${i#*=}"
    shift
    ;;
    -p=*|--project=*)
    PROJECT_NAME="${i#*=}"

    shift
    ;;
    -d=*|--domain=*)
    BASE_URL="${i#*=}"
    shift
    ;;
    *)
    ;;
esac
done

if [ -z ${VERSION} ] || [ -z ${PROJECT_NAME} ] || [ -z ${BASE_URL} ]
then
    echo "ERROR: Required arguments missing"
    echo "USE: create-project --project=EXAMPLE --domain=EXAMPLE.LOCAL --version=2.3.5"
    exit
fi

echo "Detecting OS..."
echo "OS_WSL=${OS_WSL}" > ./conf/project.conf
echo "OS_UBUNTU=${OS_UBUNTU}" >> ./conf/project.conf
echo "OS_DEBIAN=${OS_DEBIAN}" >> ./conf/project.conf
echo "OS_MAC=${OS_MAC}">> ./conf/project.conf

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  if [[ ${DISTRO} == *"Ubuntu"* ]]; then
    if uname -a | grep -q '^Linux.*icrosoft' ; then
      echo "OS=${OS_WSL}" >> ./conf/project.conf
    else
      echo "OS=${OS_UBUNTU}" >> ./conf/project.conf
    fi
  elif [[ ${DISTRO} == *"Debian"* ]]; then
      echo "OS=${OS_DEBIAN}" >> ./conf/project.conf
  else
      echo "Error: OS not detected"
      read -p "Press any key to continue ..."
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
      echo "OS=${OS_MAC}" >> ./conf/project.conf
fi

echo "Saving project configuration..."
echo "PROJECT_NAME=${PROJECT_NAME}" >> ./conf/project.conf
echo "BASE_URL=${BASE_URL}" >> ./conf/project.conf
echo "VERSION=${VERSION}" >> ./conf/project.conf
echo "DOCKER_SERVICE_APP"=app_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_PHP"=phpfpm_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_DB"=db_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_MAILHOG"=mailhog_${PROJECT_NAME}_m2 >> ./conf/project.conf
CURRENT_PATH="$(cd "$(dirname "$0")" && pwd)"
echo "PROJECT_PATH"=${CURRENT_PATH} >> ./conf/project.conf
echo "BIN_PATH"=${CURRENT_PATH}/bin >> ./conf/project.conf
echo "SRC_PATH"=${CURRENT_PATH}/src >> ./conf/project.conf
echo "CONF_PATH"=${CURRENT_PATH}/conf >> ./conf/project.conf

echo "Project environment configuration: (Check https://devdocs.magento.com/guides/v2.4/install-gde/system-requirements.html for version compatibility)"

# Composer
while true; do
  read -p "Which version of COMPOSER do you want to use 1.x [1] or 2.x [2]? [1/2]: " option
  case $option in
    1)
      COMPOSER_VERSION="1"
      break;;
    2)
      COMPOSER_VERSION="2"
      break;;
    *) echo "Please answer 1 or 2";;
  esac
done
echo "COMPOSER_VERSION=${COMPOSER_VERSION}" >> ./conf/project.conf
# Database engine
while true; do
  read -p "Choose database engine: Mysql [1] or MariaDB [2]? [1/2]: " option
  case $option in
    1)
      DATABASE_ENGINE=mysql
      while true; do
        read -p "Which version of MYSQL do you want to use 5.6 [1], 5.7 [2], or 8.0 [3]? [1/2/3]: " option
        case $option in
          1)
            DATABASE_VERSION="5.6"
            break;;
          2)
            DATABASE_VERSION="5.7"
            break;;
          3)
            DATABASE_VERSION="8.0"
            break;;
          *) echo "Please answer 1, 2 or 3";;
        esac
      done
      break;;
    2)
      DATABASE_ENGINE=mariadb
      while true; do
        read -p "Which version of MARIADB do you want to use? (10.1 [1], 10.2 [2], 10.3 [3], or 10.4 [4]) Select one: [1/2/3/4]: " option
        case $option in
          1)
            DATABASE_VERSION="10.1"
            break;;
          2)
            DATABASE_VERSION="10.2"
            break;;
          3)
            DATABASE_VERSION="10.3"
            break;;
          4)
            DATABASE_VERSION="10.4"
            break;;
          *) echo "Please answer 1, 2, 3 or 4";;
        esac
      done
      break;;
    *)
      echo "Please answer 1 or 2";;
  esac
done
echo "DATABASE_ENGINE=${DATABASE_ENGINE}" >> ./conf/project.conf
echo "DATABASE_VERSION=${DATABASE_VERSION}" >> ./conf/project.conf

# Elasticsearch
read -p "Do you want to use Elasticsearch? [Y/N]: " option
  case $option in
    [Yy])
      ELASTICSEARCH=yes
      DOCKER_SERVICE_ELASTICSEARCH=elasticsearch_${PROJECT_NAME}_m2
      echo "DOCKER_SERVICE_ELASTICSEARCH"=${DOCKER_SERVICE_ELASTICSEARCH} >> ./conf/project.conf
      while true; do
        read -p "Which version of ELASTICSEARCH do 5.x [1], 6.x [2], 7.6 [3], 7.7 [4], 7.9 [5] or 7.10 [6]? [1/2/3/4/5/6]: " option
        case $option in
          1)
            ELASTICSEARCH_VERSION="5-alpine"
            ELASTICSEARCH_INSTALL_OPTIONS=" --search-engine=elasticsearch5 --elasticsearch-host=${DOCKER_SERVICE_ELASTICSEARCH} --elasticsearch-port=9200"
            break;;
          2)
            ELASTICSEARCH_VERSION="6.8.18"
            ELASTICSEARCH_INSTALL_OPTIONS=" --search-engine=elasticsearch6 --elasticsearch-host=${DOCKER_SERVICE_ELASTICSEARCH} --elasticsearch-port=9200"
            break;;
          3)
            ELASTICSEARCH_VERSION="7.6.2"
            ELASTICSEARCH_INSTALL_OPTIONS=" --search-engine=elasticsearch7 --elasticsearch-host=${DOCKER_SERVICE_ELASTICSEARCH} --elasticsearch-port=9200"
            break;;
          4)
            ELASTICSEARCH_VERSION="7.7.1"
            ELASTICSEARCH_INSTALL_OPTIONS=" --search-engine=elasticsearch7 --elasticsearch-host=${DOCKER_SERVICE_ELASTICSEARCH} --elasticsearch-port=9200"
            break;;
          5)
            ELASTICSEARCH_VERSION="7.9.3"
            ELASTICSEARCH_INSTALL_OPTIONS=" --search-engine=elasticsearch7 --elasticsearch-host=${DOCKER_SERVICE_ELASTICSEARCH} --elasticsearch-port=9200"
            break;;
          6)
            ELASTICSEARCH_VERSION="7.10.1"
            ELASTICSEARCH_INSTALL_OPTIONS=" --search-engine=elasticsearch7 --elasticsearch-host=${DOCKER_SERVICE_ELASTICSEARCH} --elasticsearch-port=9200"
            break;;
          *) echo "Please answer 1, 2, 3, 4 ,5 or 6";;
        esac
      done
      echo "ELASTICSEARCH_VERSION=${ELASTICSEARCH_VERSION}" >> ./conf/project.conf
      ;;
    *)
      ELASTICSEARCH=no
  esac
echo "ELASTICSEARCH=${ELASTICSEARCH}" >> ./conf/project.conf
# PHP
while true; do
  read -p "Which version of PHP do you want to use? (7.2 [1], 7.3 [2], 7.4 [3] or 8.1 [4]). Select one [1/2/3/4]: " option
  case $option in
    1)
      PHPFPM_VERSION="7.2-fpm-buster"
      PHPFPM_DOCKER_GD_COMMAND="gd --with-freetype-dir=\/usr\/include\/ --with-jpeg-dir=\/usr\/include\/"
      break;;
    2)
      PHPFPM_VERSION="7.3-fpm-buster"
      PHPFPM_DOCKER_GD_COMMAND="gd --with-freetype-dir=\/usr\/include\/ --with-jpeg-dir=\/usr\/include\/"
      break;;
    3)
      PHPFPM_VERSION="7.4-fpm-buster"
      PHPFPM_DOCKER_INSTALL_PHP74='libonig-dev procps'
      PHPFPM_DOCKER_GD_COMMAND="gd --with-freetype --with-jpeg"
      break;;
    4)
      PHPFPM_VERSION="8-fpm-buster"
      PHPFPM_DOCKER_INSTALL_PHP74='libonig-dev procps'
      PHPFPM_DOCKER_GD_COMMAND="gd --with-freetype --with-jpeg"
      break;;
    *) echo "Please answer 1, 2, 3 or 4";;
  esac
done
echo "PHPFPM_VERSION=${PHPFPM_VERSION}" >> ./conf/project.conf

source ./conf/project.conf

echo "Script customizations by OS (${OS_MAC})..."
case $OS in
  $OS_WSL)
    SED_FIRST_PARAMETER=
  ;;
  *)
    SED_FIRST_PARAMETER="_bak"
  ;;
esac

echo "SED_FIRST_PARAMETER"=${SED_FIRST_PARAMETER} >> ${PROJECT_PATH}/conf/project.conf

# UPDATE /etc/hosts
echo "Write your system password to add ${BASE_URL} entry to /etc/hosts..."
echo "127.0.0.1 ::1 ${BASE_URL}" | sudo tee -a /etc/hosts

echo "Configuring docker-compose project file..."
cp ${PROJECT_PATH}/conf/docker/compose-templates/head.docker-compose.yml ${PROJECT_PATH}/docker-compose.yml
cat ${PROJECT_PATH}/conf/docker/compose-templates/nginx.docker-compose.yml >> ${PROJECT_PATH}/docker-compose.yml
cat ${PROJECT_PATH}/conf/docker/compose-templates/php.docker-compose.yml >> ${PROJECT_PATH}/docker-compose.yml
cat ${PROJECT_PATH}/conf/docker/compose-templates/db.docker-compose.yml >> ${PROJECT_PATH}/docker-compose.yml
cat ${PROJECT_PATH}/conf/docker/compose-templates/mailhog.docker-compose.yml >> ${PROJECT_PATH}/docker-compose.yml
if [ "$ELASTICSEARCH" == "yes" ]; then
  cat ${PROJECT_PATH}/conf/docker/compose-templates/elasticsearch.docker-compose.yml >> ${PROJECT_PATH}/docker-compose.yml
fi
cat ${PROJECT_PATH}/conf/docker/compose-templates/volumes.docker-compose.yml >> ${PROJECT_PATH}/docker-compose.yml

sed -i ${SED_FIRST_PARAMETER} "s/PROJECTNAME/${PROJECT_NAME}/g" ${PROJECT_PATH}/docker-compose.yml
sed -i ${SED_FIRST_PARAMETER} "s/DATABASE_ENGINE/${DATABASE_ENGINE}/g" ${PROJECT_PATH}/docker-compose.yml
sed -i ${SED_FIRST_PARAMETER} "s/DATABASE_VERSION/${DATABASE_VERSION}/g" ${PROJECT_PATH}/docker-compose.yml
if [ "$ELASTICSEARCH" == "yes" ]; then
  sed -i ${SED_FIRST_PARAMETER} "s/ELASTICSEARCH_VERSION/${ELASTICSEARCH_VERSION}/g" ${PROJECT_PATH}/docker-compose.yml
fi

#Configuring phpfpm dockerfile
cp ./conf/docker/phpfpm/Dockerfile.template ./conf/docker/phpfpm/Dockerfile
sed -i ${SED_FIRST_PARAMETER} "s/PHPFPM_VERSION/${PHPFPM_VERSION}/g" ${PROJECT_PATH}/conf/docker/phpfpm/Dockerfile
sed -i ${SED_FIRST_PARAMETER} "s/COMPOSER_VERSION/${COMPOSER_VERSION}/g" ${PROJECT_PATH}/conf/docker/phpfpm/Dockerfile
sed -i ${SED_FIRST_PARAMETER} "s/PHPFPM_DOCKER_INSTALL_PHP74/${PHPFPM_DOCKER_INSTALL_PHP74}/g" ${PROJECT_PATH}/conf/docker/phpfpm/Dockerfile
sed -i ${SED_FIRST_PARAMETER} "s/PHPFPM_DOCKER_GD_COMMAND/${PHPFPM_DOCKER_GD_COMMAND}/g" ${PROJECT_PATH}/conf/docker/phpfpm/Dockerfile

echo "Building and starting docker services..."
docker-compose up -d --build
sleep 5 #Ensure containers are loaded

echo "Creating composer magento 2 project..."
${BIN_PATH}/cli composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${VERSION} .

echo "Loading Magento and environment configuration..."
source conf/setup_magento_config
source conf/env/db.env

echo "Loading Magento and environment configuration..."
source conf/setup_magento_config
source conf/env/db.env

echo "Installing Magento..."
MAGENTO_INSTALL_OPTIONS="--db-host=${DOCKER_SERVICE_DB} \
  --db-name=${MYSQL_DATABASE}\
  --db-user=${MYSQL_USER} \
  --db-password=${MYSQL_PASSWORD} \
  --base-url=https://${BASE_URL}/ \
  --admin-firstname=${ADMIN_FIRST_NAME} \
  --admin-lastname=${ADMIN_LAST_NAME} \
  --admin-email=${ADMIN_EMAIL} \
  --admin-user=${ADMIN_USER} \
  --admin-password=${ADMIN_PASSWORD} \
  --backend-frontname=${ADMIN_URL} \
  --language=${LANGUAGE} \
  --currency=${CURRENCY} \
  --use-rewrites=1 \
  --use-secure=1 \
  --use-secure-admin=1 \
  --timezone=${TIMEZONE} ${ELASTICSEARCH_INSTALL_OPTIONS}"

echo "bin/magento setup:install ${MAGENTO_INSTALL_OPTIONS}"
${BIN_PATH}/clinotty bin/magento setup:install ${MAGENTO_INSTALL_OPTIONS}

echo "Turning on developer mode.."
${BIN_PATH}/clinotty bin/magento deploy:mode:set developer

${BIN_PATH}/clinotty bin/magento indexer:reindex

echo "Forcing deploy of static content to speed up initial requests..."
${BIN_PATH}/clinotty bin/magento setup:static-content:deploy -f

echo "Clearing the cache to apply updates..."
${BIN_PATH}/clinotty bin/magento cache:flush

echo "Copying files from container to host after install..."
mkdir src
${BIN_PATH}/copyfromcontainer --all

echo "Generating SSL certificate..."
${BIN_PATH}/setup-ssl ${BASE_URL}

echo "Configuring post install docker-compose file..."
docker-compose stop
sed -i ${SED_FIRST_PARAMETER} "s/#      - \.\/conf/      - \.\/conf/g" ${PROJECT_PATH}/docker-compose.yml
sed -i ${SED_FIRST_PARAMETER} "s/      - appdata/#      - appdata/g" ${PROJECT_PATH}/docker-compose.yml
sed -i ${SED_FIRST_PARAMETER} "s/#      - \.\/src:/      - \.\/src:/g" ${PROJECT_PATH}/docker-compose.yml
${BIN_PATH}/start
sleep 5 #Ensure containers are loaded

cp ${SRC_PATH}/nginx.conf.sample ${SRC_PATH}/nginx.conf

#Cleaning sed files
if test -f ${PROJECT_PATH}/"docker-compose.yml_bak"
then
  rm -f ${PROJECT_PATH}/"docker-compose.yml_bak"
fi
if test -f  ${PROJECT_PATH}/conf/docker/phpfpm/"Dockerfile_bak"
then
  rm -f ${PROJECT_PATH}/conf/docker/phpfpm/"Dockerfile_bak"
fi

${BIN_PATH}/restart
echo "Docker development environment setup complete."

case $OS in
  $OS_WSL)
    echo "*** ATTENTION: last steps for WSL users ***"
    echo "1) It's not possible update the windows hosts file from WSL, so you need to add this record manually:"
    echo "   127.0.0.1 ${BASE_URL}"
    echo "   Windows hosts file should be in C:\Windows\System32\drivers\etc\hosts"
    echo "2) Installing CA on windows is not supported from WSL"
    echo "   You must import it running mmc.exe (as administrator) → Certificates (Local Computer) snap-in → Trusted Root Certificates → Import and select the rootCA.pem file that is in your current folder"
    read -p "Press any key to continue"
  ;;
  *)
  ;;
esac

echo "You may now access your Magento instance at https://${BASE_URL}/"
echo "Backend information:"
echo "- url: https://${BASE_URL}/${ADMIN_URL}"
echo "- admin user: ${ADMIN_USER}"
echo "- admin password: ${ADMIN_PASSWORD}"
echo "- admin email: ${ADMIN_EMAIL}"


