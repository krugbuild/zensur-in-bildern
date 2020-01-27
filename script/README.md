# Skripte und Schemata

Zur Ausführung der Shell-Skripte ist eine bash-kompatible Shell nötig, wie sie unter GNU/Linux sowie MacOS üblicherweise zum Einsatz kommt. Unter Windows kann diese über die Einrichtung des *Windows-Subsystems für Linux* [nachträglich installiert](https://docs.microsoft.com/de-de/windows/wsl/install-win10) werden. Die XSLT-Schemata folgen dem [XSLT-Standard 1.0](http://www.w3.org/1999/XSL/Transform) und können mittels beliebiger XML-Editoren angewendet werden.

Direkt zur Dokumentation der einzelnen Skripte und Schemata:

| [BASH-Skripte](#bash-skripte) | [XSLT-Schemata](#xslt-schemata) |
| - | - |
| [getHistory.sh](#getHistory) | [history.xsl](#history-xsl) |
| [getArticles.sh](#getArticles) | [images.xsl](#images-xsl) |
| [getImages.sh](#getImages) | |
| [getImageTable.sh](#getImageTable) | |

---

## BASH-Skripte

### <a name="getHistory">[getHistory.sh (2020-01-27)](getHistory.sh)</a>

Das Skript ruft eine angegebene Wikipedia-Artikelgeschichte ab und speichert neben der unveränderten HTML-Datei auch eine auf Kennwerte reduzierte und vom HTML freigestellte XML. ([Siehe unten](#history-xsl)) Für den zweiten Schritt ist es dabei notwendig, dass sich die Transformationsdatei (i.d.R. [history.xsl](history.xsl)) im Skriptverzeichnis befindet.

```bash
sh getHistory.sh -u URL -v VERZEICHNIS
```
Der Aufruf ist optional parametrisiert und akzeptiert die Parameter `-u` zur Angabe der abzurufenden URL sowie `-v` zur Angabe eines Arbeitsverzeichnisses, um die Ergebnisdateien dort abzulegen. Es ist angeraten, die Parameter in Anführungszeichen zu setzen, um eine korrekte Übernahme auch bei komplexeren Zeichenketten (mit Leerzeichen und anderen Sonderzeichen) zu gewährleisten. Wird keine URL angegeben, wird diese zur Laufzeit des Skriptes abgefragt. Sollte kein Arbeitsverzeichnis angegeben sein, werden die Ergebnisdateien im Skriptverzeichnis abgelegt. Die Prozesse werden in einem Logfile dokumentiert.
Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc`: http://xmlsoft.org/XSLT/xsltproc.html
- `wget`: https://wiki.ubuntuusers.de/wget/

### <a name="getArticles">[getArticles.sh (2020-01-23)](getArticles.sh)</a>

Das Skript ruft eine Reihe von Wikipedia-Artikelversionen ab und speichert diese als XML-Datei. Die XML entspricht dabei folgender Form:

```xml
<article>
	<version id= >
	</version>
</article>
```

Der Abruf folgt einer zu definierenden ID-Liste, wobei diese entweder als simples Textfile übergeben werden kann. Alternativ wird über den Aufruf des Skriptes `getHistory.sh` eine ID-Liste erzeugt, die weiterhin auch zeitlich eingeschränkt werden kann. Der Skriptverlauf wird in eine Logfile geschrieben.

```bash
sh getArticles.sh -u URL -v VERZEICHNIS -b BEGINNZEITRAUM -e ENDEZEITRAUM -l
```
Der Aufruf ist optional parametrisiert und akzeptiert die Parameter `-v` zur Angabe eines Arbeitsverzeichnisses sowie `-u` zur Angabe der URL der zugehörigen Versionsgeschichte. Es ist angeraten, die Parameter in Anführungszeichen zu setzen, um eine korrekte Übernahme auch bei komplexeren Zeichenketten (mit Leerzeichen und anderen Sonderzeichen) zu gewährleisten. Wird keine URL angegeben, wird diese zur Laufzeit des Skriptes abgefragt. Sollte kein Arbeitsverzeichnis angegeben sein, werden die Ergebnisdateien im Skriptverzeichnis abgelegt. Über die Parameter `-b` *Beginn*  sowie `-e` *Ende* kann der Zeitraum der abzurufenden Artikel eingegrenzt werden. Die Datumsangaben sind im Format `YYYYMMDDhhmm` anzugeben. Werden Beginn oder Ende nicht gesetzt, kann der abzurufende Zeitraum zur Laufzeit des Skriptes angegeben werden. Mit dem Parameter `-l` kann der Abruf der `historyData.xml` unterbunden werden, das Skript wird lokal ausgeführt. Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc`: http://xmlsoft.org/XSLT/xsltproc.html
- `wget`: https://wiki.ubuntuusers.de/wget/
- `xmllint`: http://xmlsoft.org/xmllint.html (ab Version 20909)
- `sed`: http://sed.sourceforge.net/

### <a name="getImages">[getImages.sh (2020-01-27)](getImages.sh)</a>

Das Skript ermittelt aus `articleData.xml`-Dateien sämtliche Bilder und speichert deren Metadaten als XML-Datei.

```bash
sh getImages.sh -v VERZEICHNIS
```

Es können belibig viele Dateien im Format `articleData[n].xml` eingelesen werden, wobei `[n]` eine natürliche Zahl sein muss. Die erste Datei einer Serie muss stets `articleData.xml` heißen und alle folgenden müssen aufsteigend nummeriert werden. Über den Parameter `-v` kann ein Arbeitsverzeichnis relativ zum Skriptverzeichnis angegeben werden. Die Ermittlung der auszulesenden Dateien beschränkt sich auf das unmittelbare Arbeitsverzeichnis. Zur Transformation der Daten wird das Schema [images.xsl](#history-xsl) angewandt. Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc`: http://xmlsoft.org/XSLT/xsltproc.html
- `find`: https://wiki.ubuntuusers.de/find/

### <a name="getImageTable">[getImageTable.sh (2020-01-24)](getImageTable.sh)</a>

Das Skript legt eine HTML-Tabelle an, in der alle aus der Quelldatei (bzw. den Quelldateien) ermittelten Bilder allen Artikelversionen gegenübergestellt werden. Aus dieser Tabelle lässt sich somit die Entwicklung der Verwendung einzelner Bilder über den definierten Versionsverlauf nachvollziehen.

```bash
sh getImageTable.sh -v VERZEICHNIS -n
```

Der Aufruf ist optional parametrisiert und akzeptiert die Parameter `-v` zur Angabe eines Arbeitsverzeichnisses sowie `-n`, um *keine* Transformation der `articleData.xml` durchzuführen. Zur Prüfung der Artikelversionen gegen den Bildbestand werden zunächst alle einzigartigen (unique) Bilder ermittelt, diese werden dabei anhand der URL identifiziert. Anschließend wird die HTML-Tabelle geschrieben, wobei für jede Artikelversion geprüft wird, welche Bilder aus dem Gesamtbestand darin vorkommen. Das Ergebnis wird in eine HTML-Datei (Standard: `imageTable.html`) geschrieben. Die einzelnen Skript-Schritte werden in einem Logfile dokumentiert.
Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc`: http://xmlsoft.org/XSLT/xsltproc.html
- `xmllint`: http://xmlsoft.org/xmllint.html (ab Version 20909)

---

## XSLT-Schemata

### <a name="history-xsl">[history.xsl (2020-01-27)](history.xsl)</a>

Die Schemadatei dient dazu, das HTML-Dokument einer Wikipedia-Versionsgeschichte zu zerlegen und in eine auswertbare Struktur zu bringen. Die XML folgt dabei der Form:

```xml
<article>
	<versions>
        <version>
            <id/>
            <timestamp/>
            <date/>
            <time/>
            <user/>
            <minoredit/>
            <comment/>
        </version>
	</versions>
</article>
```

Das Tag `<versions/>` beinhaltet hierbei die zentrale Liste mit den einzelnen Versionen des zugehörigen Artikels. Der restliche Seiteninhalt wird entsprechend davor und dahinter im Tag `<article/>` gekapselt.
Das Schema zerlegt die dargestellten Datumsangaben in das neutrale Format `YYYYMMDDhhmm` um eine einfache Verarbeitung zu gewährleisten. Mit Stand 27.01.2020 ist nur die Zerlegung des in der chinesischen Wikipedia benutzten Datumsformat (etwa `2020年1月4日 (六) 10:20`) implementiert.

Das Schema wird üblicherweise über das Skript `getHistory.sh` aufgerufen. Unabhängig davon kann es über des Kommandozeilenprogramms `xsltproc` angewendet werden:

```bash
xsltproc -v -o ZIELDATEI history.xsl HTMLDATEI
```

### <a name="images-xsl">[images.xsl (2020-01-27)](images.xsl)</a>

Die Schemadatei dient der Ermittlung von Bild-Elementen aus Wikipediaartikeln. Das HTML der Artikel wird dabei als Inhalt von `article/version` erwartet.  Um eine Stapelverarbeitung zu ermöglichen, simuliert das Schema eine Schleifenstruktur durch einen rekursiven Aufruf. Dabei werden externe Dateien durchiteriert. Die Dateibezeichnungen *müssen* dem Schema `articleData[n].xml` folgen. Der Prozess ist bei größeren Quelldaten sehr Speicherintensiv. **NB** Auf System mit 8 GB Ram wird eine maximales Quelldatenvolumen von 1,5 GB pro Durchlauf empfohlen. Die Ausgabe entspricht folgender Form:

```xml
<article>
	<version id= >
		<image id= >
			<alt/>
			<url/>
			<class/>
			<width/>
			<height/>
			<width_file/>
			<height_file/>
			<decoding/>
			<srcset/>
		</image>
	</version>
</article>
```
Das Schema wird üblicherweise über das Skript `getImages.sh` aufgerufen. Unabhängig davon kann es über des Kommandozeilenprogramms `xsltproc` angewendet werden:

```bash
xsltproc -v -o ZIELDATEI -param count ANZAHL -stringparam directory VERZEICHNIS images.xsl articeData.xml
```

Der Parameter `count` entspricht dabei der Anzahl der *zusätzlichen* articleData.xml-Dateien, also jenen mit einer Ziffer im Dateinamen. Mittels `directory` kann das Arbeitsverzeichnis angegeben werden. (Die Angabe des Arbeitsverzeichnis wirkt sich *nicht* auf die Adressierung der Quelldatei im xsltproc-Aufruf aus!)
