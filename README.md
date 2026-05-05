# eTicket App

Eine plattformübergreifende Mobile-App zur Verwaltung digitaler Event-Tickets, entwickelt mit **Flutter & Dart**.

## Features
- Tickets kaufen, anzeigen und einlösen
- Kategorien: Konzert, Sport, Theater, Festival, Kino, Konferenz
- QR-Code-Anzeige pro Ticket
- Automatisches Ablaufen vergangener Tickets
- Persistente lokale Datenspeicherung
- Dark Mode UI mit modernem Design

## Technologien
| Technologie | Verwendung |
|---|---|
| Flutter / Dart | Cross-platform (iOS, Android, Web, Desktop) |
| flutter_bloc | State Management (BLoC Pattern) |
| SharedPreferences | Lokale Datenpersistenz |
| CustomPainter | QR-Code-Rendering |

## Architektur
Das Projekt folgt einer sauberen Schichtenarchitektur:
lib/
├── models/       # Datenmodelle
├── blocs/        # State Management
├── services/     # Business Logik
├── screens/      # UI Screens
└── widgets/      # Wiederverwendbare Komponenten
