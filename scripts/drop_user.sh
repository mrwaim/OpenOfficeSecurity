#/bin/sh
# Usage drop_user.sh [username|root with no password]
# Drops the user in .env

dir=`dirname $0`
if [ -e "$dir/../.env" ]; then
    eval $(cat $dir/../.env | sed 's/^/export /')
    echo "resetting $DB_HOST"
else
    echo ".env not found" >&2
    exit 1
fi

user='root'
p=''

if [ -z "$1" ]; then
    echo "using $user"
else
    user=$1
    p=" -p "
    echo "using $user"
fi

command="mysql -u $user $p -e \"DROP USER '$DB_USERNAME'@'localhost';\"";
echo $command
if ! eval $command; then
    echo "mysql failed" >&2
    exit 1
fi
