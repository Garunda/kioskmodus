#!/bin/bash
############################################################################################
#### Copyright (c) 2009 Alexander Kauerz, Haiko Helmholz				####
#### 											####
#### Permission is hereby granted, free of charge, to any person obtaining a copy of 	####
#### this software and associated documentation files (the "Software"), to deal in the	####
#### Software without restriction, including without limitation the rights to use, 	####
#### copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the	####
#### Software, and to permit persons to whom the Software is furnished to do so, 	####
#### subject to the following conditions:						####
#### 											####
#### The above copyright notice and this permission notice shall be included in all 	####
#### copies or substantial portions of the Software.					####
#### 											####
#### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 	####
#### IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 	####
#### FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR	####
#### COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 	####
#### IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 		####
#### CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.		####
############################################################################################



## Die Pfad-Variabeln
Instpfad="/root/kioskmodus"
Config=""$Instpfad"/kioskmodus.conf"
Aufloesung=`cat "$Instpfad"/X/aufloesung`

Beepen(){

# Nette Beeptöne von sich geben

# Das modul laden
modprobe -v pcspkr

beep -f 659 -l 460 -n -f 784 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 880 -l 230 -n -f 659 -l 230 -n -f 587 -l 230 -n -f 659 -l 460 -n -f 988 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 1047-l 230 -n -f 988 -l 230 -n -f 784 -l 230 -n -f 659 -l 230 -n -f 988 -l 230 -n -f 1318 -l 230 -n -f 659 -l 110 -n -f 587 -l 230 -n -f 587 -l 110 -n -f 494 -l 230 -n -f 740 -l 230 -n -f 659 -l 460

}


SysViniteinrichtung(){

if [ $1 == "on" ]; then

## Verlinkung des Skriptes nach /etc/rc0.d
# Das Skript wird hierdurch beim Herunterfahren ausgeführt

#	if ([ ! -f /etc/rcS.d/S60kioskmodus ] && [ ! -f /etc/rcS.d/S60* ]); then
	if [ ! -f /etc/rcS.d/S10kioskmodus ]; then
		ln -s "$Instpfad"/kioskmodus.sh /etc/rcS.d/S10kioskmodus
	fi
elif [ $1 == "off" ]; then

## Löschen der Verlinkung

	if [ -f /etc/rcS.d/S10kioskmodus ]; then
		rm /etc/rcS.d/S10kioskmodus
	fi
	exit
fi

}


Upstarteinrichtung(){

## Scriptstart beim Systemstart per Upstart einrichten
# Die Datei wurde noch nicht mit Leben gefüllt!!!!

if [ $1 == "on" ]; then

	if [ ! -f /etc/init/start_kioskmodus.conf ]; then
#		cp "$Instpfad"/Upstart/start_kioskmodus.conf /etc/init/start_kioskmodus.conf
		echo ""
	fi

elif [ $1 == "off" ]; then

	if [ -f /etc/init/start_kioskmodus.conf ]; then
		rm /etc/init/start_kioskmodus.conf
	fi

fi

}


Nummernblockaktivierung(){

## Nummernblock von Start an Aktiviert

if [ $1 == "on" ]; then

## Kopieren der Datei num-on.conf um einen Upstart event auszulösen

	if [ ! -f /etc/init/num-on.conf ]; then
		cp "$Instpfad"/Num/num-on.conf /etc/init/num-on.conf
	fi

## Setzen der Verknüpfungen zum starten von Numlockx nach start der GUI
 
	if [ ! -f /home/schule/.config/autostart/DAUnumlockx_on.desktop ]; then
		cp -a "$Instpfad"/Num/DAUnumlockx_on.desktop /home/schule/.config/autostart/DAUnumlockx_on.desktop
	fi

	if [ ! -f /home/schule/.config/autostart/ADMnumlockx_on.desktop ]; then
		cp -a "$Instpfad"/Num/ADMnumlockx_on.desktop /home/verwaltung/.config/autostart/ADMnumlockx_on.desktop
	fi

elif [ $1 == "off" ]; then

## Löschen des Upstartevents

	if [ -f /etc/init/num-on.conf ]; then
		rm /etc/init/num-on.conf
	fi

## Löschen der Verknüpfungen zum starten von Numlockx

	if [ -f /home/schule/.config/autostart/DAUnumlockx_on.desktop ]; then
		rm /home/schule/.config/autostart/DAUnumlockx_on.desktop
	fi

	if [ -f /home/schule/.config/autostart/ADMnumlockx_on.desktop ]; then
		rm /home/verwaltung/.config/autostart/ADMnumlockx_on.desktop
	fi

fi

}


