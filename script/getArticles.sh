#!/bin/bash
#
# Das Skript ruft mittels wget alle in der id-Liste definierten Artikelversionen ab und f¸gt diese zu einer Datei zusammen.
# und mehr!
#
# Autor: 	Stefan Krug
# Stand:	2020-01-13

echo "\n### getArticles.sh - Stand 2020-01-17 - Initialisierung.."

## Variablendefinition
	xmlSource="historyData.xml"	# Quelldatei f¸r die Liste
	xmlFile="articleData.xml"		# Zielpfad f¸r die XML-Datei
	logFile="articleData_log.txt"	# Zielpfad f¸r das Log
	timer=0.5s					# Wartezeit zwischen den Abrufen der Artikel, um eine Wertung des Vorgangs als DOS-Attacke zu vermeiden
	idList=""						# Abfragestring zur Ermittlung der IDs
	verzeichnis="false"			# Arbeitsverzeichnis f¸r die zu lesenden und zu erstellenden Dateien
	zBeginn=0					# Beginn des abzurufenden Zeitraums im Format YYYYMMDDhhmm; 0=Abfrage zum Modus
	zEnde=0						# Ende des abzurufenden Zeitraums im Format YYYYMMDDhhmm; 0=Abfrage zum Modus
	url="false"					# URL der abzurufenden Versionsgeschichte, um ID-Liste zu ermitteln
	
	statUrl='https://zh.wikipedia.org/w/index.php?oldid='	# statischer Teil der URL, ist nach Landesversion anzupassen

## Parameter ¸bergeben
	while getopts v:b:e:u: option; do
		case "${option}" in
			
			v) verzeichnis=${OPTARG};;
			b) zBeginn=${OPTARG};;
			e) zEnde=${OPTARG};;
			u) url=${OPTARG};;
			
		esac
	done
	
## Pfadvariablen anpassen und Arbeitsverzeichnis anlegen - sofern angegeben
	if [ $verzeichnis != "false" ]; then
		
		mkdir -p ./$verzeichnis
		xmlSource=$verzeichnis/$xmlSource
		xmlFile=$verzeichnis/$xmlFile
		logFile=$verzeichnis/$logFile
		
	fi

uname -s -r -v -m >> $logFile		# initialer logFile-Eintrag mit Systeminformationen
echo $(date) "getArticles.sh - start" >> $logFile
echo "-> definiertes Arbeitsverzeichnis=" $verzeichnis >> $logFile

## Pr¸fen, ob Parameter zum Eingrenzen der Versionsgeschichte gesetzt sind - sonst Abfrage
	if [ $zBeginn != "0" ] && [ $zEnde != "0" ]; then
		
		option=3;
		
	else
		
		echo "Bitte waehlen Sie einen Modus:\n[1] Artikel anhand einer vorhandenen Liste abrufen.\n[2] Artikel anhand der Versionsgeschichte abrufen.\n[3] Artikel anhand einer eingegrenzten Versionsgeschichte abrufen."

		read option
	fi

## Vorbereitung des Abrufs gem‰ﬂ Auswahl. Hierzu wird die Variable $idList mit der Auswahl entsprechenden Abrufstrings bef¸llt 
	if [ $option = "1" ]; then					# Option 1 erwartet eine simple Liste mit IDs
			
		echo "Bitte geben Sie den Dateinamen der einzulesenden Liste ein:"
		
		read idList
	
		echo "-> Einlesen der ID-Liste aus "$idList >> $logFile

		idList="cat" $idList

	elif [ $option > "1" ]; then				# Option 2 und 3 erzeugen auf die gleiche Art eine XML
		
		echo "-> Aufruf von getHistory.sh zur Ermittlung einer ID-Liste" >> $logFile
		
		sh getHistory.sh -v $verzeichnis -u $url	# Abruf der Versionsgeschichte, um daraus die IDs auszulesen
		
		if [ $option = "2" ]; then				# unparametrisiert
			
			idList="xmllint --xpath 'document/article/version/id/text()' $xmlSource"
		
		elif [ $option = "3" ]; then			# parametrisiert
			
			if [ $zBeginn = "0" ]  ||  [ $zEnde = "0" ]; then	# sollten die Parameter noch nicht gesetzt sein: Abfrage
					
				echo "Bitte geben Sie den Beginn des Zeitraumes (das aeltere Datum) im Format YYYYMMDDhhmm ein:"
				
				read zBeginn
				
				echo "Bitte geben Sie den Ende des Zeitraumes (das juengere Datum) im Format YYYYMMDDhhmm ein:"
				
				read zEnde
			
			fi
			
			idList="xmllint --xpath 'document/article/version[timestamp>$zBeginn and timestamp<$zEnde]/id/text()' $xmlSource"
			
		fi
	fi

echo "-> Die IDs werden im Modus" $option "im Bereich zwischen" $zBeginn "und" $zEnde "ermittelt." >> $logFile
echo "Das Ergebnis wird in die Datei" $xmlFile "geschrieben. Die Wartezeit zwischen den Abfragen betraegt:" $timer"\n"

## Artikel gem‰ﬂ Auswahl abrufen und als XML speichern
	if [ -f $xmlFile ]; then	# es folgen Append-Operationen, deshalb brauchen wir eine 'leere' Datei
		
		$(rm $htmlFile)

	fi

	echo "<articles>" >> $xmlFile		# ˆffnenden Tag setzen, um Wohlgeformtheit im XML zu gew‰hrleisten

	for id in $(eval $idList)
	do

		url=$statUrl$id					# die abzurufende URL wird aus dem statischem Teil der Artikel-Url und der ID als Parameter generiert
		
		echo "Artikel" $url "wird abgerufen.."
		echo "Artikel" $url "wird abgerufen." >> $logFile
		
		echo "<article id='$id'>" >> $xmlFile		# <article> wird mit ID als Parameter vor den abzurufen Inhalt gesetzt
		
		wget -a $logFile -O ->> $xmlFile $url			# -a Logfile wird appended; -O Ausgabedatei (append durch "->>" Operator) 
		
		echo "</article>" >> $xmlFile			# </article> wird ans Ende des abzurufenden Inhalts gesetzt
		
		sleep $timer							# kurze Wartzeit, um DOS-Erkennung zu vermeiden
	done

	echo "</articles>" >> $xmlFile				# schlieﬂenden Tag setzen, um Wohlgeformtheit des Dokuments zu gew‰hleisten

	$(eval "sed -i 's/<!DOCTYPE html>//g' $xmlFile")	# irregul‰re Tags aus HTML entfernen

	echo "\nDas HTML-Abbild wurde als "$xmlFile" gespeichert."

echo $(date) "getArticles.sh - end" >> $logFile

echo "\nAbgeschlossen. Bitte ueberpruefen Sie das Logfile" $logFile "auf Fehlermeldungen."