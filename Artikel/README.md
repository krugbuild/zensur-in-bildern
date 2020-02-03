# Forschungsdaten - Artikel

In den Unterordnern befinden sich die Forschungsdaten zu den untersuchten Artikeln. Die Ordnernamen folgen dabei den technischen Bezeichnungen, die zur Laufzeit der Skripte vergeben wurden. In der folgenden Liste werden die Unterordner den jeweiligen Artikeln auf der chinesischen Wikipedia gegenübergestellt.

| Lokales Verzeichnis | Zugehöriger Artikel |
| - | - |
| [/democracy_party](./democracy_party) | [Demokratische Partei Chinas - 中国民主党](https://zh.wikipedia.org/wiki/%E4%B8%AD%E5%9B%BD%E6%B0%91%E4%B8%BB%E5%85%9A) |
| [/falun_gong](./falun_gong) | [Falun Gong - 法轮功](https://zh.wikipedia.org/wiki/%E6%B3%95%E8%BD%AE%E5%8A%9F) |
| [/falun_gong_persecution](./falun_gong_persecution) | [Verfolgung von Falun Gong - 對法輪功的鎮壓](https://zh.wikipedia.org/wiki/%E5%B0%8D%E6%B3%95%E8%BC%AA%E5%8A%9F%E7%9A%84%E9%8E%AE%E5%A3%93)|
| [/taiwan_conflict](./taiwan_conflict) | [Taiwan Konflikt - 臺灣問題](https://zh.wikipedia.org/wiki/%E8%87%BA%E7%81%A3%E5%95%8F%E9%A1%8C) |
| [/tankman](./tankman) | [Tankman - 坦克人](https://zh.wikipedia.org/wiki/%E5%9D%A6%E5%85%8B%E4%BA%BA) |
| [/tiananmen](./tiananmen) | [Tiananmen Zwischenfall - 六四事件](https://zh.wikipedia.org/wiki/%E5%85%AD%E5%9B%9B%E4%BA%8B%E4%BB%B6) |
| [/tiananmen_army](./tiananmen_army) | [Volksbefreiungsarmee während der Tiananmenplatzproteste - 六四清场](https://zh.wikipedia.org/wiki/%E5%85%AD%E5%9B%9B%E6%B8%85%E5%9C%BA) |
| [/tibet](./tibet/) | [Autonomes Gebiet Tibet - 西藏自治区](https://zh.wikipedia.org/wiki/%E8%A5%BF%E8%97%8F%E8%87%AA%E6%B2%BB%E5%8C%BA) |
| [/umbrella_movement](./umbrella_movement) | [Umbrella Movement - 雨傘運動佔領區](https://zh.wikipedia.org/wiki/%E9%9B%A8%E5%82%98%E9%81%8B%E5%8B%95%E4%BD%94%E9%A0%98%E5%8D%80) |
| [/xinjian](./xinjian) | [Autonomes Gebiet Xinjiang - 新疆维吾尔自治区](https://zh.wikipedia.org/wiki/%E6%96%B0%E7%96%86%E7%BB%B4%E5%90%BE%E5%B0%94%E8%87%AA%E6%B2%BB%E5%8C%BA) |
| [/xinjian_history](./xinjian_history) | [Geschichte Xinjians - 新疆歷史](https://zh.wikipedia.org/wiki/%E6%96%B0%E7%96%86%E6%AD%B7%E5%8F%B2) |

## Struktur der Unterordner
Die Unterordner beinhalten regelmäßig folgende Dateien. In Einzelfällen werden diese mit fortlaufenden Nummern, sofern die ursprüngliche Datei die Grenze von 100 MB überschreitet.

| Datei | Funktion |
| - | - |
| `articleData_log.txt` | Protokoll zum Abruf der Artikeldaten. |
| `historyData.xml` | Artikelhistorie im XML-Format. |
| `historyData_log.txt` | Protokoll zum Abruf und Transformation der Artikelhistorie. |
| `imageData.xml` | Bilddaten der Artikelhistorie im XML-Format. |
| `imageData_log.txt` | Protokoll zur Transformation der Bilddaten der Artikelhistorie. |
| `imageTable.html` | Auswertungsmatrix der Bilder der Artikelhistorie. Aufgerufen aus der [Leseansicht](https://krugbuild.github.io/zensur-in-bildern/Artikel) wird die Datei im Browser gerendert. Aus der Repositoriumsansicht heraus wird der Quelltext der Datei geöffnet. |
| `imageTable_log.txt` | Protokoll zur Auswertungsmatrix der Bilder der Artikelhistorie. |
| `README.md` | Dokumentation der Quellenauswertung sowie Quellenerhebung. |