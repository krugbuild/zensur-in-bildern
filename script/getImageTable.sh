#!/bin/bash
#
#
# Autor: 	Stefan Krug
# Stand:	2020-01-21

htmlFile="imageTable.html"
imagesXML="images.xml"
imageList=""

echo "\n### getImageTable.sh - Stand 2020-01-21 - Initialisierung.."

	# Bild-ID-Liste aus einzigartigen Image-URL erzeugen
	imageList=$(eval 'xmllint $imagesXML -xpath "article/version/image[not(url = preceding:: url)]/@id"')
	
	if [ -f $htmlFile ]; then	# es folgen Append-Operationen, deshalb brauchen wir eine 'leere' Datei
		
		$(rm $htmlFile)

	fi

	# notwendige HTML-Tags anlegen, Tabellenstyle definieren
	echo "<html><head><style>table, th, td {border: 1px solid black;}</style><body>" >> $htmlFile
	
	# Table öffnen und erste Zelle (a:1) leer lassen
	echo "<table><tr><th/>" >> $htmlFile
	
	# Bilder in erste Zeile schreiben
	#for url in $(eval 'xmllint $imagesXML -xpath "article/version/image[not(url = preceding:: url)]/@id"')
	for image in $imageList
	do

		url=$(eval 'xmllint $imagesXML -xpath "(article/version/image[@$image]/url/text())[1]"')
		
		echo "<th><img width='150' src='https:$url'/></th>" >> $htmlFile
		
	done 
		
	# Erste Zeile schließen
	echo "</tr>" >> $htmlFile

	# Inhaltszeilen schreiben, je Version
	for version in $(eval 'xmllint $imagesXML -xpath "article/version/@id"')
	do
		echo "<tr>" >> $htmlFile	# neue Zeile
		
		echo "<td>$version</td>" >> $htmlFile	# ID in erste Spalte schreiben
		
		# Prüfung, welche Bild-ID in dieser Version vorkommen
		for id in $imageList;
		do
			# URL des Vergleichsbildes als uid auslesen (Text des ersten Nodes aus dem Ergebnisset)
			urlVergleich=$(eval 'xmllint $imagesXML -xpath "(article/version/image[@$id]/url/text())[1]"')
			echo "Pruefung gegen" $urlVergleich
			# Prüfung auf Version-ID und Image-ID - bei Erfolg wird ID ausgegeben
			echo "<td>"$(eval 'xmllint $imagesXML -xpath "article/version[@$version]/image[url=\"$urlVergleich\"]/@id"')"</td>" >> $htmlFile
		
		done 
	
		echo "</tr>" >> $htmlFile	# Zeilenende
	
	done
	
	echo "</table></body></html>" >> $htmlFile