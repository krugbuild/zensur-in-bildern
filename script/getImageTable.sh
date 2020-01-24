#!/bin/bash
#
# Das Skript legt eine HTML-Tabelle an, in der alle aus der Quelldatei ermittelten Bilder allen Artikelversionen gegenübergestellt werden.
# Aus dieser Tabelle lässt sich somit die Entwicklung der Verwendung einzelner Bilder über den definierten Versionsverlauf nachvollziehen.
# Hierzu wird entweder eine vorhandene Quelldatei (-n Parameter gesetzt) eingelesen, oder es wird versucht, eine ArticleData-XML zu transformieren.
# Zur Prüfung gegen den Bildbestand werden anschließend alle einzigartigen (unique) Bilder ermittelt, diese werden anhand der URL identifiziert.
# Auch beim Vergleich der Artikelversionen mit der Bildliste wird gegen die URL geprüft.
#
# Parameter:
#			-v		(optional) Arbeitsverzeichnis. Legt einen definierten Unterordner an und speichert dort die zu erzeugenden Dateien.
#			-n		(Kennzeichen) Deaktiviert die Transformation der articleXML. Stattdessen wird eine vorhandene imagesDataXML eingelesen.
#
# Autor: 		Stefan Krug
# Lizenz: 		CC BY 3.0 DE Dieses Werk ist lizenziert unter einer Creative Commons Namensnennung 3.0 Deutschland Lizenz. (http://creativecommons.org/licenses/by/3.0/de/)
# Stand:		2020-01-24

echo "\n### getImageTable.sh - Stand 2020-01-24 - Initialisierung.."

## Variablendefinition
	htmlFile="imageTable.html"		# Zieldatei
	logFile="imageTable_log.txt"		# Zielpfad für das Log
	historyXML="historyData.xml"	# Quelldatei für Metainformationen
	imagesXML="imageData.xml"		# Quelldatei für Auswertung, wird duch XSLT generiert
	stylesheet="true"				# Kennzeichen, ob XSLT durchgeführt werden soll
	imageList=""					# Variable, um auszuwertende Liste vorzuhalten
	verzeichnis="false"			# Arbeitsverzeichnis für die zu lesenden und zu erstellenden Dateien, default "false"
	
## Parameter übergeben
	while getopts v:n option; do
		case "${option}" in
			
			v) verzeichnis=${OPTARG};;
			n) stylesheet="false";;
			
		esac
	done

## Pfadvariablen anpassen und Arbeitsverzeichnis anlegen - sofern angegeben
	if [ $verzeichnis != "false" ]; then
		
		mkdir -p ./$verzeichnis
		imagesXML=$verzeichnis/$imagesXML
		historyXML=$verzeichnis/$historyXML
		htmlFile=$verzeichnis/$htmlFile
		logFile=$verzeichnis/$logFile
		
	fi

uname -s -r -v -m >> $logFile		# initialer logFile-Eintrag mit Systeminformationen
echo $(date) "getImageTable.sh - start" >> $logFile
echo "-> definiertes Arbeitsverzeichnis= $verzeichnis" >> $logFile

## Transformation via xsltproc und Schemadatei, um Quelldatei zu erzeugen
	if [ $stylesheet != "false" ]; then

		sh getImages.sh -v $verzeichnis

	fi

## eventuell vorhandene Zieldatei löschen, um Validität der folgenden Append-Operationen sicherzustellen	
	if [ -f $htmlFile ]; then
		
		$(rm $htmlFile)

	fi

## Bild-ID-Liste aus unique Images (prüfung auf Image-URL) erzeugen
	imageList=$(eval 'xmllint $imagesXML -xpath "article/version/image[not(url = preceding:: url)]/@id"')
	
echo "Ermittelte unique images: "$imageList >> $logFile
	
## Zieldatei schreiben
## notwendige HTML-Tags anlegen, Tabellenformat definieren
	echo "<html><head><style>table, th, td {border: 1px solid black;}</style><body>" >> $htmlFile
	
echo "Zieldatei $htmlFile initiiert." >> $logFile
	
## Table öffnen und Header-Zellen 1 und 2 beschriften lassen
	echo '<table style="background-color:aliceblue"><tr><th>ID</th><th>Datum</th>' >> $htmlFile
	
