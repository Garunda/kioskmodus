#!/bin/bash

local ConfFile="/etc/updateRepository/updateRepository.conf"

## Make Release and Package files
#cd ..
cd /var/www/vhosts/ostsee-gymnasium.de/subdomains/repository/httpdocs

DateienErstellen(){
#DateienErstellen raring dists/raring/main/binary-i386

Suite="$1"
PaketPfad="$2"

echo "Pfad: $PaketPfad"

# Packages.gz erzeugen
dpkg-scanpackages "$PaketPfad" > "$PaketPfad"/Packages && gzip -f "$PaketPfad"/Packages

# Packages erzeugen
dpkg-scanpackages "$PaketPfad" > "$PaketPfad"/Packages

# Release-Datei erzeugen
apt-ftparchive release -c dists/"$Suite"/apt-"$Suite"-release.conf "$PaketPfad" > "$PaketPfad"/Release

# Release-Datei signieren
gpg -a --yes --output "$PaketPfad"/Release.gpg --local-user 82BA8E0F --passphrase "$Passph" --detach-sign "$PaketPfad"/Release

apt-ftparchive release -c dists/"$Suite"/apt-"$Suite"-release.conf dists/"$Suite" > dists/"$Suite"/Release
gpg -a --yes --output dists/"$Suite"/Release.gpg --local-user 82BA8E0F --passphrase "$Passph" --detach-sign dists/"$Suite"/Release
}


GenerateRepo(){
## http://www.linux-praxis.de/linux1/shell2_4.html
## Syntax: GenerateRepo raring main kioskmodus

# Less than 2 parameter ? --> Abbort
if [ $# -lt 2 ]; then
	echo "missing parameter"
	return
fi

# The first parameter is the Ubuntu Suite
UbuntuVersionSuite=$1
# shift all paramter left. (The first is shifted out)
shift
# Read all remaining parameter
UbuntuVersioncomponents=$@

for choice in $UbuntuVersioncomponents
        do
		PackagePath=dists/"$UbuntuVersionSuite"/"$choice"/binary-i386
		DateienErstellen $UbuntuVersionSuite $PackagePath
	done
}


# Read GPG-passphrase
echo "GPG-Passphrase:"
read Passph

#if [ ! -d /etc/updateRepository ]; then
#	mkdir /etc/updateRepository
#fi

#if [ ! -f "$ConfFile" ]; then
#	echo "## updateRepository.conf" > "$ConfFile"
#	echo "RepositoryPath=\"/var/www/vhosts/ostsee-gymnasium.de/subdomains/repository/httpdocs\"" >> "$ConfFile"
#	echo "# GenerateRepo raring main kioskmodus" >> "$ConfFile"
#fi

# . "$ConfFile"
GenerateRepo raring main kioskmodus


unset Suite
unset PaketPfad
unset UbuntuVersionSuite
unset UbuntuVersioncomponents
unset choice
unset Passph
unset ConfFile

exit 0
