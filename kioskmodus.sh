c#!/bin/bash
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
Config="/etc/kioskmodus/kioskmodus.conf"

if [ -f /etc/kioskmodus/aufloesung ]; then
	Aufloesung=`cat /etc/kioskmodus/aufloesung`
else
	echo "1024x768" > /etc/kioskmodus/aufloesung
fi
Ausgang="none"

Beepen(){

# Nette Beeptöne von sich geben

# Das modul laden
modprobe -v pcspkr

beep -f 659 -l 460 -n -f 784 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 880 -l 230 -n -f 659 -l 230 -n -f 587 -l 230 -n -f 659 -l 460 -n -f 988 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 1047-l 230 -n -f 988 -l 230 -n -f 784 -l 230 -n -f 659 -l 230 -n -f 988 -l 230 -n -f 1318 -l 230 -n -f 659 -l 110 -n -f 587 -l 230 -n -f 587 -l 110 -n -f 494 -l 230 -n -f 740 -l 230 -n -f 659 -l 460

}


SysViniteinrichtung(){

if [ $1 == "on" ]; then

## Verlinkung des Skriptes nach /etc/rc0.d
# Das Skript wird hierdurch beim Hochfahren ausgeführt

#	if ([ ! -f /etc/rcS.d/S60kioskmodus ] && [ ! -f /etc/rcS.d/S60* ]); then
	if [ ! -f /etc/rcS.d/S10kioskmodus ]; then
		ln -s "$Instpfad"/kioskmodus.sh /etc/rcS.d/S10kioskmodus
	fi

	if [ ! -f /etc/gdm/PostLogin/Default ]; then
		echo "#!/bin/sh" > /etc/gdm/PostLogin/Default
		echo ""$Instpfad"/kioskmodus.sh -v" >> /etc/gdm/PostLogin/Default
		chmod a+x /etc/gdm/PostLogin/Default
	elif [ -f /etc/gdm/PostLogin/Default ]; then
		echo "test"
		if [ ! "$(cat  /etc/gdm/PostLogin/Default | egrep "*"$Instpfad"/kioskmodus.sh*" | awk '{print $1}' )" == ""$Instpfad"/kioskmodus.sh" ]; then
		echo "test2"
		echo ""$Instpfad"/kioskmodus.sh -v" >> /etc/gdm/PostLogin/Default
		fi
	fi

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

# Hier wird das Homeverzeichnis Schreibgeschützt

if [ $1 == "on" ]; then

	if [ -d /home/schule ]; then

		# Testen ob die Verzeichnisse existieren
		if [ ! -d /home/.schule_rw ]; then

			# ansonsten erstellen des Verzeichnisses
			install -d -o schule -g schule /home/.schule_rw
		fi
		# Sind Hardlinks erlaubt ?
		Hardlinkserlauben

		# Wenn angeschaltet, dann verglase das Homeverzeichnis

		mount -t aufs -o br:/home/.schule_rw/:/home/schule/ none /home/schule
	
	fi

else
	return
fi

}

MountAufsEintraginFstab(){

## Eintrag für das Uiondateisystem in der fastab anlegen,
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
	echo "nein"	
#	fi
echo "ja"
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

## Hier wird die menuedateieigefügt

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

}


