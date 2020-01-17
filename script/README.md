## [getHistory.sh](getHistory.sh)

Das Skript ruft eine angegebene Wikipedia-Artikelgeschichte ab und speichert neben der unveränderten HTML-Datei auch eine auf Kennwerte reduzierte und vom HTML freigestellte XML. Für den zweiten Schritt ist es dabei notwendig, dass sich die Transformationsdatei (i.d.R. [history.xsl](history.xsl)) im Skriptverzeichnis befindet.
```
sh getHistory.sh -u URL -v VERZEICHNIS
```
Der Aufruf ist optional parametrisiert und akzeptiert die Parameter `-u` zur Angabe der abzurufenden URL sowie `-v` zur Angabe eines Arbeitsverzeichnisses, um die Ergebnisdateien dort abzulegen. Es ist angeraten, die Parameter in Anführungszeichen zu setzen, um eine korrekte Übernahme auch bei komplexeren Zeichenketten (mit Leerzeichen und anderen Sonderzeichen) zu gewährleisten. Wird keine URL angegeben, wird diese zur Laufzeit des Skriptes abgefragt. Sollte kein Arbeitsverzeichnis angegeben sein, werden die Ergebnisdateien im Skriptverzeichnis abgelegt.
Es werden folgende Kommandozeilenprogramme verwendet:

- `xsltproc` http://xmlsoft.org/XSLT/xsltproc.html
- `wget` https://wiki.ubuntuusers.de/wget/
