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



# Als root ausführen
if [ `id -u` -ne 0 ];then exec sudo $0; fi

## Die Pfad-Variabeln
Instpfad="/usr/bin"
Config="/etc/kioskmodus/kioskmodus.conf"
LogDatei="/var/log/kioskmodus"

if [ ! -d /etc/kioskmodus ]; then
	mkdir /etc/kioskmodus
fi

if [ -f /etc/kioskmodus/aufloesung ]; then
	Aufloesung=`cat /etc/kioskmodus/aufloesung`
else
	echo "1024x768" > /etc/kioskmodus/aufloesung
fi
Ausgang="none"


LogEintragErstellen(){

## Hier werden Logeinträge für den Kioskmodus in die Datei /var/log/kioskmodus
## geschrieben. Der Aufruf dieser Funktion erfolgt nach folgendem Schema:
##      LogEintragErstellen "Dies ist ein Logeintrag"
## Dieser Befehl wird folgenden Eintrag erzeugen:
## Nov 24, 2011 14:36:18 +0100 : Dies ist ein Logeintrag
## Desweitern ist auch folgnder Aufruf möglich:
##      Befehl | LogEintragErstellen
## Hierbei wird die Ausgabe von Befehl in die Eingabe dieser Funktion umgeleitet.
## Durch diese Funktion wird das finden eines Fehlers vereinfacht.
## vgl. http://wiki.ubuntuusers.de/Logdateien

Message="$1"

# Falls kein Sting als Parameter übergeben wurde,
# dann wurde vielelciht einer als Eingabe übergeben. ( Pipeoperator )
if [ "$Message"  == "" ];then
	# Einlesen der Eingabe, aber nur 0,5 Sekunden lang dieses tun,
	# damit im Fehlerfall abgebrochen wird.
	read -t 0.5 Message
fi

# Kein String zum Eintragen wurde übergeben, Fehler ausgeben
if [ "$Message"  == "" ];then
	# Fehler melden
	Message="ERROR Es wurde kein String für die Logdatei übergeben"
fi

# Existiert die Logdatei, falls nicht wird Sie erstellt.
if [ ! -f "$LogDatei" ]; then
	echo "#### Dies ist die Logdatei vom Kioskscript ####" > "$LogDatei"
fi

# Die momentane Uhrzeit wird ermittelt
Uhrzeit="$(date "+%b %d, %Y %H:%M:%S %z")"

# Schreiben des Logeintrags
echo "$Uhrzeit : $Message" >> "$LogDatei"

unset Message

}


WoIstDerServer(){

# Im Aufbau


## Serveradressen
# Paketkoenig
PossibleServerAdress[1]="paketkoenig.localdomain"
PossibleServerAdress[2]="paketkoenig.local"
WoIstDerServer
PaketkoenigAdress=$Reply
# IPCop
PossibleServerAdress[1]="10.0.0.15"
PossibleServerAdress[2]="zeitserver.local"
PossibleServerAdress[3]="zeitserver.localdomain"
WoIstDerServer
IPCopAdress=$Reply
# FileServer
#PossibleServerAdress[1]="10.0.0.15"
#PossibleServerAdress[2]="fileserver.local"
#PossibleServerAdress[3]="fileserver.localdomain"
#WoIstDerServer
#FileServerAdress=$Reply


# Speichervariable
Reply=""

# Alle Adressen durchtesten
for wert in "${PossibleServerAdress[@]}"
  do

	# Sende 2 Pings, aber wirklich nur 2
	if [[ `ping -c 2 "$wert"` ]];then

		# Adresse in $Reply speichern
		Reply="$wert"

	fi

done

unset PossibleServerAdress

}


Beepen(){

## Nette Beeptöne über die internen PC-Lautsprecher ausgeben
## vgl. http://wiki.ubuntuusers.de/Soundausgabe_Systemlautsprecher

# Das Kernel-Modul laden
modprobe -v pcspkr

beep -f 659 -l 460 -n -f 784 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 880 -l 230 -n -f 659 -l 230 -n -f 587 -l 230 -n -f 659 -l 460 -n -f 988 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 1047-l 230 -n -f 988 -l 230 -n -f 784 -l 230 -n -f 659 -l 230 -n -f 988 -l 230 -n -f 1318 -l 230 -n -f 659 -l 110 -n -f 587 -l 230 -n -f 587 -l 110 -n -f 494 -l 230 -n -f 740 -l 230 -n -f 659 -l 460

}


SysViniteinrichtung(){

# Kontrolle ob schon vorhanden fehlerhaft

if [ $1 == "on" ]; then

## Verlinkung des Skriptes nach /etc/rc0.d
# Das Skript wird hierdurch beim Hochfahren ausgeführt

#	if ([ ! -f /etc/rcS.d/S60kioskmodus ] && [ ! -f /etc/rcS.d/S60* ]); then
	if [ ! -f /etc/rcS.d/S10kioskmodus ]; then

		LogEintragErstellen "SysViniteinrichtung : Eintrag wird erstellt, da noch nicht vorhanden"
		ln -s "$Instpfad"/kioskmodus.sh /etc/rcS.d/S10kioskmodus

	fi

#	if [ ! -f /etc/gdm/PostLogin/Default ]; then
#		echo "#!/bin/sh" > /etc/gdm/PostLogin/Default
#		echo ""$Instpfad"/kioskmodus.sh -v" >> /etc/gdm/PostLogin/Default
#		chmod a+x /etc/gdm/PostLogin/Default
#	elif [ -f /etc/gdm/PostLogin/Default ]; then
##		echo "test"
#		if [ ! "$(cat  /etc/gdm/PostLogin/Default | egrep "*"$Instpfad"/kioskmodus.sh*" | awk '{print $1}' )" == ""$Instpfad"/kioskmodus.sh" ]; then
##		echo "test2"
#		echo ""$Instpfad"/kioskmodus.sh -v" >> /etc/gdm/PostLogin/Default
#		fi
#	fi

elif [ $1 == "off" ]; then

## Löschen der Verlinkung

	if [ -f /etc/rcS.d/S10kioskmodus ]; then
		rm /etc/rcS.d/S10kioskmodus
	fi
	exit
else
	return
fi

}


UpstartDateieinfuegen(){

## Hier wird die Datei "/etc/init/start_kioskmodus.conf" erzeugt

cat <<-\$EOFE >/etc/init/start_kioskmodus.conf
#Meine ersten Schritte mit Upstart
description	"simples Upstart-Beispiel"
# wann starten bzw. stoppen?
start on runlevel [2345]
stop on runlevel [!2345]
env enabled=1
PATH_BIN=/bin/bash
exec /root/kioskmodus.sh
$EOFE

}


Upstarteinrichtung(){

## Scriptstart beim Systemstart per Upstart einrichten
# Die Datei wurde noch nicht mit Leben gefüllt!!!!

if [ $1 == "on" ]; then

	if [ ! -f /etc/init/start_kioskmodus.conf ]; then
#		UpstartDateieinfuegen
		echo ""
	fi

elif [ $1 == "off" ]; then

	if [ -f /etc/init/start_kioskmodus.conf ]; then
		rm /etc/init/start_kioskmodus.conf
	fi
else
	return
fi

}


Hardlinkserlauben(){

# Wenn noch nicht erlaubt, dann jetzt erlauben
# /etc/sysctl.d/60-hardlink-restrictions-disabled.conf
# Veränderungen werden mit 'sudo start procps' wirksam
# Für diese Einstellung siehe "Hardlink restrictions" unter
# https://wiki.kubuntu.org/Security/Features/Historical


if [ ! -f /etc/sysctl.d/60-hardlink-restrictions-disabled.conf ]; then

	echo "kernel.yama.protected_nonaccess_hardlinks=0" > /etc/sysctl.d/60-hardlink-restrictions-disabled.conf
	start procps
else
	return
fi

}

MountAufs(){

# Test ob schon gemounted nicht vorhanden

## Hier wird das Homeverzeichnis Schreibgeschützt
#  vgl. http://www.heise.de/ct/11/03/links/122.shtml
#  vgl. Ausgabe 3/2011 Computermagazin c't

if [ $1 == "on" ]; then

	if [ -d /home/schule ]; then

		# Testen ob die Verzeichnisse existieren
		if [ ! -d /home/.schule_rw ]; then

			# ansonsten erstellen des Verzeichnisses
			install -d -o schule -g schule /home/.schule_rw
			LogEintragErstellen "MountAufs : .schule_rw wird erstellt"
		fi
		# Sind Hardlinks erlaubt ?
		Hardlinkserlauben

		# Wenn angeschaltet, dann verglase das Homeverzeichnis

		mount -t aufs -o br:/home/.schule_rw/:/home/schule/ none /home/schule
		LogEintragErstellen "MountAufs : Aufs-Dateisystem über das Homeverzeichnis legen"
	fi

else
	return
fi

}

