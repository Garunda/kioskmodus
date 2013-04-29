#!/bin/bash

## Make Release and Package files
cd ..

DateienErstellen(){

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
gpg -a --yes --output "$PaketPfad"/Release.gpg --local-user 82BA8E0F --detach-sign "$PaketPfad"/Release

apt-ftparchive release -c dists/"$Suite"/apt-"$Suite"-release.conf dists/"$Suite" > dists/"$Suite"/Release
gpg -a --yes --output dists/"$Suite"/Release.gpg --local-user 82BA8E0F --detach-sign dists/"$Suite"/Release
}


GenerateRepo(){
## http://www.linux-praxis.de/linux1/shell2_4.html
## Syntax: GenerateRepo raring main kioskmodus

# Less than 2 parameter ? --> Abbort
if [ $# -lt 2 ]; then
	echo "missing parameter"
	return
fi

# The first paramter is the Ubuntu Suite
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

# Ins Verzeichnis wechseln
#cd /var/www/vhosts/ostsee-gymnasium.de/subdomains/repository/httpdocs/dists/precise/main/binary-i386

#DateienErstellen raring dists/raring/main/binary-i386
#DateienErstellen raring dists/raring/kioskmodus/binary-i386

GenerateRepo raring main kioskmodus

exit 0
