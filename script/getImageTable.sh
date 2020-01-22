#!/bin/bash
#
# Das Skript legt eine HTML-Tabelle an, in der alle aus der Quelldatei ermittelten Bilder allen Artikelversionen gegen�bergestellt werden.
# Aus dieser Tabelle l�sst sich somit die Entwicklung der Verwendung einzelner Bilder �ber den definierten Versionsverlauf nachvollziehen.
# Zur Pr�fung gegenden Bildbestand werden zun�chst alle einzigartigen (unique) Bilder ermittelt, diese werden anhand der URL identifiziert.
# Auch beim Vergleich der Artikelversionen mit der Bildliste wird �ber die URL gepr�ft.
#
# Parameter:
#			-v		(optional) Arbeitsverzeichnis. Legt einen definierten Unterordner an und speichert dort die zu erzeugenden Dateien.
#
# Autor: 	Stefan Krug
# Stand:	2020-01-22

echo "\n### getImageTable.sh - Stand 2020-01-22 - Initialisierung.."

## Variablendefinition
	htmlFile="imageTable.html"	# Zieldatei
	logFile="imageTable_log.txt"	# Zielpfad f�r das Log
	imagesXML="images.xml"	# Quelldatei
	imageList=""				# Variable, um auszuwertende Liste vorzuhalten
	verzeichnis="false"		# Arbeitsverzeichnis f�r die zu lesenden und zu erstellenden Dateien

## Parameter �bergeben
	while getopts v: option; do
		case "${option}" in
			
			v) verzeichnis=${OPTARG};;
			
		esac
	done

## Pfadvariablen anpassen und Arbeitsverzeichnis anlegen - sofern angegeben
	if [ $verzeichnis != "false" ]; then
		
		mkdir -p ./$verzeichnis
		imagesXML=$verzeichnis/$imagesXML
		htmlFile=$verzeichnis/$htmlFile
		logFile=$verzeichnis/$logFile
		
	fi

uname -s -r -v -m >> $logFile		# initialer logFile-Eintrag mit Systeminformationen
echo $(date) "getImageTable.sh - start" >> $logFile
echo "-> definiertes Arbeitsverzeichnis=" $verzeichnis >> $logFile

## eventuell vorhandene Zieldatei l�schen, um Validit�t der folgenden Append-Operationen sicherzustellen	
	if [ -f $htmlFile ]; then
		
		$(rm $htmlFile)

	fi

## Bild-ID-Liste aus unique Images (pr�fung auf Image-URL) erzeugen
	imageList=$(eval 'xmllint $imagesXML -xpath "article/version/image[not(url = preceding:: url)]/@id"')
	
echo "Ermittelte unique images: "$imageList >> $logFile
	
## Zieldatei schreiben
## notwendige HTML-Tags anlegen, Tabellenformat definieren
	echo "<html><head><style>table, th, td {border: 1px solid black;}</style><body>" >> $htmlFile
	
echo "Zieldatei $htmlFile initiiert." >> $logFile
	
## Table �ffnen und erste Zelle (a:1) leer lassen
	echo "<table><tr><th/>" >> $htmlFile
	
## Bilder in erste Zeile schreiben
	for image in $imageList
	do

		url=$(eval 'xmllint $imagesXML -xpath "(article/version/image[@$image]/url/text())[1]"')		# w�hlt den ersten Eintrag des Ergebnissatzes aus
		
		# Header-Zelle wird mit einem Bild mit 150 px Breite bef�llt
		echo "<th><img width='150' src='https:$url'/></th>" >> $htmlFile
		
	done 
		
## Erste Zeile schlie�en
	echo "</tr>" >> $htmlFile

echo "Header geschrieben." >> $logFile

## Inhaltszeilen schreiben, jeweils pro Version
	for version in $(eval 'xmllint $imagesXML -xpath "article/version/@id"')
	do
	
		echo "Inhaltszeile f�r Version $version wird geschrieben." >> $logFile
		
		echo "<tr>" >> $htmlFile	# neue Zeile
		
		echo "<td>$version</td>" >> $htmlFile	# ID in erste Spalte schreiben
		
		# Pr�fung, welche Bild-ID in dieser Version vorkommen - jeweils pro Bild in $imageList
		for id in $imageList;
		do
		
			# URL des Vergleichsbildes als uid auslesen (Text des ersten Nodes aus dem Ergebnisset)
			urlVergleich=$(eval 'xmllint $imagesXML -xpath "(article/version/image[@$id]/url/text())[1]"')
		
			echo "- Pruefung Version $version gegen Bild " $urlVergleich >> $logFile
			
			# Pr�fung auf Version-ID und Image-ID - bei Erfolg wird ID ausgegeben
			echo "<td>"$(eval 'xmllint $imagesXML -xpath "article/version[@$version]/image[url=\"$urlVergleich\"]/@id"')"</td>" >> $htmlFile
		
		done 
	
		echo "</tr>" >> $htmlFile	# Zeilenende
	
		echo "Inhaltszeile f�r Version $version abgeschlossen." >> $logFile
	
	done
	
## Zieldatei abschlie�en
	echo "</table></body></html>" >> $htmlFile

echo $(date) "getImageTable.sh - end" >> $logFile