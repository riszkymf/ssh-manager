#!/bin/bash

COMMAND=$1
CONFIG_DIR="$HOME/.ssh_manage"

typeset -A ARGS

print_usage(){
    case $1 in

    "create")
    message='''Usage:
	ssh-manage create [options]
Options:
	-a		Create Alias for Server
	-t		IP of SSH Server
	-f		SSH Key
	-u		SSH Username
	-p		SSH Password
''';;
    "update")
    message='''Usage:
	ssh-manage update SSH_ALIAs [ssh]
Options:
	-a		New Alias for SSH
	-t		New IP Target for SSH
	-f		New Key for SSH
	-u		New User for SSH
''';;
    "rm")
    message='''Usage:
	ssh-manage rm
Options:
	-a		Alias of SSH that will be removed
''';;
    "connect")
    message='''Usage:
	ssh-manage connect SSH_ALIAS
''';;
    *)
message="Usage:
	ssh-manage <command> [options]
Command:
	list		list all available ssh server
	create		create new ssh server
	rm			delete ssh server
	update		update ssh server
	connect		connect to ssh server
";;
esac
cat << EOF 
$message
EOF
exit 0
}

check_directory(){
	[ -d "$1" ] && return || mkdir $1;
}


check_command(){
    commands="create update rm connect list";
    [[ $commands =~  (^| )$1($| ) ]] &&  return || print_usage $1;
}

get_variables(){
	. $CONFIG_DIR/$1;
	
	ARGS=(
		[SSH_ALIAS]=$SSH_ALIAS
		[SSH_IP]=$SSH_IP
		[SSH_USER]=$SSH_USER
		[SSH_FILE_KEY]=$SSH_FILE_KEY
	)
}

update_config(){

	DUMP_LOCATION="$CONFIG_DIR/$1"

	cat > $DUMP_LOCATION << EOL
SSH_ALIAS=${ARGS[SSH_ALIAS]}
SSH_IP=${ARGS[SSH_IP]}
SSH_USER=${ARGS[SSH_USER]}
SSH_FILE_KEY=${ARGS[SSH_FILE_KEY]}
EOL
	
}

create_ssh(){
	alias_flag=false
	user_flag=false
	target_flag=false
	while getopts "a:t:f:u:" option; do
	  case $option in
	    a)
		  MY_SSH_ALIAS="$OPTARG";
		  alias_flag=true
		  ;;
		t)
		  MY_SSH_TARGET="$OPTARG"
		  target_flag=true
		  ;;
		f)
		  MY_FILE_KEY="$OPTARG"
		  ;;
		u)
		  MY_SSH_USER="$OPTARG"
		  user_flag=true
		  ;;
		\?) 
		  print_usage create
		  ;;
	  esac
	done
	shift $((OPTIND -1))

	if ! $target_flag && ! $alias_flag && ! $user_flag
	then
		echo "Missing IP Target/SSH Name/Username !"
		print_usage create
	fi



	DUMP_LOCATION="$CONFIG_DIR/$MY_SSH_ALIAS";
	cat > $DUMP_LOCATION << EOL
	SSH_ALIAS=$MY_SSH_ALIAS
	SSH_IP=$MY_SSH_TARGET
	SSH_USER=$MY_SSH_USER
	SSH_FILE_KEY=$MY_FILE_KEY
EOL
}

list_ssh(){
	cd $CONFIG_DIR;
	ls -1 | grep -Fv .
}

update_ssh(){

	target_alias_flag=false;
	OLD_SSH_ALIAS=$1;

	if [[ -f $CONFIG_DIR/$OLD_SSH_ALIAS ]]; then
		shift
		get_variables $OLD_SSH_ALIAS;
	else 
		echo "SSH alias does not exist."
		echo "List available ssh using ssh-manage list"
		print_usage h;
	fi

	while getopts "a:t:f:u:" option; do
	  case $option in
	    a)
		  ARGS[SSH_ALIAS]="$OPTARG"
		  ;;
		t)
		  ARGS[SSH_IP]="$OPTARG"
		  ;;
		f)
		  ARGS[SSH_FILE_KEY]="$OPTARG"
		  ;;
		u)
		  ARGS[SSH_USER]="$OPTARG"
		  ;;
		\?) 
		  print_usage update
		  ;;
	  esac
	done
	shift $((OPTIND -1))
	update_config $OLD_SSH_ALIAS
	
}

ssh_connect(){
if [[ -f $CONFIG_DIR/$1 ]]; then
	get_variables $1;
else 
	echo "SSH alias does not exist."
	echo "List available ssh using ssh-manage list"
	print_usage h;
fi

if [[ -z "${ARGS[SSH_FILE_KEY]}" ]]; then
	keycmd=""
else
	keyfile=`realpath ${ARGS[SSH_FILE_KEY]}`
	keycmd="-i $keyfile "
fi

ssh_user=${ARGS[SSH_USER]}
ssh_target=${ARGS[SSH_IP]}

command="ssh $keycmd $ssh_user@$ssh_target"
eval $command;
}




check_command $COMMAND;
shift;


case "$COMMAND" in

	create)
		create_ssh "$@";;
	list)
		list_ssh;;
	update)
		update_ssh "$@";;
	rm)
		rm $CONFIG_DIR/$1;;
	connect)
		ssh_connect $1
	esac

