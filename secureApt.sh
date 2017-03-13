#!/bin/bash
#
# Creates the Release and Release.gpg files for APT repo
# based on Packages and Packages.gz files
# The created files make the repo a "signed" repo
# Changed Input for independent distributions and made a loop for all channels

if [ "$1" = "" -o "$2" = "" ]; then echo "Usage: secureApt.sh DISTNAME RELEASENUMBER";exit 1;fi
WOR_DIR='/var/cache/rhn/repodata'

for I in $( ls -d $WOR_DIR/$1* )
do
	DATE=`date "+%a, %d %b %Y %H:%M:%S %z"`
	GPG_PASS='pingUin'
	HEADER="Origin: Ubuntu
	Label: Ubuntu
	Suite: $1
	Version: $2
	Codename: $1
	Date: ${DATE}
	Architectures: amd64
	Components: repodata
	Description: Ubuntu $1 $2
	MD5Sum:"

	PACKAGES_MD5=($(md5sum $I/Packages))
	PACKAGES_SIZE=$(stat -c%s $I/Packages)
	PACKAGESGZ_MD5=($(md5sum $I/Packages.gz))
	PACKAGESGZ_SIZE=$(stat -c%s $I/Packages.gz)
	PACKAGES_SHA256=($(sha256sum $I/Packages))
	PACKAGESGZ_SHA256=($(sha256sum $I/Packages.gz))

	# write Release file with MD5s
	rm -rf $I/Release
	echo -e "${HEADER}" > $I/Release
	echo -e " ${PACKAGES_MD5}\t${PACKAGES_SIZE}\trepodata/binary-amd64/Packages" >> $I/Release
	echo -e " ${PACKAGESGZ_MD5}\t${PACKAGESGZ_SIZE}\trepodata/binary-amd64/Packages.gz" >> $I/Release
	echo -e " ${PACKAGES_MD5}\t${PACKAGES_SIZE}\trepodata/binary-i386/Packages" >> $I/Release
	echo -e " ${PACKAGESGZ_MD5}\t${PACKAGESGZ_SIZE}\trepodata/binary-i386/Packages.gz" >> $I/Release
	echo -e "SHA256:" >> $I/Release
	echo -e " ${PACKAGES_SHA256}\t${PACKAGES_SIZE}\trepodata/binary-amd64/Packages" >> $I/Release
	echo -e " ${PACKAGESGZ_SHA256}\t${PACKAGESGZ_SIZE}\trepodata/binary-amd64/Packages.gz" >> $I/Release
	echo -e " ${PACKAGES_SHA256}\t${PACKAGES_SIZE}\trepodata/binary-i386/Packages" >> $I/Release
	echo -e " ${PACKAGESGZ_SHA256}\t${PACKAGESGZ_SIZE}\trepodata/binary-i386/Packages.gz" >> $I/Release

	# write the signature for Release file
	rm -rf $I/Release.gpg
	echo $GPG_PASS | gpg --armor --detach-sign -o $I/Release.gpg --batch --no-tty --passphrase-fd 0 --sign $I/Release

done