MountAufsEintraginFstab(){

# Im Aufbau gewesen

## Eintrag für das Uniondateisystem in der fstab anlegen,
#  aber nur wenn er noch nicht vorhanden ist.


# Vorhanden ?
String1="$(sed -n '/none /home/keinpasswort aufs br:/home/.keinpasswort_rw:/home/keinpasswort 0 0/p' /etc/fstab )"

# Falls nicht; hänge diese Zeile ans Dokument an.

if [ ! "$String1" == "none /home/keinpasswort aufs br:/home/.keinpasswort_rw:/home/keinpasswort 0 0"  ]; then

	backup /etc/fstab
	echo "none /home/keinpasswort aufs br:/home/.keinpasswort_rw:/home/keinpasswort 0 0" >> /etc/fstab

fi

unset String1

}


schule_rw_cleanup(){

## Bereinigen des schule_rw Verzeichnisses

if [ $1 == "on" ]; then

# cleanup-script soll nur weiterlaufen, wenn
# keinpasswort durch aufs geschützt wird.
#immutable=`mount -l -t aufs |grep 'none on /home/schule type aufs (rw,br:/home/.schule_rw/:/home/schule/)'`

#	if [ ! $immutable == "" ]; then

	  # Lösch-Funktion, welcher zusätzliche find-Argumente übergeben werden können

	  # Verwaltungs-Objekte von aufs
	  no_aufs="! -name .wh..wh.aufs ! -name .wh..wh.orph ! -name .wh..wh.plnk"
	  # Zusätliches find-Argument speichern
	  zusatz=""
	  # Wird dieses Script als root ausgeführt, kann das folgende "rm -rf" sehr gefährlich werden --
	  # insbesondere zu Testzwecken auf einem normalen Arbeitsrechner. Mit der folgenden Kombination
	  # ist sichergestellt, dass wirklich nur der Inhalt von .schule_rw gelöscht wird.
	  cd /home/.schule_rw && find . -maxdepth 1 -mindepth 1 $no_aufs $zusatz -print0|xargs -0 rm -rf
	LogEintragErstellen "schule_rw_cleanup : .schule_rw wurde bereinigt"
#	echo "nein"	
#	fi
#echo "ja"
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

else

	return

fi

}


gPXEgrubmenuedateieinfuegen(){

## Hier wird die Menuedatei eingefügt

cat <<-\$EOFE >/etc/grub.d/35_gpxe
#! /bin/sh -e

echo "Füge Eintrag für GPXE Boot ein"  >&2

cat << EOF

menuentry "gPXE Netzwerkboot" {
        recordfail
	savedefault
	insmod ext3
	set root='(hd0,1)'
	linux16 /etc/kioskmodus/gpxe-1.0.1-gpxe.lkrn
	echo  Lade aktuellen Kernel von ${GRUB_DEVICE}... 
}

EOF
$EOFE

# Rechte geben
chmod a+x /etc/grub.d/35_gpxe

LogEintragErstellen "gPXEgrubmenuedateieinfuegen : Eintrag erstellt"

}


GRUBgPXE(){

## Einrichten eines GRUB eintrages für gPXE Boot
#  vgl. http://wiki.ubuntuusers.de/GRUB_2/Konfiguration

if [ $1 == "on" ]; then

	# Änderungen in /etc/default/grub, damit man das Grubmenue aufrufen kann
	String1="$(sed -n '/GRUB_HIDDEN_TIMEOUT=/p' /etc/default/grub )"
	if [ ! "$String1" == "GRUB_HIDDEN_TIMEOUT=5" ]; then

		sed -e '/GRUB_HIDDEN_TIMEOUT=/c\GRUB_HIDDEN_TIMEOUT=5' /etc/default/grub > /tmp/kioskmodusdefaultgrub
		sed -e '/GRUB_HIDDEN_TIMEOUT_QUIET=/c\GRUB_HIDDEN_TIMEOUT_QUIET=false' /tmp/kioskmodusdefaultgrub > /etc/default/grub

	fi
	unset String1

	if [ ! -f /etc/grub.d/35_gpxe ]; then
		# Einfügen der gPXEgrubmenuedatei in das Grubmenueerstellungsverzeichnis
		gPXEgrubmenuedateieinfuegen

		# neue Einträge übernehmen
		update-grub
	fi

elif [ $1 == "off" ]; then

	if [ -f /etc/grub.d/35_gpxe ]; then
		rm /etc/grub.d/35_gpxe
		update-grub
#		echo ""
	fi

else
	return
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


LightDMAutoLogin(){

## Hier wird der automatische Login für den Benutzer Schule erstellt.
## Es wird angenommen das der Displaymanger LightDM verwendet wird,
## deshalb wird dieser hier konfiguriert.


# Die vorgefertigte Konfigurationsdatei einfügen
cat <<-\$EOFE >/etc/lightdm/lightdm.conf

[SeatDefaults]
user-session=xubuntu
greeter-session=lightdm-gtk-greeter
autologin-user=schule
autologin-user-timeout=0

$EOFE


}


GDMAutoLogin(){

## Kopieren der custom.conf von GDM in den GDM Ordner

# Datei einfügen
cat <<-\$EOFE >/etc/gdm/custom.conf

[daemon]
DefaultSession=xubuntu
TimedLoginEnable=false
AutomaticLoginEnable=true
TimedLogin=schule
AutomaticLogin=schule
TimedLoginDelay=1
$EOFE

}


VideoAusgangHerausfinden(){

Ausgang="$(xrandr | egrep "*\<connected*" | awk '{print $1}' )"

#echo "$Ausgang" > /root/test
echo "$Ausgang" > /etc/kioskmodus/videoausgang

unset Ausgang

}


RandRstatischeAufloesung(){

## Aufloesung mit Xrandr übernehmen

# Die Videoausgangbezeichnung herausfinden
Ausgang=`cat /etc/kioskmodus/videoausgang`

# Die xrandrdatei erzeugen mit den entsprechenden angaben
if [ ! "$Ausgang" == "none" ]; then

	if [ "$Aufloesung" == "1024x768" ]; then

		echo "xrandr --newmode "1024x768_60.00"   63.50  1024 1072 1176 1328  768 771 775 798 -hsync +vsync" > /etc/X11/Xsession.d/45custom_xrandr-settings
		echo "xrandr --addmode "$Ausgang" "1024x768_60.00"" >> /etc/X11/Xsession.d/45custom_xrandr-settings
		echo "xrandr --output "$Ausgang" --mode 1024x768_60.00" >> /etc/X11/Xsession.d/45custom_xrandr-settings

	elif [ "$Aufloesung" == "1280x1024" ]; then

		echo "xrandr --newmode "1280x1024_60.00"  109.00  1280 1368 1496 1712  1024 1027 1034 1063 -hsync +vsync" > /etc/X11/Xsession.d/45custom_xrandr-settings
		echo "xrandr --addmode "$Ausgang" "1280x1024_60.00"" >> /etc/X11/Xsession.d/45custom_xrandr-settings
		echo "xrandr --output "$Ausgang" --mode 1280x1024_60.00" >> /etc/X11/Xsession.d/45custom_xrandr-settings

	fi

	# Rechte setzen
	chmod a+x /etc/X11/Xsession.d/45custom_xrandr-settings

fi

unset Ausgang
}


xorgeinfügenXGA(){

# Xorg.conf für die Aufloesung 1024x768 erzeugen

cat <<-\$EOFE >/etc/X11/xorg.conf
	# xorg.conf (X.Org X Window System server configuration file)
#
# This file was generated by dexconf, the Debian X Configuration tool, using
# values from the debconf database.
#
# Edit this file with caution, and see the xorg.conf manual page.
# (Type "man xorg.conf" at the shell prompt.)
#
# This file is automatically updated on xserver-xorg package upgrades *only*
# if it has not been modified since the last upgrade of the xserver-xorg
# package.
#
# Note that some configuration settings that could be done previously
# in this file, now are automatically configured by the server and settings
# here are ignored.
#
# If you have edited this file but would like it to be automatically updated
# again, run the following command:
#   sudo dpkg-reconfigure -phigh xserver-xorg

Section "Device"
	Identifier	"Configured Video Device"
#	Option		"UseFBDev"		"true"
EndSection

Section "Monitor"
	Identifier	"Configured Monitor"
	Modeline "1024x768_60.00"  64.11  1024 1080 1184 1344  768 769 772 795  -HSync +Vsync
EndSection

Section "Screen"
	Identifier	"Default Screen"
	Monitor		"Configured Monitor"
	DefaultDepth	24
	SubSection "Display"
		Depth	24
		Modes	"1024x768_60.00"
	EndSubSection
	Device		"Configured Video Device"
EndSection
$EOFE

}


xorgeinfügenSXGA(){

# Xorg.conf für die Aufloesung 1280x1024 erzeugen

cat <<-\$EOFE >/etc/X11/xorg.conf
	# xorg.conf (X.Org X Window System server configuration file)
#
# This file was generated by dexconf, the Debian X Configuration tool, using
# values from the debconf database.
#
# Edit this file with caution, and see the xorg.conf manual page.
# (Type "man xorg.conf" at the shell prompt.)
#
# This file is automatically updated on xserver-xorg package upgrades *only*
# if it has not been modified since the last upgrade of the xserver-xorg
# package.
#
# Note that some configuration settings that could be done previously
# in this file, now are automatically configured by the server and settings
# here are ignored.
#
# If you have edited this file but would like it to be automatically updated
# again, run the following command:
#   sudo dpkg-reconfigure -phigh xserver-xorg

Section "Device"
	Identifier	"Configured Video Device"
#	Option		"UseFBDev"		"true"
EndSection

Section "Monitor"
	Identifier	"Configured Monitor"
	Modeline "1280x1024_60.00"  108.88  1280 1360 1496 1712  1024 1025 1028 1060  -HSync +Vsync
EndSection

Section "Screen"
	Identifier	"Default Screen"
	Monitor		"Configured Monitor"
	DefaultDepth	24
	SubSection "Display"
		Depth	24
		Modes	"1280x1024_60.00"
	EndSubSection
	Device		"Configured Video Device"
EndSection
$EOFE


}


XorgSetzen(){

#Falls neue Einstellung vorhanden, neue Auflösung übernehmen und temporäre Conf löschen.


if [ -f /root/.aufloesung ]; then
	Aufloesung=`cat /root/.aufloesung`
	echo "$Aufloesung" > /etc/kioskmodus/aufloesung
	rm /root/.aufloesung
	if [ -f /home/verwaltung/.aufloesung ]; then
		rm /home/verwaltung/.aufloesung
	fi
	if [ -f /home/.schule_rw/.aufloesung ]; then
		rm /home/.schule_rw/.aufloesung
	fi
elif [ -f /home/verwaltung/.aufloesung ]; then
	Aufloesung=`cat /home/verwaltung/.aufloesung`
	echo "$Aufloesung" > /etc/kioskmodus/aufloesung
	rm /home/verwaltung/.aufloesung
	if [ -f /home/.schule_rw/.aufloesung ]; then
		rm /home/.schule_rw/.aufloesung
	fi
elif [ -f /home/.schule_rw/.aufloesung ]; then
	Aufloesung=`cat /home/.schule_rw/.aufloesung`
	echo "$Aufloesung" > /etc/kioskmodus/aufloesung
	rm /home/.schule_rw/.aufloesung
fi


## Kopieren der xorg.conf in X11

if [ $1 == "on" ]; then

		if [ "$Aufloesung" == "1024x768" ]; then
			xorgeinfügenXGA
		elif [ "$Aufloesung" == "1280x1024" ]; then
			xorgeinfügenSXGA
		fi
#		RandRstatischeAufloesung

elif [ $1 == "off" ]; then
	if [ -f /etc/X11/xorg.conf ]; then
		rm /etc/X11/xorg.conf
	fi
fi

}


Wiederherstellen(){

## Hier werden die Archive, die die Homeverzeichnisse der Benutzer enthalten,
## entpackt. Diese Dateien werden statt der bestehenden verwendet.


## Wiederherstellen des Homeverzeichnisses

if [ $1 == "schule" ]; then

	if [ -f /etc/kioskmodus/schule.tar.lzma ]; then

# Lösche den Ordner schule und seinen Inhalt
		rm -r /home/schule

# Erstelle den Ordner schule neu
		mkdir /home/schule

# Entpacke den Inhalt des mit lzma komprimierten Archives in /home/schule/
		tar --lzma -C /home/schule -xf /etc/kioskmodus/schule.tar.lzma

# Setze die Rechte auf den Schuluser
		chown -R schule:schule /home/schule/

		echo "Wiederherstellen : /home/schule wiederhergestellt"
		LogEintragErstellen "Wiederherstellen : /home/schule wiederhergestellt"

	fi

elif [ $1 == "verwaltung" ]; then

	if [ -f /etc/kioskmodus/verwaltung.tar.lzma ]; then

		mkdir /home/verwaltung

		# Entpacke den Inhalt des mit lzma komprimierten Archives in /home/schule/
		tar --lzma -C /home/verwaltung -xf /etc/kioskmodus/verwaltung.tar.lzma

		# Setze die Rechte auf den Schuluser
		chown -R verwaltung:verwaltung /home/verwaltung/

                echo "Wiederherstellen : /home/verwaltung wiederhergestellt"
                LogEintragErstellen "Wiederherstellen : /home/verwaltung wiederhergestellt"

	fi
fi

}


Aufloesungsskripteinfuegen(){

## Einfügen der Datei in /usr/bin/
## Hierdurch kann man komfortabel die Auflösung ändern

if [ ! -f /usr/bin/aufloesungeinstellen ]; then

# Die Datei aufloesungeinstellen erzeugen mit dem angegegbenen Inhalt

#backup /root/cleanup-keinpasswort.sh
cat <<-\$EOFE >/usr/bin/aufloesungeinstellen
	#!/bin/bash

##Aufloesung einstellen mittels Dialog

#Abfrage nach der Aufloesung mit #Hilfe einer Radiobox
auswahl=`dialog --stdout --backtitle Desktopaufloesungseinstellungen --title Auswahl --radiolist "Welche Aufloesung möchten Sie verwenden ? Sie können nur eine wählen." 16 60 5 \
     "1024x768" "1024x768 - XGA Aufloesung" on \
     "1280x1024" "1280x1024 - SXGA Aufloesung" off`

#Auswertung der Auswahl und erstellen der Datei
case "$auswahl" in
  1024x768)
    dialog --backtitle Desktopaufloesungseinstellungen --title Ergebnis --msgbox "1024x768 - XGA Aufloesung wurde ausgewählt. Sie wird nach zwei Neustarts ihres Systems als ihre Standardaufloesung für diesen PC verwendet!" 15 40
    echo "$auswahl" > "$HOME"/.aufloesung
    ;;
  1280x1024)
    dialog --backtitle Desktopaufloesungseinstellungen --title Ergebnis --msgbox "1280x1024 - SXGA Aufloesung wurde ausgewählt. Sie wird nach zwei Neustarts ihres Systems als ihre Standardaufloesung für diesen PC verwendet!" 15 40
    echo "$auswahl" > "$HOME"/.aufloesung
    ;;