GRUBgPXE(){

## Einrichten eines GRUB eintrages für gPXE Boot

if [ $1 == "on" ]; then

	if [ ! -f /etc/grub.d/35_gpxe ]; then
		# Kopieren der gPXEgrubmenuedatei in das Grubmenueerstellungsverzeichnis
		cp "$Instpfad"/GRUB/35_gpxe /etc/grub.d/35_gpxe
		# neue Einträge übernehmen
		update-grub
	fi

elif [ $1 == "off" ]; then

	if [ -f /etc/grub.d/35_gpxe ]; then
		rm /etc/grub.d/35_gpxe
		update-grub
		echo ""
	fi

fi


}


GRUBabsichern(){

## GRUB mit Passwort versehen
# Funktioniert noch nicht

if [ $1 == "on" ]; then

	if [ ! -f /boot/grub/pbkdf2.lst ]; then
		cp "$Instpfad"/GRUB/pbkdf2.lst /boot/grub/pbkdf2.lst
	fi

	if [ ! -f /etc/grub.d/36_passwort ]; then
		cp "$Instpfad"/GRUB/36_passwort /etc/grub.d/36_passwort
		update-grub
	fi
fi

}


GDMAutoLogin(){

## Kopieren der custom.conf von GDM in den GDM Ordner

if [ $1 == "on" ]; then

	cp "$Instpfad"/gdm/custom.conf /etc/gdm/custom.conf

fi

}


SSHKeysKopieren(){


if [ $1 == "on" ]; then

## Kopieren der SSH-Keys für den SSH-Server

	if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
		cp "$Instpfad"/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key
	fi

	if [ ! -f /etc/ssh/ssh_host_dsa_key.pub ]; then
		cp "$Instpfad"/ssh/ssh_host_dsa_key.pub /etc/ssh/ssh_host_dsa_key.pub
	fi

	if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
		cp "$Instpfad"/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
	fi

	if [ ! -f /etc/ssh/ssh_host_rsa_key.pub ]; then
		cp "$Instpfad"/ssh/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub
	fi

fi

}


XorgSetzen(){

#Falls neue Einstellung vorhanden, neue Auflösung übernehmen und temporäre Conf löschen.


if [ -f /root/.aufloesung ]; then
	Aufloesung=`cat /root/.aufloesung`
	echo "$Aufloesung" > "$Instpfad"/X/aufloesung
	rm /root/.aufloesung
	if [ -f /home/verwaltung/.aufloesung ]; then
		rm /home/verwaltung/.aufloesung
	fi
	if [ -f /home/schule/.aufloesung ]; then
		rm /home/schule/.aufloesung
	fi
elif [ -f /home/verwaltung/.aufloesung ]; then
	Aufloesung=`cat /home/verwaltung/.aufloesung`
	echo "$Aufloesung" > "$Instpfad"/X/aufloesung
	rm /home/verwaltung/.aufloesung
	if [ -f /home/schule/.aufloesung ]; then
		rm /home/schule/.aufloesung
	fi
elif [ -f /home/schule/.aufloesung ]; then
	Aufloesung=`cat /home/schule/.aufloesung`
	echo "$Aufloesung" > "$Instpfad"/X/aufloesung
	rm /home/schule/.aufloesung
fi


## Kopieren der xorg.conf in X11

if [ $1 == "on" ]; then
#	if [ ! -f /etc/X11/xorg.conf ]; then  # Auskommentiert, weil ansonsten Aenderungen nicht übernommen werden würden
		if [ "$Aufloesung" == "1024x768" ]; then
			cp "$Instpfad"/X/1024x768/xorg.conf /etc/X11/xorg.conf
		elif [ "$Aufloesung" == "1280x1024" ]; then
			cp "$Instpfad"/X/1280x1024/xorg.conf /etc/X11/xorg.conf
		fi
#	fi
elif [ $1 == "off" ]; then
	if [ -f /etc/X11/xorg.conf ]; then
		rm /etc/X11/xorg.conf
	fi
fi

}


