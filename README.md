# HWWI Style Guide für R-Grafiken

Einheitliches Layout für alle Diagramme und Abbildungen des Hamburgischen WeltWirtschaftsInstituts (HWWI) in R / `ggplot2`.

Dieses Repository enthält:

| Datei | Inhalt |
|---|---|
| `hwwi_theme.R` | Themes, Farbpalette, Schriftart und Speicherfunktion |
| `HWWI_Style_Guide.pdf` | Richtlinien, Vorher-Nachher-Beispiel und R-Code für alle Diagrammtypen |

**Ziele:** einheitliches Erscheinungsbild, bessere Lesbarkeit, Vergleichbarkeit zwischen Präsentationen, Wiedererkennbarkeit.

---

## Schnellstart

```r
source("hwwi_theme.R")

plot <- ggplot(data, aes(x, y)) +
  geom_col(fill = hwwi_blue) +
  theme_hwwi() +
  theme(legend.position = "bottom")

hwwi_save_plot(plot, "meine_grafik.png")   # alternativ: .pdf, .jpg
```

Beim ersten Ausführen installiert das Skript fehlende Pakete über `pacman` und richtet die Schriftart **Verdana** ein.

> **Hinweis:** Das Laden der Schrift (`extrafont::loadfonts(device = "win")`) ist auf Windows ausgelegt. Unter macOS/Linux muss Verdana ggf. separat eingerichtet werden.

---

## Themes

| Funktion | Verwendung |
|---|---|
| `theme_hwwi()` | Standard (Säulen, Linien, Punkte); `grid = "h"` (Standard) oder `"hv"` |
| `theme_hwwi_flip()` | Horizontale Balkendiagramme (mit `coord_flip()`) |
| `theme_hwwi_pie()` | Kreisdiagramme |
| `theme_hwwi_map()` | Karten |

Die Standard-Schriftgrößen sind im Theme bereits gesetzt (Basisgröße 12): Achsentitel 18 pt, Achsenbeschriftung und Legende 16 pt, Quelle 12 pt. Datenlabels: `geom_text(size = 5)`.
Die Legende ist standardmäßig ausgeblendet und muss bei Bedarf mit `theme(legend.position = "bottom")` aktiviert werden.

## Farben

| Variable | Hex |
|---|---|
| `hwwi_light_blue` | `#B4CAE2` |
| `hwwi_blue` | `#004F9F` |
| `hwwi_dark_blue` | `#14387F` |
| `hwwi_rubin` | `#B80E80` |
| `hwwi_dark_rubin` | `#810759` |
| `hwwi_grey` | `#D0D0D0` |
| `hwwi_dark_grey` | `#3C3C3C` |

Fertige Paletten: `hwwi_palette_default`, `hwwi_palette_blue`, `hwwi_palette_rb`, `col6` / `col10` (für Karten bzw. Kreisdiagramme) und `col7`.
Rubin sparsam und gezielt zur Hervorhebung einsetzen (z. B. wichtigste Linie oder Balken).

## Speichern

```r
hwwi_save_plot(plot, filename, width = 11, height = 6, dpi = 400, bg = "white")
```

Unterstützt `.png`, `.jpg`, `.jpeg` und `.pdf`.

---

## Allgemeine Regeln

- Grafiken mit R erstellen und das HWWI-Theme verwenden
- Gute Lesbarkeit: ausreichende Schriftgröße, keine Überlappungen
- In der Regel **kein Grafiktitel**
- Achsen beschriften, Achsentitel sparsam einsetzen; **Jahresachsen ohne Titel**
- Legende in der Regel mittig unter der Grafik
- Quelle rechtsbündig unter der Grafik (bei Karten und Kreisdiagrammen mittig)
- Dezimaltrennzeichen nach Sprache der Veröffentlichung: Komma (deutsch), Punkt (englisch)

```r
# Achsen
scale_y_continuous(labels = scales::label_number(decimal.mark = ","))
# Datenlabels
format(x, decimal.mark = ",")
```

## Quellenangaben

Mehrere Quellen aufsteigend nach Jahr sortieren, durch Kommas trennen, mit Punkt abschließen.

| | Deutsch | Englisch |
|---|---|---|
| Standard | Quelle: Autor/Institution (evtl. Details) (Jahr). | Source: Author/Institution (Year). |
| Eigene Auswertung | Quelle: Eigene Berechnungen des HWWI. | Source: Own calculations by HWWI. |
| Überarbeitete Abbildung | Quelle: Eigene Darstellung nach Autor/Institution. | Source: Own illustration based on Author/Institution. |

Beispiel: `Quelle: Deutsche Bundesbank (2025), World Bank (World Development Indicators) (2026), eigene Berechnungen des HWWI.`

## Hinweise je Diagrammtyp

| Typ | Theme | Besonderheiten |
|---|---|---|
| Liniendiagramm / Zeitreihe | `theme_hwwi()` | Wichtigste Linie in `hwwi_dark_rubin`, übrige in dezenten Farben; Legende unten |
| Balkendiagramm | `theme_hwwi()` | Beschriftungen gut lesbar; wichtige Balken in `hwwi_dark_rubin` hervorheben |
| Horizontales Balkendiagramm | `theme_hwwi_flip()` | Balken beschriften, `coord_flip(clip = "off")` |
| Kreisdiagramm | `theme_hwwi_pie()` | Unterscheidbare Farben (`col10`), Quelle mittig |
| Karte | `theme_hwwi_map()` | Legendenwerte angeben (insb. Minimum und Maximum), Quelle mittig |

Vollständige R-Code-Beispiele für jeden Typ stehen im Anhang von `HWWI_Style_Guide.pdf`.
