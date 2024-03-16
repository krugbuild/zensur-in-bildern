#!/bin/bash
#
# Das Skript ruft eine angegebene Wikipedia-Artikelgeschichte ab und speichert neben der unveränderten HTML-Datei auch eine auf Kennwerte reduzierte und vom HTML freigestellte XML.
# Für den zweiten Schritt ist es notwendig, dass sich die Transformationsdatei (i.d.R. history.xsl) im Skriptverzeichnis befindet.
#
# Parameter:
#			-u 		(optional) Abzurufende URL. Jede URL ist valide, die Transformation ist jedoch nur auf die Versionsgeschichten der Wikipedia ausgelegt. Bei fehlender Eingabe wird URL zur Laufzeit abgefragt.
#			-v		(optional) Arbeitsverzeichnis. Legt einen definierten Unterordner an und speichert dort die zu erzeugenden Dateien.
#
# Autor: 		Alexandra Krug
# Lizenz: 		CC BY 3.0 DE Dieses Werk ist lizenziert unter einer Creative Commons Namensnennung 3.0 Deutschland Lizenz. (http://creativecommons.org/licenses/by/3.0/de/)
# Stand:		2020-01-27

echo "\n### getHistory.sh - Stand 2020-01-27 - Initialisierung.."

## Variablendefinition
	stylesheet="history.xsl"		# XSLT, muss für Transformation vorhanden sein
	htmlFile="historyData.html"		# Zieldatei für das HTML-Abbild
	xmlFile="historyData.xml"		# Zieldatei für die XML-Datei
	logFile="historyData_log.txt"	# Zieldatei für das Log
	verzeichnis="false"			# Arbeitsverzeichnis für die zu erstellenden Dateien
	url="false"					# URL zur abzurufenden Versionsgeschichte

## Parameter übergeben
	while getopts u:v: option; do
		case "${option}" in
			
			u) url=${OPTARG};;
			v) verzeichnis=${OPTARG};;
		
		esac
	done
	
## Pfadvariablen anpassen und Arbeitsverzeichnis anlegen - sofern angegeben
	if [ $verzeichnis != "false" ]; then
		
		mkdir -p ./$verzeichnis
		htmlFile=$verzeichnis/$htmlFile
		xmlFile=$verzeichnis/$xmlFile
		logFile=$verzeichnis/$logFile
	fi

uname -s -r -v -m >> $logFile	# initialer logFile-Eintrag mit Systeminformationen
echo $(date) "getHistory.sh - start" >> $logFile
echo "definiertes Arbeitsverzeichnis=" $verzeichnis

## Prüfung auf Transformationsschema - ohne wird kein Transformationsversuch unternommen
	if [ -f "$stylesheet" ]; then

		echo "-> Schemadatei" $stylesheet "gefunden." >> $logFile
	
	else
		
		echo "-> Schemadatei" $stylesheet "wurde nicht gefunden." >> $logFile
		stylesheet="false"
		
	fi

## Prüfung auf URL - wenn false, wird eine Eingabe verlangt
	if [ $url = "false" ]; then
	
		echo "\nBitte fuegen Sie die parametrisierte URL der zu verarbeitenden Wikipedia-Versionsgeschichte ein. Achten Sie auf eine sinnvolle Groesse des Parameters &limit.\n"
		read url
	
	fi
	
echo "-> URL zur Verarbeitung:" $url "\n" >> $logFile

## Abruf der HTML via wget ("-a" append logfile, "-O" Zieldatei)
	
	wget -a $logFile -O $htmlFile $url

echo "\nDas HTML-Abbild wurde als" $htmlFile "gespeichert."

## Transformation via xsltproc und Schemadatei
	if [ $stylesheet != "false" ]; then

		echo "XSLT wird angewendet.."
		echo "-> Schemadatei wird mittels xsltproc angewendet" >> $logFile
		
		xsltproc -v -o $xmlFile $stylesheet $htmlFile
		
		echo "\nBerenigte Daten wurden als" $xmlFile "gespeichert."
		echo "-> Auswertung wurde nach" $xmlFile "geschrieben." >> $logFile
	
	fi

echo $(date) "getHistory.sh - end\n" >> $logFile