Wiederherstellen(){

# Testausgabe ( Erzeugung einer Textdatei auf dem Desktop des Adminaccounts )
#echo "VOR der Wiederhersterllung" > /home/verwaltung/Desktop/TEST

## Wiederherstellen des Homeverzeichnisses

if [ $1 == "on" ]; then
	if [ -f "$Instpfad"/Archive/"$Aufloesung"/schule.tar.lzma ]; then

# Lösche den Ordner schule und seinen Inhalt
		rm -r /home/schule

# Erstelle den Ordner schule neu
		mkdir /home/schule

# Entpacke den Inhalt des mit lzma komprimierten Archives in /home/schule/
		tar --lzma -C /home/schule -xf "$Instpfad"/Archive/"$Aufloesung"/schule.tar.lzma

# Setze die Rechte auf den Schuluser
		chown -R schule:schule /home/schule/

	fi

fi

# Testausgabe ( Erzeugung einer Textdatei auf dem Desktop des Adminaccounts )
#echo "NACH der Wiederhersterllung" > /home/verwaltung/Desktop/TEST

}



AufloesungsskriptKopieren(){

##Kopieren des Skriptes nach /usr/bin

if [ $1 == "on" ]; then
	if [ ! -f /usr/bin/aufloesungeinstellen ]; then
 		if [ -f "$Instpfad"/X/aufloesungeinstellen ]; then
			cp "$Instpfad"/X/aufloesungeinstellen /usr/bin/aufloesungeinstellen
		fi
	fi
elif [ $1 == "off" ]; then
	if [ -f /usr/bin/aufloesungeinstellen ]; then
		rm /usr/bin/aufloesungeinstellen
	fi
fi

}


Journaldateisystemverwenden(){

## Dateisystem (falls noch nicht vorhanden) auf Journaling setzen
## ( Nicht nur die Metadaten sondern auch die Nutzdaten werden
## zunächst in das Journal, und dann erst auf die Festplatte geschrieben. )

# Dateisystemeigenschaften auflisten, Zeile ausfiltern und Option abtrennen.

Defaultmountoption="$(tune2fs -l /dev/sda1 | egrep "*Default mount options*" | awk '{print $4}' )"

# Überprüfen ob als "Default mount options" "journal_data" gesetzt ist. 

if [ ! $Defaultmountoption == "journal_data" ]; then

	# Dateisystem auf Journaling stellen
	tune2fs -o journal_data /dev/sda1

fi

}


Updaten(){

## Systemupdates einspielen
## Entweder online oder offline


# Verwenden on Online/Offline Paketquellen
if [ $1 == "online" ]; then

	echo "sources.list wird für Onlineupdate geändert"
	cp /etc/apt/sources.list.online /etc/apt/sources.list

else

	echo "sources.list wird für offline update geändert"
	cp /etc/apt/sources.list.mirror /etc/apt/sources.list

fi

echo "Update wird durchgeführt"
sleep 1

# Neuladen der Paketquellen und upgrade der Pakete
apt-get update && apt-get dist-upgrade

# Rücksetzen der sources.list
if [ $1 == "online" ]; then

	echo "sources.list wird auf Standardofflinepaketquellen geändert"
	cp /etc/apt/sources.list.mirror /etc/apt/sources.list

fi

echo "Update beendet"

}


Onlinepaketquellen(){

# Ändern der sources.list, sodass die Onlinepaketquellen verwendet werden
echo "Ändern der sources.list, sodass die Onlinepaketquellen verwendet werden"

cp /etc/apt/sources.list.online /etc/apt/sources.list

echo "Operation complete"

}



