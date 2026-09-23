import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/jz_ui.dart';
import '../../../services/location_service.dart';
import '../data/mosque_data.dart';

/// Three-step mosque registration: mosque details → your details → review,
/// then a "request submitted" state. Every field is mandatory, and a
/// duplicate check runs before step 2.
///
/// There is no registration backend yet: submitting only shows the
/// confirmation. Photo/document pickers are placeholders for the same
/// reason (no file-picker package in the project).
class RegisterMosqueScreen extends ConsumerStatefulWidget {
  const RegisterMosqueScreen({super.key});

  @override
  ConsumerState<RegisterMosqueScreen> createState() =>
      _RegisterMosqueScreenState();
}

class _RegisterMosqueScreenState extends ConsumerState<RegisterMosqueScreen> {
  int _step = 0; // 0,1,2 = steps; 3 = submitted
  bool _showErrors1 = false;
  bool _showErrors2 = false;
  bool _confirmed = false;
  bool _locating = false;

  final _name = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  (double, double)? _location;
  String? _photo;

  String? _connection;
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _cnic = TextEditingController();
  String? _proof;
  final _mosquePhone = TextEditingController();
  final _auqaf = TextEditingController();

  static const _connections = [
    'Imam',
    'Committee member',
    'Mutawalli',
    'Caretaker',
    'Regular worshipper',
  ];

