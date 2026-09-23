import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared building blocks for the redesigned screens. Each widget mirrors
/// one class from the design canvas (`.card`, `.prow`, `.cbox`, `.mrow`,
/// `.seclabel`, …) so the screens read like the design and stay consistent.

/// App-level success green used for "Current prayer" / "Now".
Color jzGreen(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF7CC47F)
    : const Color(0xFF2E7D32);

/// `.card` — surface, soft shadow, faint outline. Set [flat] for `.mcard`.
class JzCard extends StatelessWidget {
  const JzCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.flat = false,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool flat;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppTokens.radiusCard);
    return Padding(
      padding: margin,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? c.surface,
          borderRadius: radius,
          boxShadow: flat ? null : AppTokens.softShadow(context),
          border: Border.all(
            color:
                borderColor ?? c.outline.withValues(alpha: flat ? 0.3 : 0.22),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// `.seclabel` — small uppercase section label.
class JzSectionLabel extends StatelessWidget {
  const JzSectionLabel(
    this.text, {
    super.key,
    this.trailing,
    this.required = false,
  });

  final String text;
  final String? trailing;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: text.toUpperCase(),
                children: [
                  if (required)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: c.error),
                    ),
                ],
              ),
              style: t.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: c.onSurfaceVariant,
              ),
            ),
          ),
          if (trailing != null) Text(trailing!, style: t.labelSmall),
        ],
      ),
    );
  }
}

/// Circular icon holder (`.avatar.av-sec` / `.av-pri` / gold).
enum JzAvatarTone { secondary, primary, gold, error }

class JzAvatar extends StatelessWidget {
  const JzAvatar({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize,
    this.tone = JzAvatarTone.secondary,
  });

  final IconData icon;
  final double size;
  final double? iconSize;
  final JzAvatarTone tone;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final (bg, fg, border) = switch (tone) {
      JzAvatarTone.secondary => (c.secondaryContainer, c.secondary, null),
      JzAvatarTone.primary => (
        c.primaryContainer.withValues(alpha: 0.65),
        c.primary,
        c.outline.withValues(alpha: 0.15),
      ),
      JzAvatarTone.gold => (c.tertiary, c.onTertiary, null),
      JzAvatarTone.error => (c.errorContainer, c.error, null),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: border == null ? null : Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: fg, size: iconSize ?? size * 0.5),
    );
  }
}

/// `.cbox` — 26px rounded checkbox, filled when [checked]. [missed] tints
/// the empty border red.
class JzCheckBox extends StatelessWidget {
  const JzCheckBox({
    super.key,
    required this.checked,
    this.missed = false,
    this.size = 26,
    this.onTap,
  });

  final bool checked;
  final bool missed;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? c.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.31),
        border: Border.all(
          width: 2,
          color: checked
              ? c.primary
              : missed
              ? c.error.withValues(alpha: 0.55)
              : c.outline,
        ),
      ),
      alignment: Alignment.center,
      child: checked
          ? Icon(Icons.check_rounded, size: size * 0.7, color: c.onPrimary)
          : null,
    );
    if (onTap == null) return box;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: const EdgeInsets.all(4), child: box),
    );
  }
}

/// Row highlight states for [JzPrayerRow].
enum JzRowState { normal, current, missed }

/// `.prow` — checkbox, name + sub line, optional trailing widget. Rows are
/// separated by a hairline; the last row in a card should pass
/// [showDivider] false.
class JzPrayerRow extends StatelessWidget {
  const JzPrayerRow({
    super.key,
    required this.name,
    required this.checked,
    this.sub,
    this.subWidget,
    this.state = JzRowState.normal,
    this.trailing,
    this.onToggle,
    this.onTap,
    this.showDivider = true,
  });

