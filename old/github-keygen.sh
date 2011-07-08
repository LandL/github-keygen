#!/bin/bash
# Copyright (C) 2011 Olivier Mengué
# https://github.com/dolmen/github-keygen
# Licence: GNU GPL v3

github_user="$1"
github_hosts="github.com gist.github.com"
key_type=${key_type:-rsa}
key_bits=${key_bits:-2048}
[ -z "$github_user" ] && { echo "usage: $0 <github_user>" >&2 ; exit 1 ; }
key_name="${key_name:-$(hostname)}"

key_file=${key_file:-~/.ssh/"id_$github_user@github"}
known_hosts_file=~/.ssh/known_hosts_github

umask 077

# Make the path absolute
if ! expr "x$key_file" : x/ >/dev/null ; then
	if [ -e "$key_file" ] || expr "x$key_file" : x..*/ >/dev/null ; then
		key_file="$PWD/$key_file"
	else
		key_file=~/.ssh/"$key_file"
	fi
fi


if [ -e "$key_file" ] ; then
	echo "Key ~/${key_file#$HOME/} already exists" >&2
	if [ ! -e "$key_file.pub" -o ! -r "$key_file.pub" ] ; then
		echo "Public key $key_file.pub is missing!" >&2
		exit 1
	fi
else
	echo Creating private key $key_file...
	ssh-keygen -t $key_type -b $key_bits -C "$key_name" -f "$key_file" || exit $?
	echo Done.
	echo
	#ssh-keygen -e -f "$key_file"
fi

for h in $github_hosts
do
	ssh-keygen -R $h 2>/dev/null
done

echo Saving Github hosts authentication keys...
# Do not hash hosts: this file is already identified as containing
# Github hosts public keys, so this would not add any security
if [ ! -e "$known_hosts_file" -o -w "$known_hosts_file" ] ; then
	# The content was generated with:
	#   ssh-keyscan -t dsa,rsa $github_hosts > "$known_hosts_file"
	cat >"$known_hosts_file" <<-EOF
	github.com ssh-dss AAAAB3NzaC1kc3MAAACBANGFW2P9xlGU3zWrymJgI/lKo//ZW2WfVtmbsUZJ5uyKArtlQOT2+WRhcg4979aFxgKdcsqAYW3/LS1T2km3jYW/vr4Uzn+dXWODVk5VlUiZ1HFOHf6s6ITcZvjvdbp6ZbpM+DuJT7Bw+h5Fx8Qt8I16oCZYmAPJRtu46o9C2zk1AAAAFQC4gdFGcSbp5Gr0Wd5Ay/jtcldMewAAAIATTgn4sY4Nem/FQE+XJlyUQptPWMem5fwOcWtSXiTKaaN0lkk2p2snz+EJvAGXGq9dTSWHyLJSM2W6ZdQDqWJ1k+cL8CARAqL+UMwF84CR0m3hj+wtVGD/J4G5kW2DBAf4/bqzP4469lT+dF2FRQ2L9JKXrCWcnhMtJUvua8dvnwAAAIB6C4nQfAA7x8oLta6tT+oCk2WQcydNsyugE8vLrHlogoWEicla6cWPk7oXSspbzUcfkjN3Qa6e74PhRkc7JdSdAlFzU3m7LMkXo1MHgkqNX8glxWNVqBSc0YRdbFdTkL0C6gtpklilhvuHQCdbgB3LBAikcRkDp+FCVkUgPC/7Rw==
	github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
	gist.github.com ssh-dss AAAAB3NzaC1kc3MAAACBANGFW2P9xlGU3zWrymJgI/lKo//ZW2WfVtmbsUZJ5uyKArtlQOT2+WRhcg4979aFxgKdcsqAYW3/LS1T2km3jYW/vr4Uzn+dXWODVk5VlUiZ1HFOHf6s6ITcZvjvdbp6ZbpM+DuJT7Bw+h5Fx8Qt8I16oCZYmAPJRtu46o9C2zk1AAAAFQC4gdFGcSbp5Gr0Wd5Ay/jtcldMewAAAIATTgn4sY4Nem/FQE+XJlyUQptPWMem5fwOcWtSXiTKaaN0lkk2p2snz+EJvAGXGq9dTSWHyLJSM2W6ZdQDqWJ1k+cL8CARAqL+UMwF84CR0m3hj+wtVGD/J4G5kW2DBAf4/bqzP4469lT+dF2FRQ2L9JKXrCWcnhMtJUvua8dvnwAAAIB6C4nQfAA7x8oLta6tT+oCk2WQcydNsyugE8vLrHlogoWEicla6cWPk7oXSspbzUcfkjN3Qa6e74PhRkc7JdSdAlFzU3m7LMkXo1MHgkqNX8glxWNVqBSc0YRdbFdTkL0C6gtpklilhvuHQCdbgB3LBAikcRkDp+FCVkUgPC/7Rw==
	gist.github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
	EOF
	echo Done.
fi
chmod u+r,u-x,og-rwx "$known_hosts_file"

cut='----8<--------8--------8<--------8<--------8<--------'


echo "
Here is your public key. Post it at https://github.com/account/ssh
$cut"
cat $key_file.pub #| sed '1s/^/# /'
echo "$cut
"

ssh_config=$(cat <<EOF
# -- github-keygen - begin --

Host *.github.com
Hostname github.com

Host *.gist.github.com
Hostname gist.github.com

Host $github_hosts *.github.com *.gist.github.com
User git
# Enforce host checks
StrictHostKeyChecking yes
UserKnownHostsFile ~/${known_hosts_file#$HOME/}
# Hosts added later (identified by IP) will be hashed
HashKnownHosts yes
# GitHub has not yet (2011-05) implemented SSHFP (RFC 4255)
VerifyHostKeyDNS no
# Enable only the required authentication
PubkeyAuthentication yes
PreferredAuthentications publickey
# Trust no one, especially the remote
ForwardAgent no
ForwardX11 no
PermitLocalCommand no

Host $github_hosts $github_user.github.com $github_user.gist.github.com
IdentityFile ~/${key_file#$HOME/}

# -- github-keygen - end --
EOF
)

if [ -f ~/.ssh/config ] ; then
	cat <<-EOF
	Add the following lines to ~/.ssh/config.
	Note: if you wanted only to add a new github account and have already done the
	setup with $0 for an other Github account, you only have to add the
	last two lines.
$cut
$ssh_config
$cut

EOF
else
	echo "Creating ~/.ssh/config..."
	echo "$ssh_config" > ~/.ssh/config
	echo "Done."
fi

chmod 600 ~/.ssh/config

cat <<EOF

Once you have done the actions above you will be able to test with:
    ssh -Tn github.com
    ssh -Tn gist.github.com
    ssh -Tn $github_user.github.com
    ssh -Tn $github_user.gist.github.com

EOF