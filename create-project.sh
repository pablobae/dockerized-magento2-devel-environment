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

source ./conf/project.conf

echo "Script customizations by OS (${OS_MAC})..."
case $OS in
  $OS_WSL)
    SED_FIRST_PARAMETER=
  ;;
  *)
    SED_FIRST_PARAMETER="''"
  ;;
esac

echo "SED_FIRST_PARAMETER"=${SED_FIRST_PARAMETER} >> ./conf/project.conf


## UPDATE /etc/hosts
echo "Write your system password to add ${BASE_URL} entry to /etc/hosts..."
echo "127.0.0.1 ::1 ${BASE_URL}" | sudo tee -a /etc/hosts

echo "Configuring docker-compose project file..."
cp ./conf/base.docker-compose.yml ./docker-compose.yml
sed -i $SED_FIRST_PARAMETER "s/PROJECTNAME/${PROJECT_NAME}/g" $PROJECT_PATH/docker-compose.yml
if test -f $PROJECT_PATH/docker-compose.yml''
then
  rm -f $PROJECT_PATH/docker-compose.yml\'\'
fi

echo "Starting docker services..."
docker-compose up -d
sleep 5 #Ensure containers are loaded

echo "Creating composer magento 2 project..."
bin/cli  composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${VERSION} .

echo "Loading Magento and environment configuration..."
source conf/setup_magento_config
source conf/env/db.env

echo "Loading Magento and environment configuration..."
source conf/setup_magento_config
source conf/env/db.env

echo "Installing Magento..."
bin/clinotty bin/magento setup:install \
  --db-host=${DOCKER_SERVICE_DB} \
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
  --timezone=Europe/Madrid

echo "Turning on developer mode.."
bin/clinotty bin/magento deploy:mode:set developer

bin/clinotty bin/magento indexer:reindex

echo "Forcing deploy of static content to speed up initial requests..."
bin/clinotty bin/magento setup:static-content:deploy -f

echo "Clearing the cache to apply updates..."
bin/clinotty bin/magento cache:flush

echo "Copying files from container to host after install..."
mkdir src
bin/copyfromcontainer --all

echo "Generating SSL certificate..."
bin/setup-ssl ${BASE_URL}

echo "Configuring post install docker-compose file..."
docker-compose stop
sed -i $SED_FIRST_PARAMETER "s/#      - \.\/src:/      - \.\/src:/g" ./docker-compose.yml
sed -i $SED_FIRST_PARAMETER "s/#      - \.\/src\/nginx/      - \.\/src\/nginx/g" ./docker-compose.yml
sed -i $SED_FIRST_PARAMETER "s/#      - \.\/conf/      - \.\/conf/g" ./docker-compose.yml
sed -i $SED_FIRST_PARAMETER "s/      - appdata/#      - appdata/g" ./docker-compose.yml

if test -f $PROJECT_PATH/docker-compose.yml\'\'
then
  rm -f $PROJECT_PATH/docker-compose.yml\'\'
fi
docker-compose up -d

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
    SED_FIRST_PARAMETER="''"
  ;;
esac

echo "You may now access your Magento instance at https://${BASE_URL}/"
echo "Backend information:"
echo "- url: https://${BASE_URL}/${ADMIN_URL}"
echo "- admin user: ${ADMIN_USER}"
echo "- admin password: ${ADMIN_PASSWORD}"
echo "- admin email: ${ADMIN_EMAIL}"


