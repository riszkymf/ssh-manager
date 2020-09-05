# ssh-manager
Manage ssh collection

## Usage
Usage:
	ssh-manage <command> [options]

Command:
	list		list all available ssh server
	create		create new ssh server
	rm		delete ssh server
	update		update ssh server
	connect		connect to ssh server


Usage:
	ssh-manage create [options]

Options:
	-a --alias	Create Alias for Server
	-t --target	IP of SSH Server
	-f --file	SSH Key
	-u --user	SSH Username
	-p --pass	SSH Password

Usage:
	ssh-manage update