  @override
  void dispose() {
    for (final c in [
      _name,
      _street,
      _city,
      _fullName,
      _phone,
      _cnic,
      _mosquePhone,
      _auqaf,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _empty(TextEditingController c) => c.text.trim().isEmpty;

  int get _missing1 => [
    _empty(_name),
    _empty(_street),
    _empty(_city),
    _location == null,
    _photo == null,
  ].where((m) => m).length;

  int get _missing2 => [
    _connection == null,
    _empty(_fullName),
    _empty(_phone),
    _cnic.text.replaceAll('-', '').length != 13,
    _proof == null,
    _empty(_mosquePhone),
  ].where((m) => m).length;

  /// A registered mosque whose name matches — the duplicate check.
  Mosque? _duplicate() {
    String core(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'\b(jamia|masjid|mosque|e)\b'), ' ')
        .replaceAll(RegExp('[^a-z ]'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .join(' ');
    final mine = core(_name.text);
    if (mine.isEmpty) return null;
    for (final m in kDemoMosques) {
      if (core(m.name) == mine) return m;
    }
    return null;
  }

  Future<void> _continue1() async {
    if (_missing1 > 0) {
      setState(() => _showErrors1 = true);
      return;
    }
    final dup = _duplicate();
    if (dup != null) {
      final useExisting = await _showDuplicate(dup);
      if (!mounted || useExisting == null) return;
      if (useExisting) {
        context.pushReplacement('/app/mosques/${dup.id}');
        return;
      }
    }
    setState(() => _step = 1);
  }

  void _continue2() {
    if (_missing2 > 0) {
      setState(() => _showErrors2 = true);
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      _location = pos == null ? (24.9215, 67.0910) : (pos.lat, pos.lon);
    });
    if (pos == null) {
      AppSnackBar.error(
        context,
        'Could not read GPS — a sample pin was placed. Tap the map to move it.',
      );
    }
  }

  void _placePin(Offset local, Size size) {
    const lat0 = 24.9215, lon0 = 67.0910;
    final dx = (local.dx / size.width - 0.5) * 0.01;
    final dy = (local.dy / size.height - 0.5) * 0.01;
    setState(() => _location = (lat0 - dy, lon0 + dx));
  }

  void _pickPlaceholder(bool proof) {
    setState(() {
      if (proof) {
        _proof = 'appointment-letter.pdf';
      } else {
        _photo = 'signboard.jpg';
      }
    });
    AppSnackBar.success(
      context,
      'Sample file attached — real uploads arrive with the registration backend.',
    );
  }

  Future<bool?> _showDuplicate(Mosque m) {
    return showJzSheet<bool>(
      context,
      builder: (ctx) {
        final c = Theme.of(ctx).colorScheme;
        final t = Theme.of(ctx).textTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JzAvatar(
                  icon: Icons.info_outline_rounded,
                  size: 34,
                  iconSize: 18,
                  tone: JzAvatarTone.gold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This mosque is already registered',
                        style: t.titleMedium,
                      ),
                      Text(
                        'A registered mosque with the same name sits '
                        '${m.distanceLabel} away.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            JzCard(
              flat: true,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const JzAvatar(
                    icon: Icons.mosque_outlined,
                    size: 40,
                    iconSize: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(m.name, style: t.bodyLarge)),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: c.tertiary,
                            ),
                          ],
                        ),
                        Text(
                          '${m.address} · ${m.distanceLabel}',
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes, that’s it — use this one'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No, this is a different mosque'),
            ),
            const SizedBox(height: 12),
            Text(
              'Choosing “different” sends your request to the Al Islaah team. '
              'The same mosque cannot be registered twice.',
              textAlign: TextAlign.center,
              style: t.bodySmall,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 3) return _submitted(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _progress(context),
        const SizedBox(height: 14),
        ...switch (_step) {
          0 => _step1(context),
          1 => _step2(context),
          _ => _step3(context),
        },
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _progress(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    const titles = ['Mosque details', 'Your details', 'Review'];
    return JzCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step ? c.tertiary : c.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(titles[_step], style: t.titleSmall)),
              Text('Step ${_step + 1} of 3', style: t.labelMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = true,
    bool error = false,
    String? errorText,
    String? hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    Widget? suffix,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        inputFormatters: formatters,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          label: Text.rich(
            TextSpan(
              text: label,
              children: [
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: scheme.error),
                  ),
              ],
            ),
          ),
          hintText: hint,
          errorText: error ? errorText : null,
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _uploadBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required String? file,
    required bool error,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    if (file != null) {
      return JzCard(
        flat: true,
        padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file_outlined, color: c.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(file, style: t.bodyMedium)),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.close_rounded),
              onPressed: onRemove,
            ),
          ],
        ),
      );
    }
    return JzDashedBox(
      error: error,
      onTap: onPick,
      child: Column(
        children: [
          Icon(icon, color: error ? c.error : c.tertiary, size: 28),
          const SizedBox(height: 6),
          Text(title, style: t.titleSmall),
          const SizedBox(height: 2),
          Text(subtitle, textAlign: TextAlign.center, style: t.bodySmall),
        ],
      ),
    );
  }

  List<Widget> _step1(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final err = _showErrors1;
    return [
      if (err && _missing1 > 0)
        JzCard(
          padding: const EdgeInsets.all(14),
          color: Color.alphaBlend(
            c.errorContainer.withValues(alpha: 0.3),
            c.surface,
          ),
          borderColor: c.error.withValues(alpha: 0.45),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: c.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_missing1 ${_missing1 == 1 ? 'field' : 'fields'} still needed',
                      style: t.titleSmall,
                    ),
                    Text(
                      'A mosque cannot be registered until every field is filled.',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      else
        const JzNoteCard(
          body: Text(
            'Every field is required. A mosque cannot be registered until all '
            'of them are filled — that is what keeps duplicate and fake entries '
            'out.',
          ),
        ),
      const SizedBox(height: 18),
      const JzSectionLabel('Identity'),
      const SizedBox(height: 6),
      _field(
        _name,
        'Full mosque name',
        error: err && _empty(_name),
        errorText: 'Enter the mosque name',
      ),
      _field(
        _street,
        'Street address',
        error: err && _empty(_street),
        errorText: 'Enter the street address',
      ),
      _field(
        _city,
        'City / area',
        error: err && _empty(_city),
        errorText: 'Enter the city or area',
      ),
      const SizedBox(height: 6),
      const JzSectionLabel('Location', required: true),
      if (_location == null && err)
        JzDashedBox(
          error: true,
          onTap: _useGps,
          child: Column(
            children: [
              Icon(Icons.location_on_outlined, color: c.error, size: 28),
              const SizedBox(height: 6),
              Text('Drop a pin on the map', style: t.titleSmall),
              Text(
                'Tap GPS, or drag the pin to the mosque',
                style: t.bodySmall,
              ),
            ],
          ),
        )
      else
        _MapPicker(
          location: _location,
          locating: _locating,
          onGps: _useGps,
          onTap: _placePin,
        ),
      const SizedBox(height: 8),
      Text(
        'Drag the pin, or tap GPS. An accurate location is what stops duplicate '
        'entries.',
        style: t.bodySmall,
      ),
      const SizedBox(height: 18),
      const JzSectionLabel('Sign board photo', required: true),
      _uploadBox(
        icon: Icons.add_a_photo_outlined,
        title: 'Add a photo',
        subtitle: 'One where the mosque’s name is clearly readable',
        file: _photo,
        error: err && _photo == null,
        onPick: () => _pickPlaceholder(false),
        onRemove: () => setState(() => _photo = null),
      ),
      const SizedBox(height: 16),
      const JzNoteCard(
        body: Text(
          'Jama’at times are not entered here. The Al Islaah team adds them '
          'once the mosque is verified, so the times people see are always '
          'confirmed.',
        ),
      ),
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: err && _missing1 > 0 ? null : _continue1,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text('Continue'),
      ),
      if (err && _missing1 > 0) ...[
        const SizedBox(height: 8),
        Text(
          'Continue turns on once every field is filled.',
          textAlign: TextAlign.center,
          style: t.bodySmall,
        ),
      ],
    ];
  }

  List<Widget> _step2(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final err = _showErrors2;
    return [
      const JzSectionLabel('Your connection'),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: DropdownButtonFormField<String>(
          initialValue: _connection,
          items: [
            for (final r in _connections)
              DropdownMenuItem(value: r, child: Text(r)),
          ],
          onChanged: (v) => setState(() => _connection = v),
          decoration: InputDecoration(
            label: Text.rich(
              TextSpan(
                text: 'How are you connected to this mosque?',
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: c.error),
                  ),
                ],
              ),
            ),
            errorText: err && _connection == null ? 'Choose one' : null,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
        child: Text(_connections.join(' · '), style: t.bodySmall),
      ),
      _field(
        _fullName,
        'Your full name',
        error: err && _empty(_fullName),
        errorText: 'Enter your name',
      ),
      _field(
        _phone,
        'Phone number',
        hint: '+92 300 1234567',
        keyboard: TextInputType.phone,
        error: err && _empty(_phone),
        errorText: 'Enter your phone number',
        suffix: const Icon(Icons.lock_outline_rounded, size: 20),
      ),
      _field(
        _cnic,
        'CNIC number',
        hint: '42101-1234567-1',
        keyboard: TextInputType.number,
        formatters: [_CnicFormatter()],
        error: err && _cnic.text.replaceAll('-', '').length != 13,
        errorText: 'Enter all 13 digits',
        suffix: const Icon(Icons.lock_outline_rounded, size: 20),
      ),
      const JzNoteCard(
        body: Text(
          'Your phone number and CNIC are used only to verify you. Neither is '
          'ever shown in the app, and the Al Islaah team calls the number '
          'before approving.',
        ),
      ),
      const SizedBox(height: 18),
      const JzSectionLabel('Proof of role', required: true),
      _uploadBox(
        icon: Icons.upload_file_outlined,
        title: 'Add a document',
        subtitle: 'Appointment letter, committee resolution, or CNIC',
        file: _proof,
        error: err && _proof == null,
        onPick: () => _pickPlaceholder(true),
        onRemove: () => setState(() => _proof = null),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 16,
            color: c.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'For verification only — never shown in the app, and deleted once '
              'verified.',
              style: t.bodySmall,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'A regular worshipper can upload their CNIC here instead. The mosque is '
        'still listed either way — only an Imam or committee member can later '
        'edit its Jama’at times.',
        style: t.bodySmall,
      ),
      const SizedBox(height: 18),
      const JzSectionLabel('Mosque contact', required: true),
      const SizedBox(height: 6),
      _field(
        _mosquePhone,
        'Mosque phone number',
        keyboard: TextInputType.phone,
        error: err && _empty(_mosquePhone),
        errorText: 'Enter the mosque phone number',
      ),
      _field(
        _auqaf,
        'Auqaf registration number — optional',
        required: false,
        hint: 'Leave blank if none',
      ),
      const SizedBox(height: 6),
      FilledButton.icon(
        onPressed: _continue2,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text('Continue'),
      ),
    ];
  }

  List<Widget> _step3(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget row(String k, String v, {bool last = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 104, child: Text(k, style: t.bodySmall)),
          const SizedBox(width: 12),
          Expanded(child: Text(v, style: t.bodyMedium)),
        ],
      ),
    );
    Widget section(String title, int step, List<Widget> rows) => JzCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: t.titleMedium)),
              TextButton(
                onPressed: () => setState(() => _step = step),
                child: const Text('Edit'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(children: rows),
          ),
        ],
      ),
    );
    final loc = _location;
    return [
      section('Mosque details', 0, [
        row('Name', _name.text.trim()),
        row('Address', '${_street.text.trim()}, ${_city.text.trim()}'),
        row(
          'Location',
          loc == null
              ? '—'
              : '${loc.$1.toStringAsFixed(4)}, ${loc.$2.toStringAsFixed(4)}',
        ),
        row('Photo', _photo ?? '—'),
        row('Mosque phone', _mosquePhone.text.trim(), last: true),
      ]),
      section('Your details', 1, [
        row('Connection', _connection ?? '—'),
        row('Name', _fullName.text.trim()),
        row('Phone', _phone.text.trim()),
        row('CNIC', '${_cnic.text} · not shown publicly'),
        row('Proof', '${_proof ?? '—'} · not shown publicly', last: true),
      ]),
      JzCard(
        padding: const EdgeInsets.all(16),
        onTap: () => setState(() => _confirmed = !_confirmed),
        child: Row(
          children: [
            JzCheckBox(checked: _confirmed),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I confirm this information is correct and that this mosque '
                'really exists.',
                style: t.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: _confirmed ? () => setState(() => _step = 3) : null,
        child: const Text('Submit for registration'),
      ),
    ];
  }

  Widget _submitted(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    const steps = [
      'Form submitted',
      'Phone verification — a call within 2–3 days',
      'Photo and documents reviewed',
      'Listed in search once approved',
    ];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            children: [
              const Center(
                child: JzEmblem(icon: Icons.mark_email_read_outlined),
              ),
              const SizedBox(height: 18),
              Text(
                'Request submitted',
                textAlign: TextAlign.center,
                style: t.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '${_name.text.trim()}’s details are now with the Al Islaah team.',
                textAlign: TextAlign.center,
                style: t.bodyMedium,
              ),
              const SizedBox(height: 22),
              JzCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    for (var i = 0; i < steps.length; i++)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  i == 0
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 20,
                                  color: i == 0 ? c.primary : c.outline,
                                ),
                                if (i < steps.length - 1)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      color: c.outlineVariant,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: i < steps.length - 1 ? 14 : 0,
                                ),
                                child: Text(
                                  steps[i],
                                  style: t.bodyMedium?.copyWith(
                                    color: i == 0
                                        ? c.onSurface
                                        : c.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You’ll be notified as soon as it’s approved.',
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              style: AppTheme.tonalButtonStyle(context),
              onPressed: () => context.go('/app/mosques'),
              child: const Text('Back to Mosques'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Simple drawn map with a tap-to-place pin, coordinates chip and GPS button.
class _MapPicker extends StatelessWidget {
  const _MapPicker({
    required this.location,
    required this.locating,
    required this.onGps,
    required this.onTap,
  });

  final (double, double)? location;
  final bool locating;
  final VoidCallback onGps;
  final void Function(Offset, Size) onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final loc = location;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusInput),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: c.outline.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, box.maxHeight);
            return GestureDetector(
              onTapUp: (d) => onTap(d.localPosition, size),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _MapPainter(c))),
                  if (loc != null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 36,
                          color: Color(0xFFB3261E),
                          shadows: [
                            Shadow(blurRadius: 3, color: Colors.black38),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: JzChip(
                      loc == null
                          ? 'No pin yet'
                          : '${loc.$1.toStringAsFixed(4)}, ${loc.$2.toStringAsFixed(4)}',
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: locating ? null : onGps,
                      icon: locating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded, size: 16),
                      label: const Text('GPS'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.c);

  final ColorScheme c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = c.surfaceContainerLow);
    final block = Paint()
      ..color = c.surfaceContainerHighest.withValues(alpha: 0.55);
    final road = Paint()
      ..color = c.surface
      ..strokeWidth = 10;
    final minor = Paint()
      ..color = c.surface
      ..strokeWidth = 4;
    for (var x = 18.0; x < size.width; x += 70) {
      for (var y = 14.0; y < size.height; y += 56) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 52, 38),
            const Radius.circular(4),
          ),
          block,
        );
      }
    }
    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.38),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.42, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.78, size.height),
      minor,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.c != c;
}

/// Formats digits as a CNIC: 12345-1234567-1.
class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final d = digits.length > 13 ? digits.substring(0, 13) : digits;
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 5 || i == 12) b.write('-');
      b.write(d[i]);
    }
    final text = b.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
