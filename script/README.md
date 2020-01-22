# Skripte und Schemata

Zur Ausführung der Shell-Skripte ist eine bash-kompatible Shell nötig, wie sie unter GNU/Linux sowie MacOS üblicherweise zum Einsatz kommt. Unter Windows kann diese über die Einrichtung des *Windows-Subsystems für Linux* [nachträglich installiert](https://docs.microsoft.com/de-de/windows/wsl/install-win10) werden. Das XSLT-Schema [history.xsl](history.xsl) folgt dem [XSLT-Standard 1.0](http://www.w3.org/1999/XSL/Transform) und kann mittels beliebiger XML-Editoren angewendet werden.

Direkt zur Dokumentation der einzelnen Skripte / Schemata:

| [BASH-Skripte](#bash-skripte) | [XSLT-Schemata](#xslt-schemata) |
| - | - |
| [getHistory.sh](#getHistory) | [history.xsl](#history-xsl) |
| [getArticles.sh](#getArticles) | [images.xsl](#images-xsl) |
| [getImageTable.sh](#getImageTable) | |

---

## BASH-Skripte

### <a name="getHistory">[getHistory.sh](getHistory.sh)</a>

Das Skript ruft eine angegebene Wikipedia-Artikelgeschichte ab und speichert neben der unveränderten HTML-Datei auch eine auf Kennwerte reduzierte und vom HTML freigestellte XML. ([Siehe unten](#history-xsl)) Für den zweiten Schritt ist es dabei notwendig, dass sich die Transformationsdatei (i.d.R. [history.xsl](history.xsl)) im Skriptverzeichnis befindet.

```bash
sh getHistory.sh -u URL -v VERZEICHNIS
```
Der Aufruf ist optional parametrisiert und akzeptiert die Parameter `-u` zur Angabe der abzurufenden URL sowie `-v` zur Angabe eines Arbeitsverzeichnisses, um die Ergebnisdateien dort abzulegen. Es ist angeraten, die Parameter in Anführungszeichen zu setzen, um eine korrekte Übernahme auch bei komplexeren Zeichenketten (mit Leerzeichen und anderen Sonderzeichen) zu gewährleisten. Wird keine URL angegeben, wird diese zur Laufzeit des Skriptes abgefragt. Sollte kein Arbeitsverzeichnis angegeben sein, werden die Ergebnisdateien im Skriptverzeichnis abgelegt. Die Prozesse werden in einem Logfile dokumentiert.
Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc`: [http://xmlsoft.org/XSLT/xsltproc.html]
- `wget`: [https://wiki.ubuntuusers.de/wget/]

### <a name="getArticles">[getArticles.sh](getArticles.sh)</a>

Das Skript ruft eine Reihe von Wikipedia-Artikelversionen ab und speichert diese als XML-Datei. Die XML entspricht dabei folgender Form:

```xml
<article>
	<version id= >
	</version>
</article>
```

Der Abruf folgt einer zu definierenden ID-Liste, wobei diese entweder als simples Textfile übergeben werden kann. Alternativ wird über den Aufruf des Skriptes `getHistory.sh` eine ID-Liste erzeugt, die weiterhin auch zeitlich eingeschränkt werden kann. Der Skriptverlauf wird in eine Logfile geschrieben.

```bash
sh getArticles.sh -u URL -v VERZEICHNIS -b BEGINNZEITRAUM -e ENDEZEITRAUM
```
Der Aufruf ist optional parametrisiert und akzeptiert die Parameter `-v` zur Angabe eines Arbeitsverzeichnisses sowie `-u` zur Angabe der URL der zugehörigen Versionsgeschichte. Es ist angeraten, die Parameter in Anführungszeichen zu setzen, um eine korrekte Übernahme auch bei komplexeren Zeichenketten (mit Leerzeichen und anderen Sonderzeichen) zu gewährleisten. Wird keine URL angegeben, wird diese zur Laufzeit des Skriptes abgefragt. Sollte kein Arbeitsverzeichnis angegeben sein, werden die Ergebnisdateien im Skriptverzeichnis abgelegt. Über die Parameter `-b` *Beginn*  sowie `-e` *Ende* kann der Zeitraum der abzurufenden Artikel eingegrenzt werden. Die Datumsangaben sind im Format `YYYYMMDDhhmm` anzugeben. Werden Beginn oder Ende nicht gesetzt, kann der abzurufende Zeitraum zur Laufzeit des Skriptes angegeben werden. Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc`: [http://xmlsoft.org/XSLT/xsltproc.html]
- `wget`: [https://wiki.ubuntuusers.de/wget/]
- `xmllint`: [http://xmlsoft.org/xmllint.html]
- `sed`: [http://sed.sourceforge.net/]

### <a name="getImageTable">[getImageTable.sh](getImageTable.sh)</a>

Das Skript legt eine HTML-Tabelle an, in der alle aus der Quelldatei ermittelten Bilder allen Artikelversionen gegenübergestellt werden. Aus dieser Tabelle lässt sich somit die Entwicklung der Verwendung einzelner Bilder über den definierten Versionsverlauf nachvollziehen.

```bash
sh getImageTable.sh -v VERZEICHNIS
```

Der Aufruf ist optional parametrisiert und akzeptiert die Parameter `-v` zur Angabe eines Arbeitsverzeichnisses. Zur Prüfung der Artikelversionen gegen den Bildbestand werden zunächst alle einzigartigen (unique) Bilder ermittelt, diese werden dabei anhand der URL identifiziert. Anschließend wird die HTML-Tabelle geschrieben, wobei für jede Artikelversion geprüft wird, welche Bilder aus dem Gesamtbestand darin vorkommen. Das Ergebnis wird in eine HTML-Datei (default `imageTable.html`) geschrieben. Die einzelnen Skript-Schritte werden in einem Logfile dokumentiert.
Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc`: [http://xmlsoft.org/XSLT/xsltproc.html]

---

## XSLT-Schemata

### <a name="history-xsl">[history.xsl](history.xsl)</a>

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
Das Schema zerlegt die dargestellten Datumsangaben in das neutrale Format `YYYYMMDDhhmm` um eine einfache Verarbeitung zu gewährleisten. Mit Stand 20.01.2020 ist nur die Zerlegung des in der chinesischen Wikipedia benutzten Datumsformat (etwa `2020年1月4日 (六) 10:20`) implementiert.

Außerhalb des Skripts `getHistory.sh` kann das Schema mittels des Kommandozeilenprogramms `xsltproc` ausgeführt werden:

```bash
xsltproc -v -o ZIELDATEI history.xsl HTMLDATEI
```

### <a name="images-xsl">[images.xsl](images.xsl)</a>