Erstellen(){

## Die Funktion zum erstellen des neuen LZMA Archives

## Aufloesung in Erfahrung bringen

aktAufloesung=`cat "$Instpfad"/X/aufloesung`

echo "Es ist "$aktAufloesung" als Aufloesung gewaehlt"

## Umbennen des bisherigen LZMA-Archives in "schule'date'.tar.lzma"
Zeit="$(date "+%Y%m%d%H%M%S")"
if [ -f "$Instpfad"/Archive/"$aktAufloesung"/schule.tar.lzma ]; then
	mv "$Instpfad"/Archive/"$aktAufloesung"/schule.tar.lzma "$Instpfad"/Archive/"$aktAufloesung"/schule"$Zeit".tar.lzma
	echo "Das alte Archiv wurde in schule"$Zeit".tar.lzma umbenannt"
else
	echo "Es wurde kein altes Archiv vorgefunden"
fi

## Erstelle das neue Archiv mit dem Namen "schule.tar.lzma"
echo "Das neue Archiv wird erstellt ..."
tar --lzma -C /home/schule -cf "$Instpfad"/Archive/"$aktAufloesung"/schule.tar.lzma .

## Anzeigen des Ergebnisses und Verwertung der alten Datei

Datei="$(du -h "$Instpfad"/Archive/"$aktAufloesung"/schule.tar.lzma)"

echo "Folgende Datei wurde erstellt:"
echo "$Datei"

if [ -f "$Instpfad"/Archive/"$aktAufloesung"/schule"$Zeit".tar.lzma ]; then
	echo "Möchten sie die alte Datei löschen ?"
	echo "(yes or no)"
	read Loeschfrage
	if [ "$Loeschfrage" = "yes" ]; then

		rm "$Instpfad"/Archive/"$aktAufloesung"/schule"$Zeit".tar.lzma
		echo "Datei wurde entfernt"

	else

		echo "Datei wurde als schule"$Zeit".tar.lzma im Verzeichnis "$Instpfad"/Archive/"$aktAufloesung"/ belassen"

	fi

fi

}


## Die Funktion zur Löschung aller alten Archive##

Löschen(){

if [ -f "$Instpfad"/Archive/1024x768/schule2* ]; then

#Sicherheitsabfrage

	echo "Möchten Sie wirklich alle gesicherten Archive löschen ?"
	echo "(yes or no)"
	read Loeschen
	if [ "$Loeschen" = "yes" ]; then

		rm "$Instpfad"/Archive/1024x768/schule2*
		rm "$Instpfad"/Archive/1280x1024/schule2*
		echo "Alle alten Archive gelöscht"

	elif  [ "$Loeschen" = "no" ]; then

		echo "Die gesicherten Archive wurden nicht gelöscht :)>-"

	else

		echo "Bitte Schreiben lernen"

	fi

else

	echo "Keine alten Archive vorhanden"

fi

}


## Die Hilfe ##

Hilfe(){

echo -e "\033[49;1;31m kioskmodus.sh                 \033[49;1;33m >> \033[49;1;32m stellt das homeverzeichnis wieder her \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh erstellen / -e  \033[49;1;33m >> \033[49;1;32m erstellt ein neues Archiv \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh löschen / -l    \033[49;1;33m >> \033[49;1;32m löscht alle alten Archive \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh hilfe / --help  \033[49;1;33m >> \033[49;1;32m öffnen die Hilfe \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh updaten / -u    \033[49;1;33m >> \033[49;1;32m führt ein Upgrade durch \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh -ou             \033[49;1;33m >> \033[49;1;32m führt ein Onlineupgrade durch \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh -op             \033[49;1;33m >> \033[49;1;32m verwenden der Onlinepaketquellen \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh -j              \033[49;1;33m >> \033[49;1;32m stellt das Dateisystem auf Journaling \033[0m"
echo -e "\033[49;1;31m $Instpfad \033[0m"
echo -e "\033[49;1;31m "$Config" ist die Konfigurationsdatei \033[0m"

}
# Der Grundbefehl für die Farbe in der Konsole lautet
#echo -e "\033[49;1;31m TESTAUSGABE \033[49;1;33m PFEILE \033[49;1;32m BUNT  \033[0m"


## Parameterauswertung ##

case $1 in
	"start"|"")
	source "$Config"
	;;
	"erstellen"|"-e")
	Erstellen
	;;
	"löschen"|"-l")
	Löschen
	;;
	"hilfe"|"--help"|"-h")
	Hilfe
	;;
	"test")
	exit
	;;
	"gpxe")
	GRUBgPXE on
	;;
	"updaten"|"-u")
	Updaten
	;;
	"onlineupdate"|"-ou")
	Updaten online
	;;
	"onlinepaketquellen"|"-op")
	Onlinepaketquellen
	;;
	"-j")
	Journaldateisystemverwenden
	;;
	*)
	echo "$1 ist ein falsches Parameter"
	exit
	;;
esac


## exit :)>-
exit
