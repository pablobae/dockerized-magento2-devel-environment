#!/bin/bash

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


echo "Saving project configuration..."
echo "PROJECT_NAME=${PROJECT_NAME}" > ./conf/project.conf
echo "BASE_URL=${BASE_URL}" >> ./conf/project.conf
echo "VERSION=${VERSION}" >> ./conf/project.conf
echo "DOCKER_SERVICE_APP"=app_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_PHP"=phpfpm_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_DB"=db_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_MAILHOG"=mailhog_${PROJECT_NAME}_m2 >> ./conf/project.conf

exit;
source ./conf/project.conf


### UPDATE /etc/hosts
echo "Write your system password to add ${BASE_URL} entry to /etc/hosts..."
echo "127.0.0.1 ::1 ${BASE_URL}" | sudo tee -a /etc/hosts

echo "Configuring docker-compose project file..."
cp ./conf/base.docker-compose.yml ./docker-compose.yml
sed -i '' "s/PROJECTNAME/${PROJECT_NAME}/g" ./docker-compose.yml

echo "Starting docker services..."
docker-compose up -d
sleep 5 #Ensure containers are loaded

echo "Creating composer magento 2 project..."
bin/cli  composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${VERSION} .

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
sed -i '' "s/#      - \.\/src/      - \.\/src/g" ./docker-compose.yml

docker-compose up -d

echo "Docker developent environment setup complete."
echo "You may now access your Magento instance at https://${BASE_URL}/"