  final String name;
  final bool checked;
  final String? sub;
  final Widget? subWidget;
  final JzRowState state;
  final Widget? trailing;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final bg = switch (state) {
      JzRowState.missed => c.errorContainer.withValues(alpha: 0.3),
      JzRowState.current => c.primaryContainer.withValues(alpha: 0.32),
      JzRowState.normal => Colors.transparent,
    };
    final subColor = switch (state) {
      JzRowState.missed => c.error,
      JzRowState.current => jzGreen(context),
      JzRowState.normal => c.onSurfaceVariant,
    };
    return Material(
      color: bg,
      child: InkWell(
        onTap: onTap ?? onToggle,
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(bottom: BorderSide(color: c.outlineVariant))
                : null,
          ),
          child: Row(
            children: [
              JzCheckBox(
                checked: checked,
                missed: state == JzRowState.missed,
                onTap: onToggle,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (subWidget != null)
                      subWidget!
                    else if (sub != null)
                      Text(
                        sub!,
                        style: t.labelSmall?.copyWith(
                          color: subColor,
                          fontWeight: state == JzRowState.normal
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// `.jchip` — small gold pill with a mosque icon and a Jama'at time.
class JzJamaatChip extends StatelessWidget {
  const JzJamaatChip(this.time, {super.key});

  final String time;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.tertiaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mosque_outlined, size: 12, color: c.onSurface),
          const SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// `.chip` / `.chip-gold`.
class JzChip extends StatelessWidget {
  const JzChip(
    this.label, {
    super.key,
    this.gold = false,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool gold;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final bg = selected
        ? c.primary
        : gold
        ? c.tertiaryContainer.withValues(alpha: 0.5)
        : c.surfaceContainerHighest;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 1.33,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? c.onPrimary : c.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// `.strip` — full-width card with a leading icon, title/subtitle and
/// either a chevron or a custom [trailing].
class JzStripCard extends StatelessWidget {
  const JzStripCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return JzCard(
      margin: margin,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? c.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: t.bodySmall),
                ],
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded, color: c.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// `.mrow` — list tile used for mosques and settings lists.
class JzListRow extends StatelessWidget {
  const JzListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: c.outlineVariant))
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.bodyLarge?.copyWith(color: titleColor)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: t.bodySmall),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Chevron in the muted ink colour, for list rows.
class JzChevron extends StatelessWidget {
  const JzChevron({super.key});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.chevron_right_rounded,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// Gold info note — `.card.pad-14` with a small gold "i" avatar.
class JzNoteCard extends StatelessWidget {
  const JzNoteCard({
    super.key,
    this.title,
    required this.body,
    this.icon = Icons.info_outline_rounded,
    this.margin = EdgeInsets.zero,
  });

  final String? title;
  final Widget body;
  final IconData icon;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return JzCard(
      margin: margin,
      padding: EdgeInsets.all(title == null ? 14 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JzAvatar(
            icon: icon,
            size: title == null ? 28 : 30,
            iconSize: 16,
            tone: JzAvatarTone.gold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: t.titleSmall),
                  const SizedBox(height: 4),
                ],
                DefaultTextStyle.merge(style: t.bodySmall, child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Important Note" card shared by the Qaza screens.
class JzImportantNote extends StatelessWidget {
  const JzImportantNote({super.key});

  @override
  Widget build(BuildContext context) => const JzNoteCard(
    title: 'Important Note',
    icon: Icons.priority_high_rounded,
    body: Text(
      'This calculation is only an estimate. Islam encourages sincere effort '
      'when the exact number is unknown. Enter your best estimate and remain '
      'consistent.',
    ),
  );
}

/// `.bar` — rounded progress track.
class JzBar extends StatelessWidget {
  const JzBar({super.key, required this.value, this.height = 6, this.width});

  final double value;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1).toDouble(),
          minHeight: height,
          backgroundColor: c.surfaceContainerHighest,
          color: c.primary,
        ),
      ),
    );
  }
}

/// Thin themed divider with custom vertical spacing.
class JzDivider extends StatelessWidget {
  const JzDivider({super.key, this.top = 12, this.bottom = 12});

  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top, bottom: bottom),
    child: Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

/// Switch row: title, optional subtitle, trailing [Switch].
class JzSwitchRow extends StatelessWidget {
  const JzSwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.bodyLarge),
              if (subtitle != null) Text(subtitle!, style: t.bodySmall),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// `- n +` stepper with outlined segments.
class JzStepper extends StatelessWidget {
  const JzStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.height = 52,
    this.large = true,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final double height;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    Widget btn(IconData icon, VoidCallback? onTap, {required bool left}) =>
        InkWell(
          onTap: onTap,
          child: Container(
            width: 52,
            height: height,
            decoration: BoxDecoration(
              border: Border(
                right: left ? BorderSide(color: c.outline) : BorderSide.none,
                left: left ? BorderSide.none : BorderSide(color: c.outline),
              ),
            ),
            child: Icon(
              icon,
              color: onTap == null ? c.onSurfaceVariant : c.primary,
            ),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.outline),
        borderRadius: BorderRadius.circular(AppTokens.radiusButton),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          btn(
            Icons.remove_rounded,
            value > min ? () => onChanged(value - 1) : null,
            left: true,
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: (large ? t.headlineSmall : t.titleMedium)?.copyWith(
                fontSize: large ? 22 : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          btn(
            Icons.add_rounded,
            value < max ? () => onChanged(value + 1) : null,
            left: false,
          ),
        ],
      ),
    );
  }
}

/// `.seg` — two or more pill segments; the selected one is filled.
class JzSegmented<T> extends StatelessWidget {
  const JzSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final entries = options.entries.toList();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.outline),
        borderRadius: BorderRadius.circular(99),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var i = 0; i < entries.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(entries[i].key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: entries[i].key == selected ? c.primary : null,
                    border: i == 0
                        ? null
                        : Border(left: BorderSide(color: c.outline)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entries[i].value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: entries[i].key == selected
                          ? c.onPrimary
                          : c.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pill search field (`.searchbar`).
class JzSearchBar extends StatelessWidget {
  const JzSearchBar({
    super.key,
    this.controller,
    this.hint = 'Mosque name or area',
    this.onTap,
    this.onChanged,
    this.autofocus = false,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(99),
      borderSide: BorderSide(color: c.outline.withValues(alpha: 0.55)),
    );
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded, color: c.onSurfaceVariant),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: c.onSurfaceVariant),
                  onPressed: () {
                    controller!.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: const BoxConstraints(minHeight: 52),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: c.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Dashed call-to-action row ("Register a new mosque", "Set your primary
/// mosque").
class JzDashedAction extends StatelessWidget {
  const JzDashedAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.gold = true,
    this.radius = AppTokens.radiusButton,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool gold;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: gold
            ? c.tertiary.withValues(alpha: 0.55)
            : c.outline.withValues(alpha: 0.9),
        radius: radius,
      ),
      child: Material(
        color: gold
            ? c.tertiaryContainer.withValues(alpha: 0.28)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                gold
                    ? Icon(Icons.add_location_alt_outlined, color: c.tertiary)
                    : JzAvatar(icon: icon, size: 34, iconSize: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.titleSmall),
                      Text(subtitle, style: t.bodySmall),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.chevron_right_rounded, color: c.tertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed box used for upload placeholders and empty map states.
class JzDashedBox extends StatelessWidget {
  const JzDashedBox({
    super.key,
    required this.child,
    this.error = false,
    this.onTap,
  });

  final Widget child;
  final bool error;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppTokens.radiusInput);
    final content = Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
    if (error) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: c.error, width: 1.5),
        ),
        child: content,
      );
    }
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: c.outline.withValues(alpha: 0.9),
        radius: AppTokens.radiusInput,
      ),
      child: content,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(0.75),
      );
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Large circular emblem with a gold icon (success states).
class JzEmblem extends StatelessWidget {
  const JzEmblem({super.key, required this.icon, this.size = 88});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF3A332C), Color(0xFF2A2521)]
              : [Colors.white, const Color(0xFFF6EFE0).withValues(alpha: 0.85)],
        ),
        boxShadow: AppTokens.softShadow(context),
        border: Border.all(color: c.outline.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: c.primary, size: size * 0.45),
    );
  }
}

/// Screen title used by the four bottom-nav roots (Mosques, Records, More).
class JzPageTitle extends StatelessWidget {
  const JzPageTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
  );
}

/// Opens a design-style bottom sheet (rounded top, drag handle).
Future<T?> showJzSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outline,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            builder(ctx),
          ],
        ),
      ),
    ),
  );
}

/// Formats an int with thousands separators (3040 → "3,040").
String jzCount(int n) {
  final s = n.abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
