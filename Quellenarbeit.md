# Quellenarbeit

Um Wikipediaartikel als Quellen in einer historiographischen Analyse zu akzeptieren, muss zunächst deren technische Struktur betrachtet werden. Eine oft wiederholte Kritik an der Eignung als Lexikon ist die Tatsache, dass Artikel von praktisch jeder Person zu jedem Zeitpunkt geändert werden können. Dies impliziert eine Unbeständigkeit des Inhalts, die Abwesenheit von Nachweissystemen und daraus folgend eine Unzuverlässigkeit des Lexikons selbst. Verschiedene Untersuchungen konnten jedoch die inhaltlichen Befürchtungen wiederholt entkräften [^0] und bezüglich der Nachweissysteme ist sogar das Gegenteil der Fall. Die Wikipedia basiert auf der Software Mediawiki, die als eine der zentralen Funktionen eine Versionsverwaltung für sämtliche Seiten besitzt.

> Ein Beispiel ist auch die Wikipedia, hier erzeugt die Software nach jeder Änderung eines Artikels eine neue Version. Alle Versionen bilden in Wikipedia eine Kette, in der die letzte Version gültig ist; es sind keine Varianten vorgesehen. Da zu jedem Versionswechsel die grundlegenden Angaben wie Verfasser und Uhrzeit festgehalten werden, kann genau nachvollzogen werden, wer wann was geändert hat.[^1] 

Jede Version verfügt zudem über eine einmalige ID, mittels derer sie eindeutig und direkt adressiert werden kann - so wie im Beleg des Zitats geschehen. Da jedoch jede Änderung an einem Artikel eine neue Version generiert, unabhängig vom Ausmaß der Änderung, sind die Unterschiede zwischen benachbarten Versionen erwartungsgemäß gering. Die Herausforderung des Quellenbezugs und der -Aufbereitung liegt somit in der Verwaltung der anfallenden Datenmengen und der Auswahl von relevanten Fragmenten.

[^0]: Siehe zum Beispiel: Hesse, Wolfgang: Die Glaubwürdigkeit der Wikipedia, in: Information - Wissenschaft & Praxis 69 (4), 2018, S. 171–181. Online: <https://doi.org/10.1515/iwp-2018-0015>.

[^1]: Versionsverwaltung, in: Wikipedia, 05.02.2020. Online: <https://de.wikipedia.org/w/index.php?title=Versionsverwaltung&oldid=196516773>, Stand: 20.02.2020.

## Methodik

Um Veränderungen über größere Zeiträume nachvollziehen zu können, ohne sich auf jeweils winzige sprachliche Veränderungen je Versionssprung beziehen zu müssen, bietet es sich an, die Verwendung von Bildern in Artikeln über die Versionsgeschichte zu analysieren. Im Gegensatz zum Text eines Artikels, der sich durchaus hochfrequent mit kleinen Änderungen Entwickeln kann, ohne dass sich dabei der Sinngehalt signifikant ändert, sind Bilder relativ stabile Sinnträger. [???] Bilder werden im Mediawiki ähnlich wie Artikel behandelt, also werden auch bei ihnen sämtliche Änderungen gespeichert - gleichwohl sind diese eher die Ausnahme. Sie werden im HTML eines Artikels stets (und technisch zwangsläufig) mittels `<img>`-Tag eingebunden und sind damit über eine simple Mustererkennung zu identifizieren. Die inhaltliche Bewertung wird folglich über die Gegenwart oder Abwesenheit eines bestimmten Bildes in einer bestimmten Version durchgeführt. Diese Annäherung an den Untersuchungsgegenstand über den Quelltext der einzelnen Artikel ermöglicht es zudem, die Analyse unabhängig von spezialisierten Sprachkenntnissen durchzuführen, da der auszuwertende Quelltext stets in HTML geschrieben ist.

