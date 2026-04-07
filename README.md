# 🎟️ E-Ticket App – Flutter

Eine vollständige E-Ticket App für Android mit Kauf, Speicherung und Anzeige von Tickets.

## Features

- **Ticket kaufen** – Formular mit Kategorie, Datum, Sitzplatz, Preis
- **Ticket-Anzeige** – Kartenansicht mit QR-Code, Ticket-ID und Allen Details
- **Ticket einlösen** – Status auf "Verwendet" setzen
- **Lokale Speicherung** – Persistierung via `shared_preferences`
- **Automatisches Ablaufen** – vergangene Events werden als "Abgelaufen" markiert
- **6 Kategorien** – Konzert, Sport, Theater, Festival, Kino, Konferenz
- **Demo-Tickets** – beim ersten Start automatisch vorhanden

## Projektstruktur

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart          # Farben, Fonts, ThemeData
├── models/
│   └── ticket.dart             # Ticket-Datenmodell
├── services/
│   └── ticket_service.dart     # Speicherung & Logik
├── screens/
│   ├── home_screen.dart        # Ticket-Liste (Aktiv / Vergangen)
│   ├── buy_ticket_screen.dart  # Ticket-Kauf-Formular
│   └── ticket_detail_screen.dart # Detailansicht mit QR
└── widgets/
    ├── ticket_card.dart        # Ticket-Listeneintrag
    ├── stat_chip.dart          # Statistik-Chips (Oben)
    └── qr_widget.dart          # QR-Code Darstellung
```

## Setup in Android Studio

### 1. Projekt erstellen & Dateien kopieren
```bash
flutter create eticket_app
cd eticket_app
```
Ersetze alle generierten Dateien mit den bereitgestellten Dateien.

### 2. Schriftart herunterladen
- Gehe zu https://fonts.google.com/specimen/Outfit
- Lade die TTF-Dateien herunter:
  - Outfit-Regular.ttf
  - Outfit-Medium.ttf
  - Outfit-SemiBold.ttf
  - Outfit-Bold.ttf
- Erstelle `assets/fonts/` Ordner und kopiere die Dateien hinein

### 3. Dependencies installieren
```bash
flutter pub get
```

### 4. App starten
```bash
flutter run
```

## Echter QR-Code (optional)

Das `qr_widget.dart` enthält einen visuellen QR-Platzhalter.
Für echte, scanbare QR-Codes füge `qr_flutter` hinzu:

```yaml
# pubspec.yaml
dependencies:
  qr_flutter: ^4.1.0
```

Dann in `qr_widget.dart`:
```dart
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends StatelessWidget {
  final String data;
  final double size;
  const QrWidget({super.key, required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }
}
```

## Design

- **Farbschema:** Deep Noir + Electric Violet + Gold
- **Font:** Outfit (Google Fonts)
- **Stil:** Premium Dark UI, glühende Ticket-Karten, animierte Übergänge
