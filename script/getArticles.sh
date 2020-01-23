#!/bin/bash
#
# Das Skript ruft anhand einer ID-Liste Wikipedia-Artikel ab und speichert diese als separate Elemente in einer XML-Datei.
# Die ID-Liste kann dabei entweder als simples Textfile eingelesen werden, oder über den Aufruf des Skriptes getHistory.sh aus einer Versionsgeschichte generiert werden.
# Im zweiten Fall wird die Versionsgeschichte als XML abgelegt und in diesem Skript via XPath ausgelesen. Eine Einschränkung des auszulesenden Zeitraums ist dabei möglich.
#
# Parameter:
#			-u 		(optional) Abzurufende URL. Jede URL ist valide, die Transformation ist jedoch nur auf die Versionsgeschichten der Wikipedia ausgelegt. Bei fehlender Eingabe wird URL zur Laufzeit abgefragt.
#			-v		(optional) Arbeitsverzeichnis. Legt einen definierten Unterordner an und speichert dort die zu erzeugenden Dateien.
#			-b		(optional) BEGINN des abzurufenden Zeitraums im Format YYYYMMDDhhmm. Es wird auf > geprüft.
#			-e		(optional) Ende des abzurufenden Zeitraums im Format YYYYMMDDhhmm. Es wird auf < geprüft.
#			-l		(Kennzeichen) Nur lokal. Verhindert den (erneuten) Abruf der historyData.xml.
#
# Autor: 	Stefan Krug
# Stand:	2020-01-20

echo "\n### getArticles.sh - Stand 2020-01-20 - Initialisierung.."

## Variablendefinition
	xmlSource="historyData.xml"	# Quelldatei für die Liste
	xmlFile="articleData.xml"		# Zielpfad für die XML-Datei
	logFile="articleData_log.txt"	# Zielpfad für das Log
	timer=0.5s					# Wartezeit zwischen den Abrufen der Artikel, um eine Wertung des Vorgangs als DOS-Attacke zu vermeiden
	idList=""						# Abfragestring zur Ermittlung der IDs
	verzeichnis="false"			# Arbeitsverzeichnis für die zu lesenden und zu erstellenden Dateien
	zBeginn=0					# Beginn des abzurufenden Zeitraums im Format YYYYMMDDhhmm; 0=Abfrage zum Modus
	zEnde=0						# Ende des abzurufenden Zeitraums im Format YYYYMMDDhhmm; 0=Abfrage zum Modus
	url="false"					# URL der abzurufenden Versionsgeschichte, um ID-Liste zu ermitteln
	lokal="false"					# Parameter, Aufruf von getHistory.sh zu verhinden
	maxFileSize="5000"				# maximale Dateigröße für die Ziel-XML in kb
	
	statUrl='https://zh.wikipedia.org/w/index.php?oldid='	# statischer Teil der URL, ist nach Landesversion anzupassen

## Parameter übergeben
	while getopts v:b:e:u:l option; do
		case "${option}" in
			
			v) verzeichnis=${OPTARG};;
			b) zBeginn=${OPTARG};;
			e) zEnde=${OPTARG};;
			u) url=${OPTARG};;
			l) lokal="true";;
			
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

## Prüfen, ob Parameter zum Eingrenzen der Versionsgeschichte gesetzt sind - sonst Abfrage
	if [ $zBeginn != "0" ] && [ $zEnde != "0" ]; then
		
		option=3;
		
	else
		
		echo "Bitte waehlen Sie einen Modus:\n[1] Artikel anhand einer vorhandenen Liste abrufen.\n[2] Artikel anhand der Versionsgeschichte abrufen.\n[3] Artikel anhand einer eingegrenzten Versionsgeschichte abrufen."

		read option
	fi