Da der Quellenbezug und die Quellenaufbereitung hoch repetitive Aufgaben sind, bietet sich die Automatisierung über Skripte an. Als Quellenbezug sei hier das Herunterladen sämtlicher Versionen aller untersuchten Artikel und deren strukturierte Speicherung bezeichnet. Die im HTML-Format vorliegenden Artikelversionen sind ihrer Art nach für eine Anzeige im Browser und somit eine gute Lesbarkeit durch Menschen konzipiert. Für die weitere Verarbeitung gilt es also, die relevanten Informationen auszulesen und in ein strukturiertes Format zu übersetzen. Wegen seiner sprachlichen Nähe zu HTML wurde hier XML als Zielformat gewählt, da die gewünschten Informationen mittels XSLT-Schemata direkt aus dem HTML-Quelltext in eine XML-Struktur überführt werden können. Auf Grundlage dieser Daten kann schließlich eine wiederum menschenlesbare Auswertungsmatrix erstellt werden, in der das Verhältnis aller Bilder einer Artikelhistorie mit allen Versionen einer Artikelhistorie gegenüber gestellt werden, wodurch eine Auswertung des Bildverlaufs je Artikel erst möglich wird. (Eine detaillierte Beschreibung des Prozesses findet sich im folgenden Kapitel.)