## Bilder und Alternativtext in erste Zeile schreiben
	for image in $imageList
	do

		# URL ermitteln, wählt den ersten Eintrag des Ergebnissatzes aus
		url=$(eval 'xmllint $imagesXML -xpath "(article/version/image[@$image]/url/text())[1]"')		
		
		# Alternativtext ermitteln, wählt den ersten Eintrag des Ergebnissatzes aus
		alt=$(eval 'xmllint $imagesXML -xpath "(article/version/image[@$image]/alt/text())[1]"')
		
		# Header-Zelle wird mit einem Bild mit 150 px Breite, Zeilenumbruch und Alternativtext befüllt
		echo "<th><img width='150' src='https:$url'/><br/><b>$alt</b></th>" >> $htmlFile
		
	done 
		
## erweiterte Headerzellen schreiben
	echo "<th>Zeit</th><th>Benutzer</th><th>Kommentar</th>" >> $htmlFile
		
## Erste Zeile schließen
	echo "</tr>" >> $htmlFile

echo "Header geschrieben." >> $logFile

## Inhaltszeilen schreiben, jeweils pro Version
	for version in $(eval 'xmllint $imagesXML -xpath "article/version/@id"')
	do
	
		echo "Inhaltszeile für Version $version wird geschrieben." >> $logFile
		
		echo "<tr>" >> $htmlFile	# neue Zeile
		
		# Prüfen, ob Version nur eine kleine Änerung beinhaltet
		if [ $(eval "xmllint $historyXML -xpath 'article/versions/version[$version]/minoredit/text()'") = 1 ]; then
			
			echo "<td><nobr>$version <b>k</b></nobr></td>" >> $htmlFile	# ID mit Kennzeichen 'kleine Änderung' in erste Spalte schreiben
			
			else
			
			echo "<td>$version</td>" >> $htmlFile		# nur ID in erste Spalte schreiben
		fi
		
		# Date in zweite Spalte schreiben
		echo "<td><b>"$(eval "xmllint $historyXML -xpath 'article/versions/version[$version]/date/text()'")  "</b></td>" >> $htmlFile
		
		# Prüfung, welche Bild-ID in dieser Version vorkommen - jeweils pro Bild in $imageList
		for id in $imageList;
		do
		
			# URL des Vergleichsbildes als uid auslesen (Text des ersten Nodes aus dem Ergebnisset)
			urlVergleich=$(eval 'xmllint $imagesXML -xpath "(article/version/image[@$id]/url/text())[1]"')
		
			echo "- Pruefung Version $version gegen Bild " $urlVergleich >> $logFile
			
			# Prüfung auf Version-ID und Image-ID - bei Erfolg wird ID ausgegeben
			vorhanden=$(eval 'xmllint $imagesXML -xpath "article/version[@$version]/image[url=\"$urlVergleich\"]/@id"')
			
			if  [ ! $(eval 'xmllint $imagesXML -xpath "article/version[@$version]/image[url=\"$urlVergleich\"]/@id"') = "" ]; then
				
				echo "<td>"$vorhanden"</td>" >> $htmlFile 
				
			else
			
				echo '<td style="background-color:white"/>' >> $htmlFile
				
			fi
		
		done 
		
		# Time in dritt letzte Spalte schreiben
		echo "<td><b>"$(eval "xmllint $historyXML -xpath 'article/versions/version[$version]/time/text()'")"</b></td>" >> $htmlFile
	
		# Benutzer in vorletzte Spalte schreiben
		echo "<td><b>"$(eval "xmllint $historyXML -xpath 'article/versions/version[$version]/user/text()'")"</b></td>" >> $htmlFile
	
		# Kommentar letzte Spalte schreiben, Zeile abschließen
		echo "<td><nobr>"$(eval "xmllint $historyXML -xpath 'article/versions/version[$version]/comment/text()'")"</nobr></td></tr>" >> $htmlFile
	
		echo "Inhaltszeile für Version $version abgeschlossen." >> $logFile
	
	done
	
## Zieldatei abschließen
	echo "</table></body></html>" >> $htmlFile

echo $(date) "getImageTable.sh - end" >> $logFile