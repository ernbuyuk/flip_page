import 'package:flutter/material.dart';

import 'theme_provider.dart';

/// Not kartının görseli: renkli kağıt zemini, rengin mürekkep tonunda süslü
/// çerçeve ve rengin simgesinden soluk bir filigran. Tüm sayfalar bunu kullanır.
class NoteCard extends StatelessWidget {
  final String? colorName;
  final Widget? child;
  final double? width;
  final double? height;
  final bool showWatermark;
  final bool shadow;

  const NoteCard({
    super.key,
    required this.colorName,
    this.child,
    this.width,
    this.height,
    this.showWatermark = true,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = NoteColor.style(colorName);
    final radius = BorderRadius.circular(16);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.paperLight, style.paper, style.paperDark],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: style.ink.withValues(alpha: 0.28),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(2, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showWatermark)
              LayoutBuilder(
                builder: (context, c) => Center(
                  child: Icon(
                    style.icon,
                    size: c.biggest.shortestSide * 0.55,
                    color: style.ink.withValues(alpha: 0.07),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/card_frame.png',
                fit: BoxFit.fill,
                color: style.ink.withValues(alpha: 0.85),
                colorBlendMode: BlendMode.srcIn,
                filterQuality: FilterQuality.medium,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

/// Kartın üstündeki "simge + SORU/CEVAP" etiketi.
class NoteCardLabel extends StatelessWidget {
  final String? colorName;
  final String text;
  final double fontSize;

  const NoteCardLabel({super.key, required this.colorName, required this.text, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final style = NoteColor.style(colorName);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(style.icon, size: fontSize + 4, color: style.ink),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: style.ink,
            ),
          ),
        ),
      ],
    );
  }
}

/// Renk seçici yuvarlağı: kağıt rengi, mürekkep halkası ve simge.
class NoteColorSwatch extends StatelessWidget {
  final String colorName;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  const NoteColorSwatch({
    super.key,
    required this.colorName,
    required this.selected,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final style = NoteColor.style(colorName);
    return Tooltip(
      message: style.label,
      child: Semantics(
        button: true,
        selected: selected,
        label: '${style.label} renk',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [style.paperLight, style.paper],
              ),
              border: Border.all(color: style.ink.withValues(alpha: selected ? 1 : 0.35), width: selected ? 3 : 1.2),
              boxShadow: selected
                  ? [BoxShadow(color: style.ink.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Icon(
              selected ? Icons.check : style.icon,
              size: size * 0.5,
              color: style.ink.withValues(alpha: selected ? 1 : 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
