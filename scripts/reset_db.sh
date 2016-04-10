#/bin/sh
# Usage reset_db.h

dir=`dirname $0`
if [ -e "$dir/../.env" ]; then
    eval $(cat $dir/../.env | sed 's/^/export /')
    echo "resetting $DB_HOST"
else
    echo ".env not found" >&2
    exit 1
fi

user=$DB_USERNAME
p="-p$DB_PASSWORD"

result=$(mysql -u $user $p -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$DB_DATABASE'")
if [ -z "$result" ];
    then
    echo "$DB_DATABASE does not exists";
else
    echo "$DB_DATABASE exists, dropping";

    command="mysql -u $user $p -e \"drop database $DB_DATABASE;\""
    echo $command
    if ! eval $command; then
        echo "mysql failed" >&2
        exit 1
    fi
fi

command="mysql -u $user $p -e \"create database $DB_DATABASE;\""
echo $command
if ! eval $command; then
    echo "mysql failed" >&2
    exit 1
fi

echo 'composer dump-autoload'
composer dump-autoload

echo 'php artisan migrate'
php artisan migrate

echo 'php artisan -v db:seed'
php artisan -v db:seed

echo 'php artisan -vvv ide-helper:generate'
php artisan -vvv ide-helper:generate

echo 'php artisan -vvv ide-helper:models --write'
php artisan -vvv ide-helper:models --write
