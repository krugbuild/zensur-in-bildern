#!/bin/bash
#
# Das Skript ermittelt aus `articleData.xml`-Dateien sämtliche Bilder und speichert deren Metadaten als XML-Datei.
# Es können belibig viele Dateien im Format `articleData[n].xml` eingelesen werden, wobei `[n]` eine natürliche Zahl sein muss. 
# Die erste Datei einer Serie muss stets `articleData.xml` heißen und alle folgenden müssen aufsteigend nummeriert werden.
# Über den Parameter `-v` kann ein Arbeitsverzeichnis realtiv zum Skriptverzeichnis angegeben werden.
# Die Ermittlung der auszulesenden Dateien beschränkt sich auf das unmittelbare Arbeitsverzeichnis.
#
# Parameter:
#			-v		(optional) Arbeitsverzeichnis. Legt einen definierten Unterordner an und speichert dort die zu erzeugenden Dateien.
#
# Autor: 		Alexandra Krug
# Lizenz: 		CC BY 3.0 DE Dieses Werk ist lizenziert unter einer Creative Commons Namensnennung 3.0 Deutschland Lizenz. (http://creativecommons.org/licenses/by/3.0/de/)
# Stand:		2020-01-27

echo "\n### getImageTable.sh - Stand 2020-01-27 - Initialisierung.."

## Variablendefinition
	articleXML="articleData.xml" 	# Quelldatei für XSL-Transformation - der Dateiname ist als static zu betrachten
	imagesXML="imageData.xml"		# Zieldatei, wird duch XSLT generiert
	logFile="imageData_log.txt"		# Zielpfad für das Log
	stylesheet="images.xsl"			# Schemadatei zur XSL-Transformation
	verzeichnis="false"			# Arbeitsverzeichnis für die zu lesenden und zu erstellenden Dateien, default "false"

## Parameter übergeben
	while getopts v:n option; do
		case "${option}" in
			
			v) verzeichnis=${OPTARG};;
			
		esac
	done
	
## Pfadvariablen anpassen und Arbeitsverzeichnis anlegen - sofern angegeben
	if [ $verzeichnis != "false" ]; then
		
		mkdir -p ./$verzeichnis
		articleXML=$verzeichnis/$articleXML
		imagesXML=$verzeichnis/$imagesXML
		logFile=$verzeichnis/$logFile
	
	fi
	
uname -s -r -v -m >> $logFile		# initialer logFile-Eintrag mit Systeminformationen
echo $(date) "getImage.sh - start" >> $logFile
echo "-> definiertes Arbeitsverzeichnis= $verzeichnis" >> $logFile

## Anzahl an Quell-Dateien  ermitteln
	count=$(eval 'find $verzeichnis -maxdepth 1 -name "articleData*.xml" | wc -l')
	count=$((count - 1))
	
## Transformation via xsltproc und Schemadatei, um Quelldatei zu erzeugen
	if [ $stylesheet != "false" ]; then

		echo "XSLT wird angewendet.."
		echo "-> Schemadatei $stylesheet wird angewendet" >> $logFile
		
		$(xsltproc -v -o $imagesXML -param count $count -stringparam directory $verzeichnis $stylesheet $articleXML)
		
		echo "\n Daten wurden als $imagesXML gespeichert."
		echo "-> Auswertung wurde nach $imagesXML geschrieben." >> $logFile
	
	fi
	
echo $(date) "getImage.sh - end" >> $logFile