esac

exit
$EOFE

	fi

chmod a+x /usr/bin/aufloesungeinstellen

}


Journaldateisystemverwenden(){

## Dateisystem (falls noch nicht vorhanden) auf Journaling setzen
## ( Nicht nur die Metadaten sondern auch die Nutzdaten werden
## zunächst in das Journal, und dann erst auf die Festplatte geschrieben. )
#  http://wiki.ubuntuusers.de/Tuning#Journal-Modus-aendern

# Dateisystemeigenschaften auflisten, Zeile ausfiltern und Option abtrennen.

Defaultmountoption="$(tune2fs -l /dev/sda1 | egrep "*Default mount options*" | awk '{print $4}' )"

# Überprüfen ob als "Default mount options" "journal_data" gesetzt ist. 

if [ ! $Defaultmountoption == "journal_data" ]; then

	# Dateisystem auf Journaling stellen
	tune2fs -o journal_data /dev/sda1
	LogEintragErstellen "Journaldateisystemverwenden : Option wird gesetzt"

fi

unset Defaultmountoption

}


Erstellen(){

## Die Funktion zum erstellen eines neuen LZMA Archives

## Aufloesung in Erfahrung bringen

#aktAufloesung=`cat "$Instpfad"/X/aufloesung`

#echo "Es ist "$aktAufloesung" als Aufloesung gewaehlt"

echo "Wessen Homeverzeichnis soll als Archiv gesichert werden ?"
echo "schule oder verwaltung ?"
read Benutzername

# Ist die Eingabe eine mögliche Eingabe ?
if [ "$Benutzername" == "" ]; then

	echo "Kein Benutzer gewählt, es wird nichts gemacht."
	LogEintragErstellen "Erstellen : Es wurde kein Benutzer angegeben, weiter ohne diese Funktion"
	# Springe raus aus dieser Funktion
	return

elif [ "$Benutzername" == "verwaltung" ] || [ "$Benutzername" == "schule" ]; then

	echo "Benutzer korrekt, los gehts"
	LogEintragErstellen "Erstellen : Benutzer korrekt, los gehts"

else

	echo "Eingabe nicht korrekt, es wird nichts gemacht."
	LogEintragErstellen "Erstellen : Es wurde kein möglciher Benutzer angegeben, weiter ohne diese Funktion"
	return

fi

## Umbennen des bisherigen LZMA-Archives in "<Benutzername><Datum>.tar.lzma"
Zeit="$(date "+%Y%m%d%H%M%S")"
if [ -f /etc/kioskmodus/"$Benutzername".tar.lzma ]; then
	mv /etc/kioskmodus/"$Benutzername".tar.lzma /etc/kioskmodus/"$Benutzername""$Zeit".tar.lzma
	echo "Das alte Archiv wurde in "$Benutzername""$Zeit".tar.lzma umbenannt"
	LogEintragErstellen "Erstellen : Das alte Archiv wurde in "$Benutzername""$Zeit".tar.lzma umbenannt"
else
	echo "Es wurde kein altes Archiv vorgefunden"
	LogEintragErstellen "Erstellen : Es wurde kein altes Archiv vorgefunden"
fi

## Erstelle das neue Archiv mit dem Namen "<Benutzername>.tar.lzma"
echo "Das neue Archiv wird erstellt ..."
LogEintragErstellen "Erstellen : Das neue Archiv wird erstellt ..."
tar --lzma -C /home/"$Benutzername" -cf /etc/kioskmodus/"$Benutzername".tar.lzma .

## Anzeigen des Ergebnisses und Verwertung der alten Datei

Datei="$(du -h /etc/kioskmodus/"$Benutzername".tar.lzma)"

echo "Folgende Datei wurde erstellt:"
echo "$Datei"
LogEintragErstellen "Erstellen : Folgende Datei wurde erstellt: "$Datei""

if [ -f /etc/kioskmodus/"$Benutzername""$Zeit".tar.lzma ]; then
	echo "Möchten sie die alte Datei löschen ?"
	echo "(yes or no)"
	read Loeschfrage
	if [ "$Loeschfrage" = "yes" ]; then

		rm /etc/kioskmodus/"$Benutzername""$Zeit".tar.lzma
		echo "Datei wurde entfernt"

	else

		echo "Datei wurde als "$Benutzername""$Zeit".tar.lzma im Verzeichnis /etc/kioskmodus/ belassen"

	fi

fi

unset Benutzername
unset Datei
unset Loeschfrage

}


