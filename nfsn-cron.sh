#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

Dir=`dirname "$0"`
RealDir=`realpath "${Dir}"`

cd "$(dirname "$0")"

Verbose=0

for Arg in $*
do
	if [ "${Arg}" = "-v" ]
	then
		Verbose=1
	else
		echo "Unknown argument: ${Arg}"
		exit 1
	fi
done

if [ $Verbose -gt 0 ]
then
	echo " + Updating lets-nfsn.sh..."
	git pull
else
	git pull | fgrep -v 'Already up-to-date.' || true
fi

[ $Verbose -gt 0 ] && echo " + Updating dehydrated..."
git submodule update --remote

cd dehydrated

if [ ! -d certs ]
then
	echo "No certs directory. Have you run nfsn-setup.sh?"
	exit 1
fi

[ $Verbose -gt 0 ] && echo " + Checking certificate expiration date..."
if find certs -name cert.pem -type l \
	-exec openssl x509 -checkend 2592000 -in {} \; |
		grep -qF "Certificate will expire"
then
	true
else
	[ $Verbose -gt 0 ] && echo " + More than 30 days until any certificate expires. Exiting."
	exit 0
fi

##  Until we make the nfsn command work via cron.
#echo " + Certificate will expire in 30 days or less!"
#echo " + Run this command to renew your certificates:"
#echo
#echo "   ${RealDir}/nfsn-renew.sh"
#echo
#echo " + You can use ssh or the \"Run Shell Command\" action on"
#echo "   the Site Information Panel to run this command."
#echo " + This error message will repeat daily."
#exit 1

##  Renew certificate.
echo " + Running dehydrated..."
./dehydrated --cron

echo " + Cleaning up old certificates..."
./dehydrated --cleanup

