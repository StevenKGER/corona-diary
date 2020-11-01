import 'package:flutter/material.dart';

String text = """
Mit der folgenden Datenschutzerklärung möchten wir Sie darüber aufklären, welche Arten Ihrer personenbezogenen Daten (nachfolgend auch kurz als "Daten“ bezeichnet) wir zu welchen Zwecken und in welchem Umfang im Rahmen der Bereitstellung unserer Applikation verarbeiten.

Die verwendeten Begriffe sind nicht geschlechtsspezifisch.

Stand: 1. November 2020

Verantwortlicher
Übersicht der Verarbeitungen
Die nachfolgende Übersicht fasst die Arten der verarbeiteten Daten und die Zwecke ihrer Verarbeitung zusammen und verweist auf die betroffenen Personen.

Arten der verarbeiteten Daten
Inhaltsdaten (z.B. Eingaben in Onlineformularen).
Meta-/Kommunikationsdaten (z.B. Geräte-Informationen; hier: GPS, IP-Adressen).
Nutzungsdaten (z.B. besuchte Webseiten, Interesse an Inhalten, Zugriffszeiten).

Kategorien betroffener Personen
Nutzer (z.B. Webseitenbesucher, Nutzer von Onlinediensten).

Übermittlung und Offenbarung von personenbezogenen Daten
Im Rahmen unserer Verarbeitung von personenbezogenen Daten kommt es vor, dass die Daten an andere Stellen, Unternehmen, rechtlich selbstständige Organisationseinheiten oder Personen übermittelt oder sie ihnen gegenüber offengelegt werden. Zu den Empfängern dieser Daten können z.B. Zahlungsinstitute im Rahmen von Zahlungsvorgängen, mit IT-Aufgaben beauftragte Dienstleister oder Anbieter von Diensten und Inhalten, die in eine Webseite eingebunden werden, gehören. In solchen Fall beachten wir die gesetzlichen Vorgaben und schließen insbesondere entsprechende Verträge bzw. Vereinbarungen, die dem Schutz Ihrer Daten dienen, mit den Empfängern Ihrer Daten ab.

Änderung und Aktualisierung der Datenschutzerklärung
Wir bitten Sie, sich regelmäßig über den Inhalt unserer Datenschutzerklärung zu informieren. Wir passen die Datenschutzerklärung an, sobald die Änderungen der von uns durchgeführten Datenverarbeitungen dies erforderlich machen. Wir informieren Sie, sobald durch die Änderungen eine Mitwirkungshandlung Ihrerseits (z.B. Einwilligung) oder eine sonstige individuelle Benachrichtigung erforderlich wird.

Sofern wir in dieser Datenschutzerklärung Adressen und Kontaktinformationen von Unternehmen und Organisationen angeben, bitten wir zu beachten, dass die Adressen sich über die Zeit ändern können und bitten die Angaben vor Kontaktaufnahme zu prüfen.

Begriffsdefinitionen
In diesem Abschnitt erhalten Sie eine Übersicht über die in dieser Datenschutzerklärung verwendeten Begrifflichkeiten. Viele der Begriffe sind dem Gesetz entnommen und vor allem im Art. 4 DSGVO definiert. Die gesetzlichen Definitionen sind verbindlich. Die nachfolgenden Erläuterungen sollen dagegen vor allem dem Verständnis dienen. Die Begriffe sind alphabetisch sortiert.

Personenbezogene Daten: "Personenbezogene Daten“ sind alle Informationen, die sich auf eine identifizierte oder identifizierbare natürliche Person (im Folgenden "betroffene Person“) beziehen; als identifizierbar wird eine natürliche Person angesehen, die direkt oder indirekt, insbesondere mittels Zuordnung zu einer Kennung wie einem Namen, zu einer Kennnummer, zu Standortdaten, zu einer Online-Kennung (z.B. Cookie) oder zu einem oder mehreren besonderen Merkmalen identifiziert werden kann, die Ausdruck der physischen, physiologischen, genetischen, psychischen, wirtschaftlichen, kulturellen oder sozialen Identität dieser natürlichen Person sind.
Verantwortlicher: Als "Verantwortlicher“ wird die natürliche oder juristische Person, Behörde, Einrichtung oder andere Stelle, die allein oder gemeinsam mit anderen über die Zwecke und Mittel der Verarbeitung von personenbezogenen Daten entscheidet, bezeichnet.
Verarbeitung: "Verarbeitung" ist jeder mit oder ohne Hilfe automatisierter Verfahren ausgeführte Vorgang oder jede solche Vorgangsreihe im Zusammenhang mit personenbezogenen Daten. Der Begriff reicht weit und umfasst praktisch jeden Umgang mit Daten, sei es das Erheben, das Auswerten, das Speichern, das Übermitteln oder das Löschen.
Erstellt mit kostenlosem Datenschutz-Generator.de von Dr. Thomas Schwenke

Die angegebenen Daten werden bei der Nutzung der Applikation an OpenStreetMap sowie OverPass übermittelt, um eine ideale Nutzererfahrung für Standortdaten zu ermöglichen.  © OpenStreetMap-Mitwirkende
Mehr Informationen zu OpenStreetMap sind unter https://www.openstreetmap.org/copyright verfügbar. Die Datenschutzerklärung von OpenStreetMap ist in englischer Sprache hier verfügbar: https://wiki.osmfoundation.org/wiki/Privacy_Policy.
OpenStreetMap wird von der OpenStreetMap Foundation (OpenStreetMap Foundation, St John’s Innovation Centre, Cowley Road, Cambridge, CB4 0WS, United Kingdom) sowie deren Gemeinschaft angeboten.
Die OverPass-API wird mit Daten des Projekts OpenStreetMap von FOSSGIS e.V. (Römerweg 5, 79199 Kirchzarten, Deutschland) bereitgestellt. Die Datenschutzerklärung finden Sie unter https://www.fossgis.de/datenschutzerkl%C3%A4rung/.
""";

class PrivacyPolicyPage extends StatefulWidget {
  PrivacyPolicyPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  PrivacyPolicyText createState() => PrivacyPolicyText();
}

class PrivacyPolicyText extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Datenschutzerklärung"),
      ),
      body: Container(
        child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(text),
        ),
      ),
    );
  }
}