Dem Anspruch an eine freie Wissenschaft folgend, wurde bei der Wahl der technischen Mittel stets auf den Einsatz von Open Source geachtet, es wurden alle Teile des Forschungsprozesses offengelegt und die Ergebnisse unter freien Lizenzen zur Verfügung gestellt.[^y] Als Skriptumgebung wurde die [BASH](https://www.gnu.org/software/bash/) gewählt, die dort verwendeten Konsolenprogramme sind über gebräuchliche Repositorien verfügbar und zur Ausführung kamen Systeme auf Basis von GNU/Linux zum Einsatz. Weiterhin sind sämtliche Skripte und Schemata dieses Projekts unter [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/de/) und alle Auswertungen und Ergebnisse unter [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/de/) lizenziert. 

[^y]: Vgl. Grötschel, Martin: Elektronisches Publizieren, Open Access, Open Science und ähnliche Träume, in: Wissenschaftliches Publizieren: zwischen Digitalisierung, Leistungsmessung, Ökonomisierung und medialer Beobachtung, Berlin ; Boston 2016, S. 252.

## Exemplarischer Ablauf

Die im Folgenden genannten Skripte finden sich im Unterordner [~/Skripte](./Skripte) und sind in der zugehörigen ReadMe-Datei sowie im Quelltextkommentar ausführlich beschrieben. Weiterhin ist dort der idealtypische Ablauf des Datenabrufs in aller Kürze dargestellt.

Als Beispiel soll der Artikel zur [Autonomen Region Tibet](https://zh.wikipedia.org/wiki/%E8%A5%BF%E8%97%8F%E8%87%AA%E6%B2%BB%E5%8C%BA) dienen.[^2] Die [Artikelhistorie](https://zh.wikipedia.org/w/index.php?title=%E8%A5%BF%E8%97%8F%E8%87%AA%E6%B2%BB%E5%8C%BA&action=history) zeigt beim ersten Aufruf nur die letzten 50 Versionen. Um die vollständige Versionsgeschichte zu beziehen, muss deshalb der Parameter `limit` auf einen ausreichend hohen Wert gesetzt werden. Da selbst sehr häufig editierte Artikel selten über 10.000 Versionen kommen, ist ein Wert von 50.000 eine sichere Wahl. Die URL sähe dann wie folgt aus:

```URL
https://zh.wikipedia.org/w/index.php?title=%E8%A5%BF%E8%97%8F%E8%87%AA%E6%B2%BB%E5%8C%BA&limit=50000&action=history
```

Mit dieser parametrisierten URL wird nun das Skript `getArticles.sh` aufgerufen. Da URLs Steuerzeichen enthalten können, sollte die URL in Anführungszeichen übergeben werden. Über den Parameter `-v` setzen wir das Arbeitsverzeichnis 'tibet' und über die Parameter `-b` und `-e` definieren wir den Zeitraum der abzurufenden Daten. Da der Artikel zur Autonomen Region Tibet im April 2003 angelegt wurde, definieren wir den Zeitraum zwischen 2003 und heute, um alle Artikelversionen mit einzuschließen. Die Notation der Datumsangaben folgt dabei dem Schema `YYYYMMDDhhmm`. Der Aufruf sieht somit wie folgt aus:

```bash
sh getArticles.sh -u 'https://zh.wikipedia.org/w/index.php?title=%E8%A5%BF%E8%97%8F%E8%87%AA%E6%B2%BB%E5%8C%BA&limit=50000&action=history' -v tibet -b 200304010000 -e 202002200000
```

Nachdem das Skript erfolgreich durchgelaufen ist, finden sich im Arbeitsverzeichnis fünf Dateien:

- `articleData.xml` - Hier sind alle Artikelversionen kumuliert gespeichert. Da die potentielle Datenmenge je nach Artikel sehr groß ist, wird ab 200 MB Dateigröße eine neue Datei mit angehangenem Zähler angelegt.
- `articleData_log.txt` - In dieser Logdatei ist der Verlauf des Datenabrufs dokumentiert. Eventuelle Fehlermeldungen werden ebenfalls gespeichert.
- `historyData.html` - Dies eine Kopie der über die URL abgefragten Versionsgeschichte-Webseite.
- `historyData.xml` - Diese Datei enthält die Versionsinformationen der `historyData.html` in einem XML-Schema.
- `historyData_log.txt` - In dieser Logdatei ist der Abruf und die Transformation der Versionsgeschichte dokumentiert.

Nachdem die Logdateien auf Fehler überprüft wurden, wird als nächstes das Skript `getImages.sh` ausgeführt. Das Skript ermittelt sämtliche Bilder aus allen Versionen des Artikels und schreibt diese strukturiert in eine XML-Datei. Hierzu greift es auf die Daten in `articleData.xml` zu; sollten mehrere derartige Dateien im Arbeitsverzeichnis liegen, werden diese nacheinander ausgewertet.

```bash
sh getImages.sh -v tibet
```

Nach dem erfolgreichen Durchlauf, finden sich zwei weitere Dateien im Arbeitsverzeichnis:

- `imageData.xml` - In dieser XML-Datei sind alle Artikelversionen mit allen dort verzeichneten Bildern gespeichert.[^3]
- `imageData_log.txt` - In dieser Logdatei ist die Auswertung der Artikeldaten dokumentiert.

Schließlich soll diese Aufstellung von Artikeldaten zu Bilddaten in eine menschenlesbare Form gebracht werden. Das Skript `getImageTables.sh` erzeugt aus diesen Daten daher eine HTML-Tabelle, in der in der Kopfzeile alle verwendeten Bilder gezeigt werden und diese allen Artikelversionen gegenübergestellt werden. Der Aufruf ähnelt dem der `getImages.sh`, jedoch wird hier zusätzlich der Parameter `-n` gesetzt, damit keine erneute Transformation der Artikeldaten ausgelöst wird.

```bash
sh getImageTable.sh -v tibet -n
```

Das Ergebnis dieses Prozesses sind die folgenden beiden Dateien:

- `imageTable_log.txt` - In dieser Logdatei ist die Auswertung der `imageData.xml` zur `imageTable.html` dokumentiert.
- `imageTable.html` - In dieser HTML-Datei ist die Tabelle zur Quellenauswertung abgelegt.


![imageTable.html - Tibet](./Dokumente/Screenshot_imageTable_tibet.png)

> Screenshot der Datei imageTable.html (Auszug) des Artikels Autonome Region Tibet, bearbeitet, 20.02.2020.

In den ersten beiden Spalten der Tabelle finden sich die ID der einzelnen Versionen und das Datum der Version. Über die ID kann die Version eindeutig identifiziert und aufgerufen werden. Wenn die Version als *kleine Änderung* vermerkt wurde, ist hinter der ID ein *k* notiert. Es folgen die Spalten für die Bilder des Artikels. Die Anzahl ist je nach Artikel und untersuchtem Zeitraum unterschiedlich. Vermeintliche Dopplungen sind regelmäßig zu beobachten, jedoch handelt es sich dabei technisch um unterschiedliche Bilder. Der Algorithmus unterscheidet die Bilder nach ihrer URL; Sobald also ein Bild durch eine Variation (zum Beispiel durch ein Bild mit reduzierter Größe) des selben Bildes ersetzt wird, werden in der Tabelle beide Bilder angezeigt. Die letzten Spalten zeigen den Zeitpunkt des Eintrages, den verantwortlichen Benutzer bzw. IP-Adresse sowie eventuelle Kommentare zur Version. Wenn ein Bild in einer Version vorkommt, dann ist dies durch ein *x* markiert, zudem ist die betreffende Zelle farblich hinterlegt. Über diese Markierungen lassen sich die Verläufe der Bildzuordnungen über längere Zeiträume nachvollziehen.

## Erläuterung der Quelleneditionen / Artikel-README

Die Dokumentation und Auswertung der erhobenen Daten is je Artikel in der zugehörigen ReadMe hinterlegt. Das Dokument folgt einem standardisierten Aufbau: Die Überschrift besteht stets aus der deutschen Übersetzung und dem originalen Titel des Artikels, zudem ist ihr ein Verweis zum Artikel hinterlegt. Unter *Auffällige Bilder* sind all jene Bilder aufgeführt, die durch ihr Motiv, die ermittelten Zeitreihen oder andere Details aus der Menge der Bilder herausstechen. Sie sind besonders, jedoch nicht exklusiv, für eine historiographische Auswertung geeignet. Datumsangaben in der zugehörigen Tabelle sind stets im Format `YYYY-MM-DD (ID)` wobei sich der Klammerausdruck auf die ID der zugehörigen Artikelversion bezieht. Solche Datumsangaben sind i.d.R. mit einem Link zur entsprechenden Artikelversion hinterlegt. Unter *Artikeldaten* ist der Zeitraum des Datenabrufs der einzelnen Artikelversionen angeben, zudem wird auf die zugehörigen Logdateien verwiesen. Unter *Bilddaten* sind die Zeiträume zur Ermittlung der Bilddaten aus den Artikeldaten sowie zur Auswertung der Bilddaten durch Erstellung er Auswertungstabelle angegeben, weiterhin wird die zugehörigen Logdateien und die Auswertungstabelle verwiesen. Im Abschnitt *Ausgeschlossene Daten* sind all jene Dateien und deren Dateigröße aufgeführt, die im Rahmen der Auswertung angefallen sind, jedoch nicht mit ins Repositorium aufgenommen wurden. Diese Prozessdaten entsprechen üblicherweise den ursprünglichen Quelldaten und bieten nach erfolgter Auswertung keinen Mehrwert für die Untersuchung. Wenn es der Dokumentation oder Auswertung zuträglich war, wurde diese Struktur um weiter Abschnitte erweitert.

## Ausblick

Während sich die Methodik selbst in Anbetracht der Ergebnisse als valide und zielführende Herangehensweise erwiesen hat, gibt es bei der technischen Umsetzung durchaus Verbesserungsmöglichkeiten, die im Folgenden diskutiert werden.

Die Auswertung umfangreicher Datensätze ist unperformant. Insbesondere ist hier das Schreiben der HTML-Tabelle aus den Bilddaten betroffen. Da für jeden Datenpunkt ein Konsolenprogramm aufgerufen werden muss, steigt die Laufzeit dieses Skripts bei Artikeln mit vielen Versionen und Bildern schnell auf mehrere Tage. Weiterhin führen Dateigrößen von mehreren hundert Megabyte bei der Auswertung der Artikeldaten gewöhnliche Arbeitsrechner (die benutzten Systeme waren ein i5 mit 8 GB RAM und einer SSD sowie ein älterer i7 mit 12 GB RAM und einer HDD) schnell an ihre Grenzen, wodurch die Implementierung einer Stapelverarbeitung notwendig wurde. Durch die Umsetzung der Algorithmen in einer Programmiersprache wie z.B. Python, die zum Parsen und Transformieren von XML eigene Bibliotheken aufweist, dürfte durch den Wegfall der ständigen Programmaufrufe und eine elegantere interne Datenverwaltung eine deutliche Steigerung der Performanz erreicht sowie die Resilienz des Programms erhöht werden.

Die Präsentation insbesondere der historiographischen Analyse im Markdownformat ist wegen der mangelhaften Unterstützung von Fußnoten nur eingeschränkt empfehlenswert. Zwar ist *Markdown* als simple Auszeichnungssprache für eine Vielzahl von Dokumententypen ein völlig angemessenes Werkzeug, jedoch stößt es bei der gewohnten Gestalt akademischer Texte an seine Grenzen. Weiterhin ist die fehlende Unterstützung gängiger Zitationsprogramme ein Ärgerniss. Der suboptimalen Darstellung der Fußnoten kann mit entsprechenden Technologien, in der hier verwendeten *Leseansicht* ist es [jekyll](https://jekyllrb.com/) über [GitHub Pages](https://pages.github.com/), begegnet werden. In Anbetracht der fehlenden Literaturverwaltungsunterstützung weist das Schreiben in *Markdown* aber weiterhin signifikante Nachteile gegenüber üblichen Textverarbeitungsprogrammen auf.[^f]

Für folgende Untersuchungen ist die exakte Implementation der Versionsverwaltung der Bildartikel im Mediawiki zu klären. In Einzelfällen, wie dem Bild [Tiananmensquare.jpg](https://zh.wikipedia.org/wiki/File:Tiananmensquare.jpg) des Artikels zum Tiananmen Zwischenfall[^x], sind die Verweise im Artikel früher zu datieren, als die älteste Dateiversion. Der exakte Zustand des referenzierten Bildes kann für solche Zeiträume folglich nicht rekonstruiert werden.

---

[^2]: Um trotz mangelnder Sprachkenntnisse zumindest einen ersten Überblick zu bekommen und zielgerichteter auf der Seite navigieren zu können, sei die Verwendung des Chrome-Browsers empfohlen, da dieser eine automatische Übersetzung der Seiteninhalte anbietet. Da die tatsächliche Qualität der Übersetzung jedoch nur schwer abzuschätzen ist, sollte diese Übersetzung dabei nicht für die inhaltliche Auswertung herangezogen werden.

[^3]: Bei sehr großen Datenmengen kann es nötig sein, die `articleData.xml` in mehreren Schritten auszuwerten. Die dabei erzeugten `imageData.xml` können anschließend über das Schema `combineImages.xsl` zusammengefügt werden. Siehe hierzu die [entsprechende Dokumentation](./Skripte/README.md#combineimages-xsl).

[^f]: Zur Praxistauglichkeit verschiedener Applikationen und Vorgehensweisen beim Verfassen von Open Science Publikationen siehe: Heise, Christian: Von Open Access zu Open Science: zum Wandel digitaler Kulturen der wissenschaftlichen Kommunikation, Leuphana Universität Lüneburg, Lüneburg 2018, S. 223-233. Online: <http://offene-doktorarbeit.de/>.

[^x]: Siehe [Bildquellenauswertung des Artikels "Tiananmen Zwischenfall"](./Artikel/tiananmen/README.md)].