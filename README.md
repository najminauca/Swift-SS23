# Swift-SS23 Prüfungsleistung

## Präambel
Die folgenden Aufgaben beschreiben die Anforderungen an zwei Apps, welche Clients des FruitShop-Servers sind. Laden Sie diesen aus Moodle herunter und starten Sie den Server per swift run. Auf http://127.0.0.1:8080 lässt sich die API-Dokumentation betrachten. Machen Sie sich mit der API und insbesondere dem Paginationsystem vertraut.

Listen werden mit den Query-Parametern page und per abgerufen. Beispiel: http://127.0.0.1: 8080/api/products?page=1&per=10. ”Page” ist die Seitennummer, welche mit 1 beginnt. ”Per” gibt an, wieviele Elemente pro Seite abgerufen werden sollen. Listeneintra ̈ge sind immer alphabetisch sortiert.

Der Fruit Shop Server implementiert kein Rollen- oder Rechtesystem. Außerdem gibt es keine Nutzer oder Sessions. Das Bezahlen einer Bestellung wird simuliert, indem der Client eine beliebige UUID als Transaktions-ID verschickt. Der Server sendet keine Emails und ruft auch keine andere HTTP-Services ab. Die Daten werden im Projektverzeichnis unter database.sqlite abgespeichert.