Loeschen(){

## Die Funktion zur Löschung aller alten Archive

if [ -f /etc/kioskmodus/*.tar.lzma ]; then

#Sicherheitsabfrage

	echo "Möchten Sie wirklich alle gesicherten Archive löschen ?"
	echo "(yes or no)"
	read Loeschen
	if [ "$Loeschen" == "yes" ]; then

		rm /etc/kioskmodus/schule2*
		rm /etc/kioskmodus/verwaltung2*
		echo "Alle alten Archive gelöscht"

	elif  [ "$Loeschen" == "no" ]; then

		echo "Die gesicherten Archive wurden nicht gelöscht :)>-"

	else

		echo "Bitte Schreiben lernen"

	fi

else

	echo "Keine alten Archive vorhanden"

fi

}


LokaleTopLevelDomainHerausfinden(){

## Um eideutige Server-Hostnamen zu verwenden muss
## die im lokalen Netzwerk verwendete Top-Level-Domain
## bekannt sein. Da diese verändert werden kann und
## zentral vom DHCP-Server festgelegt wird, ist es nur
## logisch diese durch diesen auch in Erfahrung zu bringen.
## Hierzu wird der "dhclient" angezapft. Dieser schreibt die
## aktuelle DHCP-Einstellungen nach "/var/lib/dhcp3" und
## dort in in Dateien nach dem Schema:
## "./dhclient-df1c490c-a733-4b80-a9fc-174cd2cf7bb6-eth1.lease"
## Zunächst gilt es die neueste Datei zu finden. Das Konstrukt
## "ls -lt $(for i in $(find -type f) ; do ls -t $i ; done) | head -1"
## liefert die neueste Datei aus dem aktuellen Verzeichnis
## und allen Unterverzeichnissen. Uns reicht in diesem
## Fall dieses schnelle und einfachere Codeschnipsel :
## "ls -t | head -1"
## vgl. http://www.e-cs.co/2010/08/26/linux/neuste-datei-finden/
##      http://linuxint.com/DOCS/Linux_Docs/openbook_shell/shell_004_002.htm

# neuste Datei finden, Option "-t" sortiert nach Änderungsdatum
# "head -1" gibt nur die oberste Zeile aus.
AktuelleDHCPLeaseDatei="$(ls -t /var/lib/dhcp3/ | head -1)"

# awk: Zeile "option domain-name" herausfiltern
# head: Falls mehrmals vorhanden, nur erste verwenden
# cut: erstes Zeichen abschneiden ( alles ab dem 2. ausgeben )
AktuelleLokaleTopLevelDomain="$(awk '/option domain-name / {print $3 }' /var/lib/dhcp3/$AktuelleDHCPLeaseDatei | head -1 | cut -c2- )"

# Die letzten beiden Zeichen abschneiden ( Quote und Semikolon )
AktuelleLokaleTopLevelDomain="${AktuelleLokaleTopLevelDomain%??}"

unset AktuelleDHCPLeaseDatei

}


SicherheitsupdatesEinspielenUndHerunterfahren(){

## Diese Funtion wird durch einen Cronjob ausgeführt.
## Dieser wurde durch PCAutoShutdown erstellt.
## Es wird nach Sicherheitsupdates gesucht und diese werden dann installiert.
## Dannach werden auch andere unkritische Updates installiert.
## Zum Abschluss wird der PC heruntergefahren

# Zunächst wird überprüft ob die Systemuhrzeit korrekt sein kann.
if [ "$(ntpdate zeitserver.localdomain)" ]; then

	# Den Distributionscodenamen einlesen
	. /etc/lsb-release
	# Paketquellen neu laden
	apt-get update
	# Sicherheitsupdates installieren
	apt-get -yt "$DISTRIB_CODENAME"-security dist-upgrade
	# Alle einfachen Updates installieren
	apt-get --trivial-only dist-upgrade 
	# PC herunterfahren, verwenden von shutdown, da halt Fehler verursacht ( PC friert ein )
	LogEintragErstellen "SicherheitsupdatesEinspielenUndHerunterfahren : Der PC muss durch das Script heruntergefahren, der DAU war am Werk"
	shutdown -h now

fi

}


PCAutoShutdown(){

# Muss getestet werden

## Der PC soll automatisch um 1700 Uhr heruntergefahren werden.
## Das ganze soll aber nur durchgeführt werden wenn die Systemuhrzeit
## aktuell ist. Hierzu wird ein entsprechender Eintrag in der neu
## zu erstellenden Datei /etc/cron.d/autoshutdown angelegt.

# Nachsehen ob die Datei schon existiert.
if [ ! -f /etc/cron.d/autoshutdown ]; then

# Sie existiert noch nicht und wird deshlab angelegt
cat <<-\$EOFE >/etc/cron.d/autoshutdown

## Dies ist der Cron-job für das automatische
## Herunterfahren des Rechners um 1700 Uhr
## Das ganze ist nur wegen dem DAU notwendig 
## und wäre ohne ihm unnötig.

# Path Varibale erzeugen, damit das Skript funktioniert
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#M   S     T M W   user Befehl

59   16    * * *   root /usr/sbin/ntpdate zeitserver.localdomain > /dev/null
0    17    * * *   root /usr/sbin/ntpdate zeitserver.localdomain > /dev/null && /usr/bin/kioskmodus.sh -S

$EOFE

LogEintragErstellen "PCAutoShutdown : Datei /etc/cron.d/autoshutdown erstellt"

fi

}


LightDMGreeterAendern(){

## Es soll ein spezieller Hintergrund statt dem
## Standard-Xubuntu Hintergrund für den Loginbildschirm
## verwendet werden.
## Hierzu wird die erste Zeile der Config angepasst und
## komplett neu geschrieben
## Es wird ein Bild aus der NASA "Image Gallery of the Day" verwendet
## vgl. http://www.nasa.gov/multimedia/imagegallery/iotd.html

cat <<-\$EOFE >/etc/lightdm/lightdm-gtk-greeter.conf

#
# background = Background file to use, either an image path or a color (e.g. #772953)
# theme-name = GTK+ theme to use
# font-name = Font to use
# xft-antialias = Whether to antialias Xft fonts (true or false)
# xft-dpi = Resolution for Xft in dots per inch (e.g. 96)
# xft-hintstyle = What degree of hinting to use (hintnone, hintslight, hintmedium, or hintfull)
# xft-rgba = Type of subpixel antialiasing (none, rgb, bgr, vrgb or vbgr)
#
[greeter]
background=/usr/share/xfce4/backdrops/586473main_iss028e005671_full.jpg
theme-name=greybird
font-name=Droid Sans 10
xft-antialias=true
xft-dpi=96
xft-hintstyle=slight
xft-rgba=rgb

$EOFE

LogEintragErstellen "LightDMGreeterAendern : Datei wurde abgeändert"

}


PlymouthThemeAendern(){

## Plymouth ist für die grafische Darstellung des Bootsplash verantwortlich.
## Es soll statt dem Standardtheme "xubuntu-plymouth-theme" das Thema 
## "plymouth-theme-solar" verwendet werden. Hierzu muss es installiert sein, 
## damit folgende Einstellung greifen kann. Der Ansatz über 
## update-alternatives --set default.plymouth /lib/plymouth/themes/solar/solar.plymouth
## funktioniert leider nicht beim Systemstart, daher wird stattdessen der 
## symbolische Link /etc/alternatives/default.plymouth auf das neue Ziel gesetzt.
## ( /lib/plymouth/themes/xubuntu-logo/xubuntu-logo.plymouth =>
##          /lib/plymouth/themes/solar/solar.plymouth )
## Zunächst wird aber mittels "readlink" überprüft ob der Link überhaupt
## noch geändert werden muss. Erst dannach wird die Änderung vorgenommen.
## vgl. http://wiki.ubuntuusers.de/Plymouth
##      http://linuxwiki.de/SymLink

# Ist das Thema vorhanden ?
if [ -f /lib/plymouth/themes/solar/solar.plymouth ]; then

	# readlink gibt die Datei aus auf die der symbolische Link zeigt.
	aktLink="$(readlink /etc/alternatives/default.plymouth)"

	if [ ! "$aktLink" == "/lib/plymouth/themes/solar/solar.plymouth" ]; then

		# Löschen des alten Links
		rm /etc/alternatives/default.plymouth
		# Erstellen eines neuen, der auf das gewünschte Thema zeigt.
		ln -s /lib/plymouth/themes/solar/solar.plymouth /etc/alternatives/default.plymouth

		# Nun werden die Aenderungen ins Bootimage geschrieben
		update-initramfs -u -k all 

	fi

else

	echo "PlymouthThemeAendern : Das Thema ist noch nicht installiert"
	LogEintragErstellen "PlymouthThemeAendern : Das Thema ist noch nicht installiert"

fi

unset aktLink

}


BenutzerSchuleAnlegen(){

## Hier wird der Benutzer schule mit all seinen Gruppen erstellt

if [ ! -d /home/schule ]; then

	# User "schule" anlegen
	adduser --gecos ',,,' --disabled-password schule

	# User "schule" mit den Standardgruppenzugehörigkeiten ausstatten
	usermod -a -G adm,dialout,fax,cdrom,floppy,tape,audio,dip,video,plugdev,fuse,netdev,nopasswdlogin schule

	# Passwort auf einen leer-String setzen
	usermod -p U6aMy0wojraho schule

	# Erlaubnis das Passwort erst nach 10000 Tagen ändern zu dürfen
	passwd -n 100000 schule

	echo "BenutzerSchuleAnlegen : Benutzer angelegt"
	LogEintragErstellen "BenutzerSchuleAnlegen : Benutzer angelegt"

	# Der Homeordner wird nun mit dem erstellten Archiv gefüllt
	Wiederherstellen schule

fi

}


KopiergeschuetzteDVDswiedergeben(){

## Es wird ein Skript ausgeführt, welches die Wiedergabe von
## kopierschutzbehafteten DVDs ermöglicht.
## vgl. http://wiki.ubuntuusers.de/Codecs

LogEintragErstellen "KopiergeschuetzteDVDswiedergeben : Skript wird ausgeführt"

/usr/share/doc/libdvdread4/install-css.sh

}


PaketlisteDeinstallieren(){

## Hier werden alle Pakete deinstalliert die Standardmäßig installiert
## werden, aber eigentlich nicht benötigt werden. Es werden hierzu
## alle Pakete, die in der Datei /etc/kioskmodus/removepackages.list
## hinterlegt sind, deinstalliert.
## vgl. http://wiki.ubuntuusers.de/Paketverwaltung/Tipps

if [ -f /usr/bin/pidgin ]; then

	if [ -f /etc/kioskmodus/removepackages.list ]; then

		LogEintragErstellen "PaketlisteDeinstallieren : Pakete entfernen"

		# Alle Pakete der Paketliste deinstallieren
		xargs -a "/etc/kioskmodus/removepackages.list" sudo apt-get -y remove

	fi

fi

}


PaketlisteInstallieren(){

## Hier werden die Pakete installiert, die benötigt werden.
## Es werden diese aus der Datei /etc/kioskmodus/packages.list
## eingelesen.
## vgl. http://wiki.ubuntuusers.de/Paketverwaltung/Tipps

if [ $1 == "erstellen" ]; then

# Hier wird die Datei packages.list erstellt.

	# Falls dei Datei bereits existiert , dann löschen
	if [ -f /etc/kioskmodus/packages.list ]; then
		rm /etc/kioskmodus/packages.list
	fi

	LogEintragErstellen "PaketlisteInstallieren : packages.list wird erstellt"
	echo "packages.list wird erstellt ..."

	# Alle Paketnamen in die Datei schreiben
	dpkg --get-selections | awk '!/deinstall|purge|hold/ {print $1}' > /etc/kioskmodus/packages.list 

else

# Hier werden die Pakete installiert.

	# Paketquellen aktualisieren
	apt-get update 

	if [ -f /etc/kioskmodus/packages.list ]; then

		# Medibuntu Keys importieren
		apt-get install medibuntu-keyring

		# Google earth key ( dl.google.com ) herunterladen
		apt-key adv --recv-keys --keyserver keyserver.ubuntu.com A040830F7FAC5991  

		# Alle Pakete der Paketliste installieren
		xargs -a "/etc/kioskmodus/packages.list" sudo apt-get install 

		# Kopiergeschützte DVDs wiedergeben
		KopiergeschuetzteDVDswiedergeben
	fi

fi

}


MIMEtypesSetzen(){

# Im Aufbau, noch nicht getestet

## Hier werden die Dateityp->Programm-Verknüpfungen erstellt

if [ -f /home/schule/.local/share/applications/mimeapps.list ]; then
	rm /home/schule/.local/share/applications/mimeapps.list
fi

cat <<-\$EOFE >/home/schule/.local/share/applications/mimeapps.list

[Default Applications]
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/ftp=firefox.desktop
x-scheme-handler/chrome=firefox.desktop
text/html=firefox.desktop
application/x-extension-htm=firefox.desktop
application/x-extension-html=firefox.desktop
application/x-extension-shtml=firefox.desktop
application/xhtml+xml=firefox.desktop
application/x-extension-xhtml=firefox.desktop
application/x-extension-xht=firefox.desktop
audio/x-vorbis+ogg=vlc.desktop
audio/x-musepack=vlc.desktop
audio/x-ms-wma=vlc.desktop
audio/x-wavpack=vlc.desktop
audio/x-ape=vlc.desktop
application/vnd.ms-wpl=vlc.desktop
audio/x-mpegurl=vlc.desktop
audio/mpeg=vlc.desktop
audio/x-wav=vlc.desktop

[Added Associations]
x-scheme-handler/http=firefox.desktop;
x-scheme-handler/https=firefox.desktop;
x-scheme-handler/ftp=firefox.desktop;
x-scheme-handler/chrome=firefox.desktop;
text/html=firefox.desktop;
application/x-extension-htm=firefox.desktop;/etc/kioskmodus
application/x-extension-html=firefox.desktop;
application/x-extension-shtml=firefox.desktop;
application/xhtml+xml=firefox.desktop;
application/x-extension-xhtml=firefox.desktop;
application/x-extension-xht=firefox.desktop;
audio/x-vorbis+ogg=vlc.desktop;
audio/x-musepack=vlc.desktop;
audio/x-ms-wma=vlc.desktop;
audio/x-wavpack=vlc.desktop;
audio/x-ape=vlc.desktop;
application/vnd.ms-wpl=vlc.desktop;
audio/x-mpegurl=vlc.desktop;
audio/mpeg=vlc.desktop;
audio/x-wav=vlc.desktop;

$EOFE

}


SicherheitsaktualisierungenAutomatischInstallieren(){

# Im Aufbau

## Es wird hier Aptitude aufgerufen, damit die Sicherheitsupdates automatisch installiert werden.
## vgl. http://wiki.ubuntuusers.de/aptitude#Automatische-Sicherheitsupdates-ohne-Interaktion

# Jeden Freitag, alle 10 minuten zwischen 13 Uhr und 23 Uhr
#Cronstring="*/10   13-23   * * 5 cp /pfad/zu/datei /pfad/zur/kopie"

httpServerIP=paketkoenig.localdomain
httpServerIP2=paketkoenig.local

ping -c 2 "$httpServerIP" > /dev/null 2>&1

# Server erreichbar ?
if [ "$?" = "0" ]
then
# Ist erreichbar, Anweisungen holen

	wget -P /tmp/ http://"$httpServerIP"/updateanweisungen

else

	ping -c 2 "$httpServerIP2" > /dev/null 2>&1
	if [ "$?" = "0" ];then
		wget -P /tmp/ http://"$httpServerIP2"/updateanweisungen	
	fi

fi

if [ -f /tmp/updateanweisungen ]; then

	source /tmp/updateanweisungen

fi

unset httpServerIP

}


LokaleSystemMailsAnMailAdresseWeiterleitenAktivieren(){

## Bei Problemen mit Hard- und Software schicken viele Linux-Programme
#  Mails an den lokalen Systemadministrator. Damit Sie diese züpgig sehen,
#  sollte das System die Mails an ihre normale E-Mail-Adresse weiterleiten.
#  Ohne expliziete Konfiguration werden die Mails aber nur an eine lokale
#  Mailbox verschickt die meist nie abgefragt wird.
#  Es muss in unserem Fall dafür gesorgt werden das alle Mails an
#  "smtp.ostsee-gymnasium.de:587" gehen. Außerdem muss eine Authentifizierung
#  am Smarthost stattfinden.
#  vgl. C'T 12 23.5.2011 S.186
#       http://wiki.ubuntuusers.de/Postfix
#       http://wiki.ubuntuusers.de/Postfix#Authentifizierung-am-Smarthost
#       http://wiki.ubuntuusers.de/Postfix#General-type-of-configuration



# Wenn der SMTP-Server auf dem Smarthost zum Versenden der Mail
# ein Passwort verlangt, dann muss in der Datei /etc/postfix/sasl_password
# eben dieses hinterlegt werden

if [ ! -f /etc/postfix/sasl_password ]; then

	# Server Benutzername:Passwort
	cat <<-\$EOFE >/etc/postfix/sasl_password
smtp.ostsee-gymnasium.de garunda@ostsee-gymnasium.de:ogtogt
$EOFE

	# Damit nicht jeder die Datei lesen kann werden die Rechte eingeschränkt.
	chmod 600 /etc/postfix/sasl_password

	# Generierung einer kompilierten Form der Datei. Diese ist schneller abfragbar
	postmap hash:/etc/postfix/sasl_password

fi

# Hier wird für korrekte Absender- und Empfängeradressen gesorgt.
if [ ! -f /etc/postfix/generic ]; then

	# Die erste Zeile spezifiziert die korrekte Absender- und Empfängeradresse
	# für root, die zweite für verwaltung, die dritte weist an, alle Mails mit
	# lokalen Empfängern, für die keine E-Mail-Adresse festgelegt wurde, an die
	# spezifizierte Adresse zu verschicken
	cat <<-\$EOFE >/etc/postfix/generic
root garunda@ostsee-gymnasium.de
verwaltung garunda@ostsee-gymnasium.de
@localhost.localdomain garunda@ostsee-gymnasium.de
$EOFE

	# Generierung einer kompilierten Form der Datei. Diese ist schneller abfragbar
	postmap /etc/postfix/generic

fi

# Konfiguration in der main.cf

# Sind die Zusatzoptionen schon vorhanden ?
String1="$(sed -n "/smtp_generic_maps = hash:\/etc\/postfix\/generic/p" /etc/postfix/main.cf )"

if [ ! "$String1" == "smtp_generic_maps = hash:/etc/postfix/generic" ]; then

	# Spezifikation der Datei die für korrekte Absender- und Empfängeradressen sorgt.
	echo "smtp_generic_maps = hash:/etc/postfix/generic" >> /etc/postfix/main.cf

	# Aktivierung der Verbindung über Transport Layer Securtity (TLS) und
	# die Autherntifizierung gegenüber dem Relayhost.
	echo "smtp_use_tls = yes" >> /etc/postfix/main.cf
	echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf
	echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf

	# Spezifikation des Pfades unter dem Postfix nach Root-CA-Zertifikaten sucht,
	# um mit ihnen die Authentizität der gegenstelle sicherzustellen.
	echo "smtpd_tls_CApath = /usr/share/ca-certificates/" >> /etc/postfix/main.cf

	# Es wird die Datei spezifiziert in der die Benutzerangaben stehen ( siehe oben )
	echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_password" >> /etc/postfix/main.cf

fi


# Es soll kein lokales Ziel für die Mails geben

# Die zu betrachtende Zeile isolieren
String2="$(sed -n "/mydestination =/p" /etc/postfix/main.cf )"

# Nachsehen welche Parameter gesetzt sind
if [ ! "$String2" == "mydestination = " ]; then

	# Parameter anpassen
	sed -e '/mydestination =/c\mydestination = ' main.cf > tmpmain.cf
	mv tmpmain.cf main.cf

fi


# Es sollen auch keine Verbindungen von anderen Rechnern angenommen werden

# Die zu betrachtende Zeile isolieren
String3="$(sed -n "/inet_interfaces =/p" /etc/postfix/main.cf )"

# Nachsehen welche Parameter gesetzt sind
if [ ! "$String3" == "inet_interfaces = loopback-only" ]; then

	# Parameter anpassen
	sed -e '/inet_interfaces =/c\inet_interfaces = loopback-only' /etc/postfix/main.cf > /tmp/kioskmodusLokaleMail
	mv /tmp/kioskmodusLokaleMail /etc/postfix/main.cf

fi


# Hier wird der Mailserver des Providers eintragen, über den man die Mail verschicken will, z.B. smtp.mailanbieter.de.

# Die zu betrachtende Zeile isolieren
String4="$(sed -n "/relayhost =/p" /etc/postfix/main.cf )"

# Nachsehen welche Parameter gesetzt sind
if [ ! "$String4" == "relayhost = smtp.ostsee-gymnasium.de:587" ]; then

	# Parameter anpassen
	sed -e '/relayhost =/c\relayhost = smtp.ostsee-gymnasium.de:587' /etc/postfix/main.cf > /tmp/kioskmodusLokaleMail
	mv /tmp/kioskmodusLokaleMail /etc/postfix/main.cf

fi


unset String1
unset String2
unset String3
unset String4

}


SuchenInDerShellHistoryAktivieren(){

## Hier wird das Gezielte Blättern in der Bash-History aktiviert.
#  Durch Drücken der Tasten Bild ↑ und Bild ↓ kann man die History 
#  der Bash anschließend nach Einträgen durchsuchen, welche mit
#  den Worten beginnen, die vor der aktuellen Cursorposition stehen.
#  Hierzu werden 2 Zeilen in der Datei "/etc/inputrc" einkommentiert
#  vgl. http://wiki.ubuntuusers.de/Bash#Gezieltes-Blaettern-in-der-History-aktivieren
## vgl. https://bbs.archlinux.org/viewtopic.php?id=115348

sed -i 's/^# "\\e\[5~": history-search-backward/"\\e\[5~": history-search-backward/;' /etc/inputrc
sed -i 's/^# "\\e\[6~": history-search-forward/"\\e\[6~": history-search-forward/;' /etc/inputrc

}


LibreOfficeExtensionGlobalInstallieren(){

# Muss getestet werden

## Hier werden die Extensions für alle Benutzer installiert.
## Zunächst wird hierfür überprüft ob sie vielleciht doch
## schon installiert sind. Wenn nicht, dann werden sie jetzt
## installiert.
#  vgl. http://www.ooowiki.de/Extension und manpage von unopkg
#  Es werden nur die folgenden Extensions installiert:
#	- Sun_ODF_Template_Pack_de
#	- Sun_ODF_Template_Pack2_de
#	- Italian and Latin spelling dictionaries 
#	  ( http://extensions.libreoffice.org/extension-center/italian-and-latin-spelling-dictionaries )

LogEintragErstellen "LibreOfficeExtensionGlobalInstallieren : Nun  werden die Extensions aufgelistet"

# Liste aller installierter Extensions in eine Datei schreiben
unopkg list --shared >> /tmp/KioskmodusLOExtension
IstInstalliert="yes"

# Nach den Extensions suchen
for file in /etc/kioskmodus/*.oxt ; do 

	fname=$( basename "$file")

	if ! grep -q "$fname" /tmp/KioskmodusLOExtension ; then

		echo "LibreOfficeExtensionGlobalInstallieren : "$fname" nicht installiert, installieren ..."
		LogEintragErstellen "LibreOfficeExtensionGlobalInstallieren : "$fname" nicht installiert, installieren ..."

		IstInstalliert="no"
		if [ -f "$file" ]; then

			# -s unterdrückt die Lizenzabsegnung, --shared installiert für alle Benutzer
			unopkg add -s --shared "$file"

		else

			echo "LibreOfficeExtensionGlobalInstallieren : "$fname" nicht vorhanden"
			LogEintragErstellen "LibreOfficeExtensionGlobalInstallieren : "$fname" nicht vorhanden"

		fi

	fi

done

if [ "$IstInstalliert" == "yes" ]; then

	echo "LibreOfficeExtensionGlobalInstallieren : alles schon installiert"
	LogEintragErstellen "LibreOfficeExtensionGlobalInstallieren : alles schon installiert"
	return

fi


unset IstInstalliert

if [ -f /tmp/KioskmodusLOExtension ]; then
	rm /tmp/KioskmodusLOExtension
fi

}


DateisystemUeberpruefungsRhythmusAendern(){

## Hier wird die Anzahl der mounts, zwischen denen eine Ueberpruefung stattfindet,
#  von dem Ursprünglichen Wert ( 30 ) auf 10 gesetzt. So fallen Fehler früher auf
#  vgl. http://wiki.ubuntuusers.de/Dateisystemcheck#berpruefungs-Rhythmus-aendern

# Der folgende Befehl stellt nun den Zeitpunkt der Überprüfung von jedem 
# 30. Systemstart auf jeden 60. Start um. Natürlich kann auch jede beliebige
# andere Zahl verwendet werden.

MaxMountCount="$(tune2fs -l /dev/sda1 | grep -i "Maximum mount count" | awk '{print $4}') "

if [ ! "10 " == "$MaxMountCount" ]; then

	tune2fs -c 10 /dev/sda1

fi

}


WakeOnLANAktivieren(){

## Hier wird das ferngesteuerte Anschalten der Recher ermöglicht.
#  vgl. http://wiki.ubuntuusers.de/Wake_on_LAN

# Eintrag in /etc/rc.local für die Ausführung des Befehls beim start des Rechners.

# Verwendete Netzwerkschnittstelle herausfinden

Netzwerkschnittstelle="$(ifconfig | awk '/eth/ { print $1 }') "  # == "eth1 "

# Gucken ob die Zeile schon existiert.

String1="$(sed -n "/ethtool -s ${Netzwerkschnittstelle}wol g/p" /etc/rc.local )"

# Falls nicht; hänge diese Zeile ans Dokument an.

if [ ! "$String1" == "ethtool -s ${Netzwerkschnittstelle}wol g"  ]; then
	sed -e "12a\ethtool -s ${Netzwerkschnittstelle}wol g" /etc/rc.local > /tmp/kioskmodusWOL
	mv /tmp/kioskmodusWOL /etc/rc.local
fi

unset String1

# halt skript anpassen, damit die Netzwerkschnittstelle nicht abgeschaltet wird

if [ ! -f /tmp/kioskmodusWOL ]; then
	cp /etc/init.d/halt /tmp/kioskmodusWOL
fi

sed -e 's/NETDOWN=yes/NETDOWN=no/' /tmp/kioskmodusWOL > /etc/init.d/halt

if [ -f /tmp/kioskmodusWOL ]; then
	rm /tmp/kioskmodusWOL
fi

}


DateisystemFehlerAutomatischKorrigieren(){

## Dateisystemfehler sollen automatisch beim Start korrigiert werden
#  vgl. http://wiki.ubuntuusers.de/Dateisystemcheck

if [ ! -f /tmp/kioskmodusrcS ]; then
	cp /etc/default/rcS /tmp/kioskmodusrcS
fi

sed -e 's/FSCKFIX=no/FSCKFIX=yes/' /tmp/kioskmodusrcS > /etc/default/rcS

# Nun sollte Ubuntu bei jedem Start eventuell vorhandene Dateisystemfehler automatisch korrigieren.

if [ -f /tmp/kioskmodusrcS ]; then
	rm /tmp/kioskmodusrcS
fi

}


NetbeansMenueeintragErstellen(){

## Erstellen einer netbeans.desktop in /usr/share/applications damit eine Menueverknüpfung erscheint

VerknuepfungsDatei="/usr/share/applications/netbeans.desktop"

if [ ! -f "$VerknuepfungsDatei" ]; then

	echo "[Desktop Entry]" > "$VerknuepfungsDatei"
	echo "Version=7.0.1" >> "$VerknuepfungsDatei"
	echo "Name=Netbeans" >> "$VerknuepfungsDatei"
	echo "Comment=design, implement, compile,... your programs" >> "$VerknuepfungsDatei"
	echo "Name[de]=Netbeans" >> "$VerknuepfungsDatei"
	echo "Comment[de]=Entwerfe, implementiere, compiliere,... deine Programme" >> "$VerknuepfungsDatei"
	echo "Exec=/opt/Netbeans_7.0.1/netbeans/bin/netbeans" >> "$VerknuepfungsDatei"
	echo "Icon=netbeans.png" >> "$VerknuepfungsDatei"
	echo "Terminal=false" >> "$VerknuepfungsDatei"
	echo "Type=Application" >> "$VerknuepfungsDatei"
	echo "Categories=Development;IDE;Java;" >> "$VerknuepfungsDatei"
	echo "StartupNotify=true" >> "$VerknuepfungsDatei"
fi

unset VerknuepfungsDatei

}


GoogleEarthMenueeintragErstellen(){

## Erstellen einer Googleearth6.desktop in /usr/share/applications damit eine Menueverknüpfung erscheint
# Das Google Earth entstammt dem Repository ( "http://www.ubuntuupdates.org/ppas/80")
VerknuepfungsDatei="/usr/share/applications/Googleearth6.desktop"

if [ ! -f "$VerknuepfungsDatei" ]; then

	echo "[Desktop Entry]" > "$VerknuepfungsDatei"
	echo "Version=6" >> "$VerknuepfungsDatei"
	echo "Name=Google Earth 6" >> "$VerknuepfungsDatei"
	echo "Comment=Explore, search and discover the planet" >> "$VerknuepfungsDatei"
	echo "Name[de]=Google Earth 6" >> "$VerknuepfungsDatei"
	echo "Comment[de]=Ansehen und Erkunden von Googles Satellitenbildern" >> "$VerknuepfungsDatei"
	echo "Exec=google-earth" >> "$VerknuepfungsDatei"
	echo "Icon=google-earth" >> "$VerknuepfungsDatei"
	echo "Terminal=false" >> "$VerknuepfungsDatei"
	echo "Type=Application" >> "$VerknuepfungsDatei"
	echo "Categories=AudioVideo;Player;" >> "$VerknuepfungsDatei"
	echo "StartupNotify=true" >> "$VerknuepfungsDatei"
fi

unset VerknuepfungsDatei

}


MediathekmenueeintragErstellen(){

## Erstellen einer Mediathek.desktop in /usr/share/applications damit eine Menueverknüpfung erscheint
VerknuepfungsDatei="/usr/share/applications/Mediathek.desktop"

if [ ! -f "$VerknuepfungsDatei" ]; then

	echo "[Desktop Entry]" > "$VerknuepfungsDatei"
	echo "Version=2.6.0" >> "$VerknuepfungsDatei"
	echo "Name=Mediathek" >> "$VerknuepfungsDatei"
	echo "Comment=Read, capture your ARD, ZDF, ... TV streams" >> "$VerknuepfungsDatei"
	echo "Name[de]=Mediathek" >> "$VerknuepfungsDatei"
	echo "Comment[de]=Wiedergabe und Aufnahme der Sendungen der öffentlich-rechtlichen Fernsehanstalten" >> "$VerknuepfungsDatei"
	echo "Exec=java -jar /opt/Mediathek_2.6.0/Mediathek.jar" >> "$VerknuepfungsDatei"
	echo "Icon=oxygen.png" >> "$VerknuepfungsDatei"
	echo "Terminal=false" >> "$VerknuepfungsDatei"
	echo "Type=Application" >> "$VerknuepfungsDatei"
	echo "Categories=AudioVideo;Player;" >> "$VerknuepfungsDatei"
	echo "StartupNotify=true" >> "$VerknuepfungsDatei"
fi

unset VerknuepfungsDatei

}


PaketQuellenAnpassen(){

## Hier werden die Paketquellen leserlich hergerichtet, 
## sodass sie schnell zu überschauen sind und außerdem werden sie
## auf den Netzwerkspiegel umgestellt.

SourcesList="/etc/apt/sources.list"

# Den Distributionscodenamen einlesen

. /etc/lsb-release

# Spiegel ja oder nein ?

if [ $1 == "online" ]; then
	Mirror="http://"
	echo "#### INTERNET ####" > "$SourcesList"
elif [ $1 == "offline" ]; then
	Mirror="http://paketkoenig.localdomain/mirror/"
	echo "#### PAKETKOENIG ####" > "$SourcesList"
else
	Mirror=false
fi

# Neue sources.list erzeugen

if [ ! $Mirror == false ]; then

	
	echo "" >> "$SourcesList"
	echo "## Ubuntu" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"de.archive.ubuntu.com/ubuntu/ "$DISTRIB_CODENAME" main restricted universe multiverse" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"de.archive.ubuntu.com/ubuntu/ "$DISTRIB_CODENAME"-updates main restricted universe multiverse" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"de.archive.ubuntu.com/ubuntu "$DISTRIB_CODENAME"-security main restricted universe multiverse" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "#deb "$Mirror"extras.ubuntu.com/ubuntu "$DISTRIB_CODENAME" main" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "## Remastersys" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"www.geekconnection.org/remastersys/repository lucid/" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "## Medibuntu" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"packages.medibuntu.org/ "$DISTRIB_CODENAME" free non-free" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "## Google Earth" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"dl.google.com/linux/earth/deb/ stable main" >> "$SourcesList"  # vgl. http://www.ubuntuupdates.org/ppas/80
	echo "" >> "$SourcesList"
	echo "## OGT Kioskmodus Repository" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb http://paketkoenig.localdomain/repository ./" >> "$SourcesList"
	echo "" >> "$SourcesList"

fi

# temporäre Variablen und Dateien löschen.

unset Mirror
unset SourcesList

if [ -f /tmp/kioskmodusPaketQuellenAnpassen ]; then
	rm /tmp/kioskmodusPaketQuellenAnpassen
fi

# Fehler: "W: Duplicate sources.list entry
#	http://dl.google.com/linux/earth/deb/ stable/main_binary-i386_Packages
#	(/var/lib/apt/lists/dl.google.com_linux_earth_deb_dists_stable_main_binary-i386_Packages)"
# Google Earth erstellt automatisch einen eigenen sources.list Eintrag in /etc/apt/sources.list.d
# Zur Fehlerbehebnung wird dieser Eintrag gelöscht / alle Dateien in /etc/apt/sources.list.d gelöscht.

if [ -f /etc/apt/sources.list.d/* ]; then
	rm /etc/apt/sources.list.d/*
fi

}


NTPZeitserverSynchronisationEinstellen(){

## Hier wird in der Datei "/etc/crontab" der Eintrag für die Synchronisation erstellt.
#  vgl. http://wiki.ubuntuusers.de/Systemzeit#NTP-korrigiert-nicht-die-Rechner-Uhrzeit

# Gucken ob die Zeile schon existiert.

#String1="$(sed -n '/12 \* \* \* \* root ntpdate 10.0.0.15 \&> \/dev\/null/p' /etc/crontab )"
String2="$(sed -n '/12 \* \* \* \* root ntpdate zeitserver.localdomain \&> \/dev\/null/p' /etc/crontab )"

# Falls nicht; hänge diese Zeile ans Dokument an.

#if [ ! "$String1" == "12 * * * * root ntpdate 10.0.0.15 &> /dev/null"  ]; then
#	sed -e '15a\12 * * * * root ntpdate 10.0.0.15 \&> /dev/null' /etc/crontab > /tmp/kioskmodusNTP  #/etc/crontab
#	cp /tmp/kioskmodusNTP /etc/crontab
#fi

if [ ! "$String2" == "12 * * * * root ntpdate zeitserver.localdomain &> /dev/null" ]; then
	sed -e '16a\12 * * * * root ntpdate zeitserver.localdomain &> /dev/null' /etc/crontab > /tmp/kioskmodusNTP #/etc/crontab
	cp /tmp/kioskmodusNTP /etc/crontab
fi

# Entfernen aller Zwischenspeicher

if [ -f /tmp/kioskmodusNTP ]; then
	rm /tmp/kioskmodusNTP
fi

#unset String1
unset String2

}


UpgradeBenachrichtigungDeaktivieren(){

## Hier wird die lästige Nachricht unterdrückt, die dadrauf hinweist, das eine neue Ubuntuversion erschienen ist.

# in der Datei /etc/update-manager/release-upgrades wird die Anweisung "normal" gegen "never" ausgetauscht.
# Dadurch wird nie nach einer neuen Ubuntuversion gesucht.

# sed kann nicht aus einer Datei lesen, wenn es darin schreiben soll, deshalb der Umweg über die Backup Datei.

if [ ! -f /etc/update-manager/release-upgrades.backup ]; then
	cp /etc/update-manager/release-upgrades /etc/update-manager/release-upgrades.backup
fi

sed -e 's/Prompt=normal/Prompt=never/' /etc/update-manager/release-upgrades.backup > /etc/update-manager/release-upgrades

}


KonfigurationsdateiErstellen(){

## Hier wird die Datei "kioskmodus.conf" erstellt, falls sie noch nicht vorhanden ist.

if [ ! -d /etc/kioskmodus ]; then
	mkdir /etc/kioskmodus
fi

if [ ! -f "$Config" ]; then

cat <<-\$EOFE >"$Config"
##########################################
## Die Config von dem Kioskmodusscript. ##
##########################################

## Upstart einrichten (datei noch nicht mit Leben gefüllt)
#Upstarteinrichtung off

## SysVinit Skriptstart beim booten einrichten
SysViniteinrichtung on

## Top Level Domain herausfinden ( z.B. ".local" )
LokaleTopLevelDomainHerausfinden

## xorg.conf kopieren
XorgSetzen on

# Wenn noch nicht geschehn wird hier der Benutzer Schule angelegt
BenutzerSchuleAnlegen

## Zur Bearbeitung des Homeverzeichnisses von schule,
# die Option auf Off setzen
MountAufs on

## Wiederherstellen des Homeverzeichnisses von schule
schule_rw_cleanup on

## Displaymanager Autologin vom User "schule" einrichten
#GDMAutoLogin
LightDMAutoLogin

##Auflösungseinstellungen im Terminal verfügbar machen
#Aufloesungsskripteinfuegen

## gPXE Menueeintrag in GRUB setzen
GRUBgPXE on

## Journalingmodus für das Dateisystem einstellen
Journaldateisystemverwenden 

## Deaktivierung des Infofensters für ein Upgrade
UpgradeBenachrichtigungDeaktivieren

## Uhrzeit automatisch syncronisieren
NTPZeitserverSynchronisationEinstellen

## PaketQuellen entweder die Offiziellen oder der Spiegel
#PaketQuellenAnpassen online
PaketQuellenAnpassen offline

## Menueeintraege für die Programme Mediathek und Google Earth
#MediathekmenueeintragErstellen
#GoogleEarthMenueeintragErstellen
#NetbeansMenueeintragErstellen

## Dateisystemfehler beim booten beheben
DateisystemFehlerAutomatischKorrigieren

## Mounts zwischen Dateisystemchecks verkürzen
DateisystemUeberpruefungsRhythmusAendern

# Wake on LAN aktivieren
WakeOnLANAktivieren

# Hier wird die Systemmailweiterleitung aktiviert
LokaleSystemMailsAnMailAdresseWeiterleitenAktivieren

# Hier wird der Displaymanagerhintergrund geändert
LightDMGreeterAendern

# PC automatisch ausschalten wenn es 1700 Uhr ist
PCAutoShutdown

# Hier wird das Standard-Plymouth-Thema durch ein spezielles ausgetauscht
PlymouthThemeAendern

# Hier wird überprüft, ob die Extensions schon installiert sind
# Falls nicht werden sie installiert.
LibreOfficeExtensionGlobalInstallieren

# Durch drücken der Bild hoch/unter Tasten in der Shellhistory suchen
SuchenInDerShellHistoryAktivieren

# Es werden alle überflüssigen Pakete deinstalliert
PaketlisteDeinstallieren

## Dateiprogrammverknüpfungen anpassen
#MIMEtypesSetzen

## Die Sicherheitsaktualisierungen automatisch installieren, wenn
## Auf dem Server die Anweisungen liegen.
#SicherheitsaktualisierungenAutomatischInstallieren

## GRUB mit Passwort versehen ( noch nicht vollständig implementiert )
#GRUBabsichern off

## Nummernblockaktivierung einrichten
#Nummernblockaktivierung on

$EOFE

fi

}


## Die Hilfe ##

Hilfe(){

echo -e "\033[49;1;31m kioskmodus.sh                 \033[49;1;33m >> \033[49;1;32m Führt die in der Conf festgelegten Operationen durch \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh erstellen / -e  \033[49;1;33m >> \033[49;1;32m erstellt ein neues Archiv \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh löschen / -l    \033[49;1;33m >> \033[49;1;32m löscht alle alten Archive \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh --install       \033[49;1;33m >> \033[49;1;32m Verwandelt das System in ein System mit kioskmodus \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh hilfe / --help  \033[49;1;33m >> \033[49;1;32m öffnen die Hilfe \033[0m"
echo -e "\033[49;1;31m $Instpfad \033[0m"
echo -e "\033[49;1;31m "$Config" \033[49;1;33m >> Die Konfigurationsdatei \033[0m"
echo -e "\033[49;1;31m "$LogDatei"           \033[49;1;33m >> Die Logdatei \033[0m"

}
# Der Grundbefehl für die Farbe in der Konsole lautet
#echo -e "\033[49;1;31m TESTAUSGABE \033[49;1;33m PFEILE \033[49;1;32m BUNT  \033[0m"


## Parameterauswertung ##

case $1 in
	"start"|"")
	KonfigurationsdateiErstellen
	LogEintragErstellen "Parameterauswertung : Beginn der Ausführung der Konfiguarationsdatei"
	source "$Config"
	LogEintragErstellen "Parameterauswertung : Ende der Ausführung der Konfiguarationsdatei"
	;;
	"erstellen"|"-e") ## Hier werden alle Dinge für die Paketierung erstellt, hierzu muss das Image soweit fertig sein
	PaketlisteInstallieren erstellen
	Erstellen
	;;
	"löschen"|"-l") # Hiermit kann man erstellte Archive löschen
	Loeschen
	;;
	"hilfe"|"--help"|"-h"|"--hilfe")
	Hilfe
	;;
	"RandR")
	RandRstatischeAufloesung
	;;
	"gpxe")
	GRUBgPXE on
	;;
	"-t"|"test")
	PlymouthThemeAendern
	;;
	"-v") # wird nach dem Login ausgeführt
	VideoAusgangHerausfinden
	;;
	"-S")
	SicherheitsupdatesEinspielenUndHerunterfahren
	;;
	"--SuchenInDerShellHistoryAktivieren")
	SuchenInDerShellHistoryAktivieren
	;;
	"--PaketQuellenAnpassen_online")
	PaketQuellenAnpassen online
	;;
	"--PaketQuellenAnpassen_offline")
	PaketQuellenAnpassen offline
	;;
	"--NTPZeitserverSynchronisationEinstellen")
	NTPZeitserverSynchronisationEinstellen
	;;
	"--LightDMAutoLogin")
	LightDMAutoLogin
	;;
	"--WakeOnLANAktivieren")
	WakeOnLANAktivieren
	;;
	"--KopiergeschuetzteDVDswiedergeben")
	KopiergeschuetzteDVDswiedergeben
	;;
	"--Autostarteinrichten")
	SysViniteinrichtung on
	;;
	"entwicklung") # Hier wird alles durchgeführt was am Anfang der Erstellung eines neues Images durchgeführt werden sollte
##	PaketQuellenAnpassen online
#	BenutzerSchuleAnlegen
#	MIMEtypesSetzen
	;;
	"--install") # Dies wird direkt nach der Installation ausgeführt, damit auch alles installiert wird
#	apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 82BA8E0F # Der Schlüssel von garunda; nicht nötig ( kioskmodus-keyring )
	Wiederherstellen verwaltung
	SysViniteinrichtung on
	KopiergeschuetzteDVDswiedergeben # Muss einmal ausgeführt werden
	Beepen # Beepen nach Beendigung des Prozesses
	;;
	*)
	echo "$1 ist ein falsches Parameter"
	exit
	;;
esac


## exit :)>-
exit