GRUBgPXE(){

## Einrichten eines GRUB eintrages für gPXE Boot

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
		echo ""
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


GDMAutoLogin(){

## Kopieren der custom.conf von GDM in den GDM Ordner

# veraltet
#	cp "$Instpfad"/gdm/custom.conf /etc/gdm/custom.conf

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


#SSHKeysKopieren(){


#if [ $1 == "on" ]; then

## Kopieren der SSH-Keys für den SSH-Server

#	if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
#		cp "$Instpfad"/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key
#	fi

#	if [ ! -f /etc/ssh/ssh_host_dsa_key.pub ]; then
#		cp "$Instpfad"/ssh/ssh_host_dsa_key.pub /etc/ssh/ssh_host_dsa_key.pub
#	fi

#	if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
#		cp "$Instpfad"/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
#	fi
#
#	if [ ! -f /etc/ssh/ssh_host_rsa_key.pub ]; then
#		cp "$Instpfad"/ssh/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub
#	fi

#fi

#}

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
	if [ -f /home/schule/.aufloesung ]; then
		rm /home/schule/.aufloesung
	fi
elif [ -f /home/verwaltung/.aufloesung ]; then
	Aufloesung=`cat /home/verwaltung/.aufloesung`
	echo "$Aufloesung" > /etc/kioskmodus/aufloesung
	rm /home/verwaltung/.aufloesung
	if [ -f /home/schule/.aufloesung ]; then
		rm /home/schule/.aufloesung
	fi
elif [ -f /home/schule/.aufloesung ]; then
	Aufloesung=`cat /home/schule/.aufloesung`
	echo "$Aufloesung" > /etc/kioskmodus/aufloesung
	rm /home/schule/.aufloesung
fi


## Kopieren der xorg.conf in X11

if [ $1 == "on" ]; then

		if [ "$Aufloesung" == "1024x768" ]; then
			xorgeinfügenXGA
		elif [ "$Aufloesung" == "1280x1024" ]; then
			xorgeinfügenSXGA
		fi
		RandRstatischeAufloesung

elif [ $1 == "off" ]; then
	if [ -f /etc/X11/xorg.conf ]; then
		rm /etc/X11/xorg.conf
	fi
fi

}


Wiederherstellen(){

## VERALTET


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


Aufloesungsskripteinfuegen(){

## Einfügen der Datei in /usr/bin/
## Hierdurch kann man komfortabel die Auflösung ändern

if [ ! -f /usr/bin/aufloesungeinstellen ]; then

# Die Datei aufloesungeinstellen erzeugen mit dem angegegbenen Inhalt

#backup /root/cleanup-keinpasswort.sh
cat <<-\$EOFE >/usr/bin/aufloesungeinstellen
	#!/bin/bash

##Aufloesung einstellen mittels Dialog

#Abfrage nach der Aufloesung mit Hilfe einer Radiobox
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

# Dateisystemeigenschaften auflisten, Zeile ausfiltern und Option abtrennen.

Defaultmountoption="$(tune2fs -l /dev/sda1 | egrep "*Default mount options*" | awk '{print $4}' )"

# Überprüfen ob als "Default mount options" "journal_data" gesetzt ist. 

if [ ! $Defaultmountoption == "journal_data" ]; then

	# Dateisystem auf Journaling stellen
	tune2fs -o journal_data /dev/sda1

fi

unset Defaultmountoption

}


Erstellen(){

## MUSS ANGEPASST WERDEN

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
	if [ "$Loeschen" == "yes" ]; then

		rm "$Instpfad"/Archive/1024x768/schule2*
		rm "$Instpfad"/Archive/1280x1024/schule2*
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


DateisystemUeberpruefungsRhythmusAendern(){

## Hier wird die Anzahl der mounts zwischen denen eine Ueberpruefung stattfindet 
#  von dem Ursprünglichen Wert ( 30 ) auf 10 gesetzt. So fallen Fehler früher auf

# Der folgende Befehl stellt nun den Zeitpunkt der Überprüfung von jedem 
# 30. Systemstart auf jeden 60. Start um. Natürlich kann auch jede beliebige
# andere Zahl verwendet werden.

MaxMountCount="$(tune2fs -l /dev/sda1 | grep -i "Maximum mount count" | awk '{print $4}') "

if [ ! "10 " == "$MaxMountCount" ]; then
	
	tune2fs -c 10 /dev/sda1

fi

}


WakeOnLANAktivieren(){

## Hier wird das Ferngesteruerte Anschalten der Recher ermöglicht.

# Eintrag in /etc/rc.local für die Ausführung des Befehls beim start des Rechners.

# Gucken ob die Zeile schon existiert.

Netzwerkschnittstelle="eth0"
String1="$(sed -n '/ethtool -s '${Netzwerkschnittstelle}' wol g/p' /etc/rc.local )"

# Falls nicht; hänge diese Zeile ans Dokument an.

if [ ! "$String1" == "ethtool -s ${Netzwerkschnittstelle} wol g"  ]; then
	sed -e '12a\ethtool -s '${Netzwerkschnittstelle}' wol g' /etc/rc.local > /tmp/kioskmodusWOL
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

if [ ! -f /tmp/kioskmodusrcS ]; then
	cp /etc/default/rcS /tmp/kioskmodusrcS
fi

sed -e 's/FSCKFIX=no/FSCKFIX=yes/' /tmp/kioskmodusrcS > /etc/default/rcS

# Nun sollte Ubuntu bei jedem Start eventuell vorhandene Dateisystemfehler automatisch korrigieren.

if [ -f /tmp/kioskmodusrcS ]; then
	rm /tmp/kioskmodusrcS
fi

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
	echo "Version=2.5.0" >> "$VerknuepfungsDatei"
	echo "Name=Mediathek" >> "$VerknuepfungsDatei"
	echo "Comment=Read, capture your ARD, ZDF, ... TV streams" >> "$VerknuepfungsDatei"
	echo "Name[de]=Mediathek" >> "$VerknuepfungsDatei"
	echo "Comment[de]=Wiedergabe und Aufnahme der Sendungen der öffentlich-rechtlichen Fernsehanstalten" >> "$VerknuepfungsDatei"
	echo "Exec=java -jar /opt/Mediathek_2.5.0/Mediathek.jar" >> "$VerknuepfungsDatei"
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
## sodass sie schnell zu überschauen sind und außeredm werden sie
## auf den Netzwerkspiegel umgestellt.

SourcesList="/etc/apt/sources.list"

# Den Distributionscodenamen herausfinden

awk '/DISTRIB_CODENAME/ { print $1 }' /etc/lsb-release > /tmp/kioskmodusPaketQuellenAnpassen

DistributionsCodeName="$(sed s/DISTRIB_CODENAME=//g /tmp/kioskmodusPaketQuellenAnpassen )"

# Spiegel ja oder nein ?

if [ $1 == "online" ]; then
	Mirror="http://"
	echo "#### INTERNET ####" > "$SourcesList"
elif [ $1 == "offline" ]; then
	Mirror="ftp://paketkoenig.local/mirror/"
	echo "#### PAKETKOENIG ####" > "$SourcesList"
else
	DistributionsCodeName=false
fi

# Neue sources.list erzeugen

if [ ! $DistributionsCodeName == false ]; then

	
	echo "" >> "$SourcesList"
	echo "## Ubuntu" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"de.archive.ubuntu.com/ubuntu/ "$DistributionsCodeName" main restricted universe multiverse" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"de.archive.ubuntu.com/ubuntu/ "$DistributionsCodeName"-updates main restricted universe multiverse" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"security.ubuntu.com/ubuntu "$DistributionsCodeName"-security main restricted universe multiverse" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"extras.ubuntu.com/ubuntu "$DistributionsCodeName" main" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "## Remastersys" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"www.geekconnection.org/remastersys/repository karmic/" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "## Medibuntu" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"packages.medibuntu.org/ "$DistributionsCodeName" free non-free" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "## Google Earth" >> "$SourcesList"
	echo "" >> "$SourcesList"
	echo "deb "$Mirror"dl.google.com/linux/earth/deb/ stable main" >> "$SourcesList"
	echo "" >> "$SourcesList"

fi

# temporäre Variablen und Dateien löschen.

unset Mirror
unset DistributionsCodeName
unset SourcesList

if [ -f /tmp/kioskmodusPaketQuellenAnpassen ]; then
	rm /tmp/kioskmodusPaketQuellenAnpassen
fi

}


NTPZeitserverSynchronisationEinstellen(){

## Hier wird in der Datei "/etc/crontab" der Eintrag für die Synchronisation erstellt.

# Gucken ob die Zeile schon existiert.

String1="$(sed -n '/12 \* \* \* \* root ntpdate 10.0.0.15 \&> \/dev\/null/p' /etc/crontab )"
String2="$(sed -n '/12 \* \* \* \* root ntpdate zeitserver.local \&> \/dev\/null/p' /etc/crontab )"

# Falls nicht; hänge diese Zeile ans Dokument an.

if [ ! "$String1" == "12 * * * * root ntpdate 10.0.0.15 &> /dev/null"  ]; then
	sed -e '15a\12 * * * * root ntpdate 10.0.0.15 \&> /dev/null' /etc/crontab > /tmp/kioskmodusNTP  #/etc/crontab
	cp /tmp/kioskmodusNTP /etc/crontab
fi

if [ ! "$String2" == "12 * * * * root ntpdate zeitserver.local &> /dev/null" ]; then
	sed -e '16a\12 * * * * root ntpdate zeitserver.local &> /dev/null' /etc/crontab > /tmp/kioskmodusNTP #/etc/crontab
	cp /tmp/kioskmodusNTP /etc/crontab
fi

# Entfernen aller Zwischenspeicher

if [ -f /tmp/kioskmodusNTP ]; then
	rm /tmp/kioskmodusNTP
fi

unset String1
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

## xorg.conf kopieren
XorgSetzen on

## Zur Bearbeitung des Homeverzeichnisses von schule,
# die Option auf Off setzen
MountAufs on

## Wiederherstellen des Homeverzeichnisses von schule
Wiederherstellen off
schule_rw_cleanup on

## GDM Autologin vom User "schule" einrichten
GDMAutoLogin

##Auflösungseinstellungen im Terminal verfügbar machen
Aufloesungsskripteinfuegen

## gPXE Menueeintrag in GRUB setzen
GRUBgPXE on

## Journalingmodus für das Dateisystem einstellen
Journaldateisystemverwenden 

## Deaktivierung des Infofensters für ein Upgrade
UpgradeBenachrichtigungDeaktivieren

## Uhrzeit automatisch syncronisieren
NTPZeitserverSynchronisationEinstellen

## PaketQuellen entweder die Offiziellen oder der Spiegel
PaketQuellenAnpassen online
#PaketQuellenAnpassen offline

## Menueeintraege für die Programme Mediathek und Google Earth
MediathekmenueeintragErstellen
GoogleEarthMenueeintragErstellen

## Dateisystemfehler beim booten beheben
DateisystemFehlerAutomatischKorrigieren

## Mounts zwischen Dateisystemchecks verkürzen
DateisystemUeberpruefungsRhythmusAendern

# Wake on LAN aktivieren
WakeOnLANAktivieren

## GRUB mit Passwort versehen ( noch nicht vollständig implementiert )
#GRUBabsichern off

## SSH-Keys kopieren
#SSHKeysKopieren on   ## Zum entfernen deaktiviert

## Nummernblockaktivierung einrichten
#Nummernblockaktivierung on

$EOFE

fi

}


## Die Hilfe ##

Hilfe(){

echo -e "\033[49;1;31m kioskmodus.sh                 \033[49;1;33m >> \033[49;1;32m stellt das homeverzeichnis wieder her \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh erstellen / -e  \033[49;1;33m >> \033[49;1;32m erstellt ein neues Archiv \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh löschen / -l    \033[49;1;33m >> \033[49;1;32m löscht alle alten Archive \033[0m"
echo -e "\033[49;1;31m kioskmodus.sh hilfe / --help  \033[49;1;33m >> \033[49;1;32m öffnen die Hilfe \033[0m"
echo -e "\033[49;1;31m $Instpfad \033[0m"
echo -e "\033[49;1;31m "$Config" ist die Konfigurationsdatei \033[0m"

}
# Der Grundbefehl für die Farbe in der Konsole lautet
#echo -e "\033[49;1;31m TESTAUSGABE \033[49;1;33m PFEILE \033[49;1;32m BUNT  \033[0m"


## Parameterauswertung ##

case $1 in
	"start"|"")
	KonfigurationsdateiErstellen
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
	"RandR")
	RandRstatischeAufloesung
	;;
	"gpxe")
	GRUBgPXE on
	;;
	"-t"|"test")
	GRUBgPXE on
	;;
	"-v")
	VideoAusgangHerausfinden
	;;
	*)
	echo "$1 ist ein falsches Parameter"
	exit
	;;
esac


## exit :)>-
exit