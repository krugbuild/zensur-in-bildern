#!/bin/bash
#
# Das Skript ruft eine angegebene Wikipedia-Artikelgeschichte ab und speichert neben der unveränderten HTML-Datei auch eine auf Kennwerte reduzierte und vom HTML freigestellte XML.
# Für den zweiten Schritt ist es notwendig, dass sich die Transformationsdatei >history.xsl< im Skriptverzeichnis befindet.
#
# Autor: 	Stefan Krug
# Stand:	2020-01-09

echo "\n### getHistory.sh - Stand 2020-01-09 - Initialisierung.."

## Parameterdefinition
stylesheet="history.xsl"		# XSLT, muss für Transformation vorhanden sein
htmlFile="historyData.html"		# Zieldatei für das HTML-Abbild
xmlFile="historyData.xml"		# Zieldatei für die XML-Datei
logFile="historyData_log.txt"	# Zieldatei für das Log
url=""						# URL zur abzurufenden Versionsgeschichte

uname -s -r -v -m >> $logFile	# initialer logFile-Eintrag mit Systeminformationen
echo $(date) "getHistory.sh - start" >> $logFile

## 1. Prüfung auf history.xsl
if [ -f "$stylesheet" ];then
	echo "Schemadatei" $stylesheet "gefunden."
else
	echo "Schemadatei" $stylesheet "wurde nicht gefunden. Transformationsfunktion deaktiviert."
	stylesheet="false"
fi

## 2. Eingabeaufforderung für URL
echo "\nBitte fuegen Sie die parametrisierte URL der zu verarbeitenden Wikipedia-Versionsgeschichte ein. Achten Sie auf eine sinnvolle Groesse des Parameters &limit.\n"
read url
echo "\nDie URL \""$url"\" wird verarbeitet.."
echo "-> URL zur Verarbeitung:" $url "\n" >> $logFile

# 3. Abruf der HTML via wget ("-a" append logfile, "-O" Zieldatei)
wget -a $logFile -O $htmlFile $url

echo "\nDas HTML-Abbild wurde als" $htmlFile "gespeichert."

# 4. transformation via xsltproc (if 1.)
if [ $stylesheet != "false" ]; then
	echo "XSLT wird angewendet.."
	echo "-> xsltproc wird ausgefuehrt" >> $logFile
	xsltproc -v -o $xmlFile $stylesheet $htmlFile
	echo "\nBerenigte Daten wurden als" $xmlFile "gespeichert."
	echo "-> Auswertung wurde nach" $xmlFile "geschrieben." >> $logFile
fi

echo $(date) "getHistory.sh - end\n" >> $logFile