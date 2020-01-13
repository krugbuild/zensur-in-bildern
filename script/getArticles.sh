#!/bin/bash
#
# Das Skript ruft mittels wget alle in der id-Liste definierten Artikelversionen ab und f¸gt diese zu einer Datei zusammen.
# und mehr!
#
# Autor: 	Stefan Krug
# Stand:	2020-01-10

echo "\n### getArticles.sh - Stand 2020-01-10 - Initialisierung.."

## Parameterdefinition
statUrl='https://zh.wikipedia.org/w/index.php?oldid='	# statischer Teil der URL, ist nach Landesversion anzupassen
htmlFile="articleData.html"		# Zieldatei f¸r das HTML-Abbild
xmlFile="articleData.xml"		# Zieldatei f¸r die XML-Datei
logFile="articleData_log.txt"	# Zieldatei f¸r das Log
stylesheet="article.xsl"		# XSLT, muss f¸r Transformation vorhanden sein
timer=0.5s					# Wartezeit zwischen den Abrufen der Artikel, um eine Wertung des Vorgangs als DOS-Attacke zu vermeiden
idList=""						# Abfragestring zur Ermittlung der IDs
xmlSource="historyData.xml"	# Quelldatei f¸r die Liste


uname -s -r -v -m >> $logFile		# initialer logFile-Eintrag mit Systeminformationen
echo $(date) "getArticles.sh - start" >> $logFile

## 1. Pr¸fung auf article.xsl
if [ -f "$stylesheet" ];then
	echo "Schemadatei" $stylesheet "gefunden."
else
	echo "Schemadatei" $stylesheet "wurde nicht gefunden. Transformationsfunktion deaktiviert."
	stylesheet="false"
fi

## 2. Abfrage, ob via Liste oder ¸ber Versionsgeschichte
echo "Bitte waehlen Sie eine Option:\n[1] Artikel anhand einer vorhandenen Liste abrufen.\n[2] Artikel anhand der Versionsgeschichte abrufen.\n[3] Artikel anhand einer eingegrenzten Versionsgeschichte abrufen. (Dabei wird zusaetzlich die Versionsgeschichte gesichert und als bereinigte XML abgelegt.)"
read option
if [ $option = "1" ]; then
	echo "-> Einlesen der ID-Liste mit " >> $logFile
	echo "Bitte geben Sie den Dateinamen der einzulesenden Liste ein:"
	read idList
	idList="cat" $idList
elif [ $option > "1" ]; then			# Option 2 und 3 erzeugen auf die gleiche Art eine XML
	echo "-> Aufruf von getHistory.sh zur Ermittlung einer ID-Liste" >> $logFile
	sh getHistory.sh				# hier wird die xml Ausgabe erzeugt, ohne Parameter 
	if [ $option = "2" ]; then			# unparametrisiert
		idList="xmllint --xpath 'document/article/version/id/text()' $xmlSource"
	elif [ $option = "3" ]; then			# parametrisiert
		echo "Bitte geben Sie den Beginn des Zeitraumes (das aeltere Datum) im Format YYYYMMDDhhmm ein:"
		read start
		echo "Bitte geben Sie den Ende des Zeitraumes (das juengere Datum) im Format YYYYMMDDhhmm ein:"
		read end
		idList="xmllint --xpath 'document/article/version[timestamp>$start and timestamp<$end]/id/text()' $xmlSource"
	fi
fi
echo "Das Ergebnis wird in die Datei" $outputFile "geschrieben. Die Wartezeit zwischen den Abfragen betraegt:" $timer"\n"

## 3. Artikel gem‰ﬂ Auswahl abrufen
if [ -f $htmlFile ]; then	# es folgen Append-Operationen, deshalb brauchen wir eine 'leere' Datei
	$(rm $htmlFile)
fi
echo "<articles>" >> $htmlFile		# ˆffnenden Tag setzen, um Wohlgeformtheit zu gew‰hrleisten
# $idList		Parameter mit allen abzurufenden IDs
# -a			Logfile, wird fortgeschrieben (append)
# -O ->>		Ausgabedatei, an die ebenfalls angehangen wird (->> Operator)
for id in $(eval $idList)
do
	url=$statUrl$id							# die abzurufende URL wird aus dem statischem Teil der Artikel-Url und der ID als Parameter generiert
	echo "Artikel " $url " wird abgerufen.."
	wget -a $logFile -O ->> $htmlFile $url
	sleep $timer
done
echo "</articles>" >> $htmlFile		# schlieﬂenden Tag setzen

echo "\nDas HTML-Abbild wurde als" $htmlFile "gespeichert."

## 4. Artikel in XML transformieren
$(eval "sed -i 's/<!DOCTYPE html>//g' $htmlFile")	# irregul‰re Tags aus HTML entfernen

if [ $stylesheet != "false" ]; then
	echo "XSLT wird angewendet.."
	echo "-> xsltproc wird ausgefuehrt" >> $logFile
	xsltproc -v -o $xmlFile $stylesheet $htmlFile
	echo "\nBerenigte Daten wurden als" $xmlFile "gespeichert."
	echo "-> Auswertung wurde nach" $xmlFile "geschrieben." >> $logFile
fi

echo $(date) "getArticles.sh - end" >> $logFile
echo "\nAbgeschlossen. Bitte ueberpruefen Sie das Logfile" $logFile "auf Fehlermeldungen."