## Vorbereitung des Abrufs gemäß Auswahl. Hierzu wird die Variable $idList mit der Auswahl entsprechenden Abrufstrings befüllt 
	if [ $option = "1" ]; then					# Option 1 erwartet eine simple Liste mit IDs
			
		echo "Bitte geben Sie den Dateinamen der einzulesenden Liste ein:"
		
		read idList
	
		echo "-> Einlesen der ID-Liste aus "$idList >> $logFile

		idList="cat" $idList

	elif [ $option > "1" ]; then				# Option 2 und 3 erzeugen auf die gleiche Art eine XML
		
		echo "-> Aufruf von getHistory.sh zur Ermittlung einer ID-Liste" >> $logFile
		
		# wenn Parameter 'lokal' gesetzt wurde, soll die Versionsgeschichte nicht abgerufen werden
		if [ $lokal = "false" ]; then
		
			# Abruf der Versionsgeschichte, um daraus die IDs auszulesen
			sh getHistory.sh -v $verzeichnis -u $url	
		fi
		
		if [ $option = "2" ]; then				# unparametrisiert
			
			idList="xmllint --xpath 'article/versions/version/id/text()' $xmlSource"
		
		elif [ $option = "3" ]; then			# parametrisiert
			
			if [ $zBeginn = "0" ]  ||  [ $zEnde = "0" ]; then	# sollten die Parameter noch nicht gesetzt sein: Abfrage
					
				echo "Bitte geben Sie den Beginn des Zeitraumes (das aeltere Datum) im Format YYYYMMDDhhmm ein:"
				
				read zBeginn
				
				echo "Bitte geben Sie den Ende des Zeitraumes (das juengere Datum) im Format YYYYMMDDhhmm ein:"
				
				read zEnde
			
			fi
			
			idList="xmllint --xpath 'article/versions/version[timestamp>$zBeginn and timestamp<$zEnde]/id/text()' $xmlSource"
			
		fi
	fi

echo "-> Die IDs werden im Modus" $option "im Bereich zwischen" $zBeginn "und" $zEnde "ermittelt." >> $logFile
echo "Das Ergebnis wird in die Datei" $xmlFile "geschrieben. Die Wartezeit zwischen den Abfragen betraegt:" $timer"\n"

## Artikel gemäß Auswahl abrufen und als XML speichern
	if [ -f $xmlFile ]; then	# es folgen Append-Operationen, deshalb brauchen wir eine 'leere' Datei
		
		$(rm $xmlFile)

	fi

	echo "<article>" >> $xmlFile		# öffnenden Tag setzen, um Wohlgeformtheit im XML zu gewährleisten

	xmlFileCore=$(eval 'basename $xmlFile ".xml"')	# Dateinamen ohne Verzeichnis und Endung ermitteln

	for id in $(eval $idList)
	do

		url=$statUrl$id					# die abzurufende URL wird aus dem statischem Teil der Artikel-Url und der ID als Parameter generiert
		
		echo "Version" $url "wird abgerufen.."
		echo "Version" $url "wird abgerufen." >> $logFile
		
		echo "<version id='$id'>" >> $xmlFile		# <version> wird mit ID als Parameter vor den abzurufen Inhalt gesetzt
		
		wget -a $logFile -O ->> $xmlFile $url			# -a Logfile wird appended; -O Ausgabedatei (append durch "->>" Operator) 
		
		echo "</version>" >> $xmlFile			# </version> wird ans Ende des abzurufenden Inhalts gesetzt
		
		sleep $timer							# kurze Wartzeit, um fälschliche DOS-Erkennung zu vermeiden
		
		# Dateigröße der Ausgabe prüfen und ggf. eine neue Datei beginnen
		if [ $(du -k "$xmlFile" | cut -f 1) -ge $maxFileSize ]; then 

			echo "</article>" >> $xmlFile				# schließenden Tag setzen, um Wohlgeformtheit des Dokuments zu gewähleisten

			$(eval "sed -i 's/<!DOCTYPE html>//g' $xmlFile")	# irreguläre Tags aus HTML entfernen
			
			echo "\nDas HTML-Teil-Abbild wurde als "$xmlFile" gespeichert."
			
			xmlFile=$xmlFileCore$id".xml"		#neue Datei um die letzte ID erweitern
			
			if [ $verzeichnis != "false" ]; then
			
				xmlFile=$verzeichnis/$xmlFile
			
			fi
			
			echo "<article>" >> $xmlFile		# öffnenden Tag setzen, um Wohlgeformtheit im XML zu gewährleisten
		fi
	done

	echo "</article>" >> $xmlFile				# schließenden Tag setzen, um Wohlgeformtheit des Dokuments zu gewähleisten

	$(eval "sed -i 's/<!DOCTYPE html>//g' $xmlFile")	# irreguläre Tags aus HTML entfernen

	echo "\nDas HTML-Abbild wurde als "$xmlFile" gespeichert."

echo $(date) "getArticles.sh - end" >> $logFile

echo "\nAbgeschlossen. Bitte ueberpruefen Sie das Logfile" $logFile "auf Fehlermeldungen."