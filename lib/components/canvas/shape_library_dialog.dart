import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/components/theming/uni_icon.dart';

/// A dialog for selecting pre-made engineering SVG symbols.
///
/// Returns the SVG string of the selected symbol, or null if cancelled.
class ShapeLibraryDialog extends StatefulWidget {
  const ShapeLibraryDialog({super.key});

  /// Shows the dialog and returns the selected SVG string.
  /// Returns null if the user cancels.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ShapeLibraryDialog(),
    );
  }

  @override
  State<ShapeLibraryDialog> createState() => _ShapeLibraryDialogState();
}

class _ShapeLibraryDialogState extends State<ShapeLibraryDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Shape Library',
                style: theme.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tap a symbol to insert it onto the canvas.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const Divider(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _symbols.length,
                itemBuilder: (context, index) {
                  final symbol = _symbols[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.of(context).pop(symbol.svg),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UniIcon(symbol.icon, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            symbol.name,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymbolEntry {
  final String name;
  final String svg;
  final Object icon;

  const _SymbolEntry(this.name, this.svg, this.icon);
}

/// Engineering SVG symbols for insertion.
/// SVG strings are minimal inline SVGs at 100x100 viewBox.
const _symbols = <_SymbolEntry>[
  _SymbolEntry(
    'Resistor',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="10" y1="50" x2="25" y2="50" stroke="black" stroke-width="2"/>'
    '<polyline points="25,50 30,35 35,65 40,35 45,65 50,35 55,65 60,35 65,50" '
    'fill="none" stroke="black" stroke-width="2"/>'
    '<line x1="65" y1="50" x2="90" y2="50" stroke="black" stroke-width="2"/>'
    '</svg>',
    FontAwesomeIcons.bolt,
  ),
  _SymbolEntry(
    'Capacitor',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="10" y1="50" x2="35" y2="50" stroke="black" stroke-width="2"/>'
    '<line x1="35" y1="25" x2="35" y2="75" stroke="black" stroke-width="2"/>'
    '<line x1="45" y1="25" x2="45" y2="75" stroke="black" stroke-width="2"/>'
    '<line x1="45" y1="50" x2="90" y2="50" stroke="black" stroke-width="2"/>'
    '</svg>',
    FontAwesomeIcons.bars,
  ),
  _SymbolEntry(
    'Diode',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="10" y1="50" x2="35" y2="50" stroke="black" stroke-width="2"/>'
    '<polygon points="35,28 65,50 35,72" fill="black"/>'
    '<line x1="65" y1="28" x2="65" y2="72" stroke="black" stroke-width="2"/>'
    '<line x1="65" y1="50" x2="90" y2="50" stroke="black" stroke-width="2"/>'
    '</svg>',
    FontAwesomeIcons.arrowRight,
  ),
  _SymbolEntry(
    'Ground',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="50" y1="20" x2="50" y2="50" stroke="black" stroke-width="2"/>'
    '<line x1="20" y1="50" x2="80" y2="50" stroke="black" stroke-width="2"/>'
    '<line x1="30" y1="60" x2="70" y2="60" stroke="black" stroke-width="2"/>'
    '<line x1="40" y1="70" x2="60" y2="70" stroke="black" stroke-width="2"/>'
    '</svg>',
    FontAwesomeIcons.triangleExclamation,
  ),
  _SymbolEntry(
    'Inductor',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="10" y1="50" x2="25" y2="50" stroke="black" stroke-width="2"/>'
    '<path d="M25,50 C30,30 40,70 45,50 C50,30 60,70 65,50" '
    'fill="none" stroke="black" stroke-width="2"/>'
    '<line x1="65" y1="50" x2="90" y2="50" stroke="black" stroke-width="2"/>'
    '</svg>',
    FontAwesomeIcons.waveSquare,
  ),
  _SymbolEntry(
    'Voltage Source',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="50" cy="50" r="30" fill="none" stroke="black" stroke-width="2"/>'
    '<line x1="50" y1="30" x2="50" y2="50" stroke="black" stroke-width="2"/>'
    '<line x1="35" y1="55" x2="65" y2="55" stroke="black" stroke-width="2"/>'
    '<line x1="50" y1="50" x2="50" y2="70" stroke="black" stroke-width="2"/>'
    '</svg>',
    FontAwesomeIcons.bolt,
  ),
  _SymbolEntry(
    'Op-Amp',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<polygon points="30,10 90,50 30,90" fill="none" stroke="black" stroke-width="2"/>'
    '<line x1="10" y1="30" x2="30" y2="30" stroke="black" stroke-width="2"/>'
    '<line x1="10" y1="70" x2="30" y2="70" stroke="black" stroke-width="2"/>'
    '<line x1="90" y1="50" x2="95" y2="50" stroke="black" stroke-width="2"/>'
    '<text x="55" y="55" font-size="14" text-anchor="middle">+</text>'
    '<text x="45" y="35" font-size="14" text-anchor="middle">-</text>'
    '</svg>',
    FontAwesomeIcons.shapes,
  ),
  _SymbolEntry(
    'NPN Transistor',
    '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="50" y1="10" x2="50" y2="40" stroke="black" stroke-width="2"/>'
    '<line x1="10" y1="50" x2="50" y2="50" stroke="black" stroke-width="2"/>'
    '<line x1="50" y1="40" x2="75" y2="60" stroke="black" stroke-width="2"/>'
    '<line x1="75" y1="60" x2="50" y2="80" stroke="black" stroke-width="2"/>'
    '<line x1="50" y1="80" x2="50" y2="90" stroke="black" stroke-width="2"/>'
    '<polygon points="55,50 65,55 55,60" fill="black"/>'
    '</svg>',
    FontAwesomeIcons.microchip,
  ),
];
