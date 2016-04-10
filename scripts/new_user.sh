#/bin/sh
# Usage new_user.sh [username|root with no password]
# Creates the user in .env

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

command="mysql -u $user $p -e \"CREATE USER '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD';\"";
echo $command
if ! eval $command; then
    echo "mysql failed - ignoring" >&2
    #exit 1
fi

command="mysql -u $user $p -e \"grant Select,Update,Insert,Create,Delete,Drop,Alter,References on $DB_DATABASE.* to '$DB_USERNAME'@'localhost' identified by '$DB_PASSWORD'\";";
echo $command
if ! eval $command; then
    echo "mysql failed" >&2
    exit 1
fi

command="mysql -u $user $p -e \"FLUSH PRIVILEGES;\"";
echo $command
if ! eval $command; then
    echo "mysql failed" >&2
    exit 1
fi
