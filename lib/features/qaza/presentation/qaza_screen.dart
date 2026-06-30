import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/providers.dart';
import '../data/qaza_plan.dart';
import 'qaza_dashboard.dart';
import 'qaza_form_step.dart';
import 'qaza_intro_step.dart';

enum _QazaStep { intro, form, dashboard }

/// Entry point for `/app/qaza`. First-time users see a 2-step wizard
/// (explainer, then per-prayer entry form); once a plan is saved, returning
/// users land on the progress dashboard with an "Edit backlog" shortcut
/// back into the form (skipping the explainer on edit).
class QazaScreen extends ConsumerStatefulWidget {
  const QazaScreen({super.key});

  @override
  ConsumerState<QazaScreen> createState() => _QazaScreenState();
}

class _QazaScreenState extends ConsumerState<QazaScreen> {
  _QazaStep? _step;

  Future<void> _save(QazaPlanParsed plan) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    await ref
        .read(userRepositoryProvider)
        .updateQazaPlan(uid: uid, qazaPlan: plan.toFirestoreMap());
    if (mounted) setState(() => _step = _QazaStep.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final appUserAsync = ref.watch(appUserStreamProvider);

    return appUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (u) {
        final plan = u?.qazaPlanParsed ?? QazaPlanParsed.defaults();
        // Decide the starting step only once per plan-completion state —
        // afterwards _step drives navigation between wizard steps.
        _step ??= plan.setupComplete ? _QazaStep.dashboard : _QazaStep.intro;

        switch (_step!) {
          case _QazaStep.intro:
            return QazaIntroStep(
              onNext: () => setState(() => _step = _QazaStep.form),
            );
          case _QazaStep.form:
            return QazaFormStep(
              initial: plan,
              showStepProgress: !plan.setupComplete,
              onBack: () => setState(
                () => _step = plan.setupComplete
                    ? _QazaStep.dashboard
                    : _QazaStep.intro,
              ),
              onSave: _save,
            );
          case _QazaStep.dashboard:
            return QazaDashboard(
              plan: plan,
              onEdit: () => setState(() => _step = _QazaStep.form),
            );
        }
      },
    );
  }
}
