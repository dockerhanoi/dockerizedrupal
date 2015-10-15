#!/bin/bash
set -e

# wait database up done
WAIT_TIME=10

#------------------------------ GET CONFIG -----------------------------------
DRUPAL_PROFILE=${DRUPAL_PROFILE:-minimal}
DRUPAL_SITE_NAME=${DRUPAL_SITE_NAME:-Hello}
DRUPAL_USER=${DRUPAL_USER:-admin}
DRUPAL_PASSWORD=${DRUPAL_PASSWORD:-admin}
DRUPAL_USER_EMAIL=${DRUPAL_USER_EMAIL:-admin@example.com}

DB_TYPE=${DB_TYPE:-}
DB_HOST=${DB_HOST:-}
DB_PORT=${DB_PORT:-}
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}
DB_POOL=${DB_POOL:-10}
DB_TABLE_PREFIX=${DB_TABLE_PREFIX:-d7_}
DB_PROTO=${DB_PROTO:-}

# is a mysql or postgresql database linked?
# requires that the mysql or postgresql containers have exposed
# port 3306 and 5432 respectively.
if [[ -n ${MYSQL_PORT_3306_TCP_ADDR} ]]; then
  DB_TYPE=${DB_TYPE:-mysql}
  # DB_HOST=${DB_HOST:-${MYSQL_PORT_3306_TCP_ADDR}}
  DB_HOST=${DB_HOST:-mysql}
  DB_PORT=${DB_PORT:-${MYSQL_PORT_3306_TCP_PORT}}

  # support for linked official mysql image
  DB_USER=${DB_USER:-${MYSQL_ENV_MYSQL_USER}}
  DB_PASS=${DB_PASS:-${MYSQL_ENV_MYSQL_PASSWORD}}
  DB_NAME=${DB_NAME:-${MYSQL_ENV_MYSQL_DATABASE}}
  DB_PROTO=${DB_PROTO:-mysql}
elif [[ -n ${POSTGRESQL_PORT_5432_TCP_ADDR} ]]; then
  DB_TYPE=${DB_TYPE:-postgres}
  # DB_HOST=${DB_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
  DB_HOST=${DB_HOST:-postgresql}
  DB_PORT=${DB_PORT:-${POSTGRESQL_PORT_5432_TCP_PORT}}

  # support for linked official postgres image
  DB_USER=${DB_USER:-${POSTGRESQL_ENV_POSTGRES_USER}}
  DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_POSTGRES_PASSWORD}}
  DB_NAME=${DB_NAME:-${DB_USER}}
  DB_PROTO=${DB_PROTO:-pgsql}
fi

if [[ -z ${DB_HOST} ]]; then
  echo "ERROR: "
  echo "  Please configure the database connection."
  echo "  Refer https://hub.docker.com/r/tranhuucuong91/drupal/ for more information."
  echo "  Cannot continue without a database. Aborting..."
  exit 1
fi

# DB_TYPE defaults to mysql
DB_TYPE=${DB_TYPE:-mysql}

# use default port number if it is still not set
case ${DB_TYPE} in
  mysql) DB_PORT=${DB_PORT:-3306} DB_PROTO=${DB_PROTO:-mysql};;
  postgres) DB_PORT=${DB_PORT:-5432} DB_PROTO=${DB_PROTO:-pgsql};;
  *)
    echo "ERROR: "
    echo "  Please specify the database type in use via the DB_TYPE configuration option."
    echo "  Accepted values are \"postgres\" or \"mysql\". Aborting..."
    exit 1
    ;;
esac

# set default user and database
DB_USER=${DB_USER:-root}
DB_NAME=${DB_NAME:-drupal}

#-----------------------------------------------------------------------------

if [ "$1" = 'apache2-foreground' ]; then
    if [ ! -f /var/www/html/sites/default/settings.php ]; then
        sleep ${WAIT_TIME}

        cd /var/www/html/
        echo "drush install new site"

        drush --y si ${DRUPAL_PROFILE} \
        --db-url=${DB_PROTO}://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME} \
        --db-prefix=${DB_TABLE_PREFIX} \
        --clean-url=0 \
        --site-name=${DRUPAL_SITE_NAME} \
        --account-name=${DRUPAL_USER} \
        --account-pass=${DRUPAL_PASSWORD} \
        --account-mail=${DRUPAL_USER_EMAIL} || true
    fi

    source /etc/apache2/envvars

    # Apache gets grumpy about PID files pre-existing
    rm -f /var/run/apache2/apache2.pid
    exec apache2 -DFOREGROUND
fi

exec "$@"

