import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CheckEligibilitySheet extends StatefulWidget {
  final ValueChanged<bool>? onResult;

  /// Fired right before the sheet closes when the user IS eligible.
  /// Receives the selected hospital name.
  /// The caller uses this to call profileProvider.addPendingDonation().
  final ValueChanged<String>? onEligible;

  const CheckEligibilitySheet({
    super.key,
    this.onResult,
    this.onEligible,
  });

  static Future<bool?> show(
    BuildContext context, {
    ValueChanged<bool>? onResult,
    ValueChanged<String>? onEligible,
  }) async {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckEligibilitySheet(
        onResult: onResult,
        onEligible: onEligible,
      ),
    );
  }

  @override
  State<CheckEligibilitySheet> createState() => _CheckEligibilitySheetState();
}

class _CheckEligibilitySheetState extends State<CheckEligibilitySheet> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  bool? _hasTattoo;
  bool? _hasChronicDisease;
  DateTime? _lastDonationDate;
  bool _neverDonated = true;
  String? _selectedHospital;

  String? _weightError;
  String? _ageError;

  bool _isEligible = false;
  String _ineligibleReason = '';

  static const List<String> _kHospitals = [
    'Abu El Reesh Children Hospital',
    'Ain Shams University Hospital',
    'Al Agouza Hospital',
    'Al Demerdash Hospital',
    'Al Galaa Military Hospital',
    'Al Haram Hospital',
    'Al Salam International Hospital',
    'Cairo University Hospital (Kasr El Aini)',
    'Cleopatra Hospital',
    'El Sahel Teaching Hospital',
    'El Shorouq Hospital',
    'Heliopolis Hospital',
    'International Medical Center',
    'Kobry El Kobba Military Hospital',
    'Maadi Military Hospital',
    'Misr International Hospital',
    'National Cancer Institute',
    'October 6 University Hospital',
    'Salam City Hospital',
    'Shubra El Kheima Hospital',
    'Wadi El Neel Hospital',
    'Zayed Specialized Hospital',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage == 0) {
      final weight = double.tryParse(_weightController.text.trim());
      final age = int.tryParse(_ageController.text.trim());
      setState(() {
        _weightError = weight == null
            ? 'Please enter your weight'
            : weight < 50
                ? 'Minimum weight is 50 kg'
                : null;
        _ageError = age == null
            ? 'Please enter your age'
            : age < 18
                ? 'Must be at least 18 years old'
                : age > 60
                    ? 'Must be 60 years or younger'
                    : null;
      });
      if (_weightError != null || _ageError != null) return;
    }
    if (_currentPage == 1 && _hasTattoo == null) return;
    if (_currentPage == 2 && _hasChronicDisease == null) return;
    if (_currentPage == 3 && !_neverDonated && _lastDonationDate == null) {
      return;
    }
    if (_currentPage == 4) {
      if (_selectedHospital == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a hospital'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }
      _computeEligibility();
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _computeEligibility() {
    if (_hasTattoo == true) {
      _isEligible = false;
      _ineligibleReason =
          'Getting a tattoo in the last 6 months may affect your eligibility to donate.';
      return;
    }
    if (_hasChronicDisease == true) {
      _isEligible = false;
      _ineligibleReason =
          'Such as diabetes, heart disease, hepatitis, HIV, or cancer.';
      return;
    }
    if (!_neverDonated && _lastDonationDate != null) {
      final days = DateTime.now().difference(_lastDonationDate!).inDays;
      if (days < 90) {
        _isEligible = false;
        _ineligibleReason =
            'You must wait at least 90 days between donations. You last donated $days days ago.';
        return;
      }
    }
    _isEligible = true;
  }

  void _onResultClose() {
    // Fire before closing so the caller can act on it
    if (_isEligible && _selectedHospital != null) {
      widget.onEligible?.call(_selectedHospital!);
    }
    Navigator.of(context).pop(_isEligible);
    widget.onResult?.call(_isEligible);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            if (_currentPage < 5)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 5,
                    backgroundColor:
                        AppTheme.grey.withValues(alpha: 0.3),
                    color: AppTheme.red,
                    minHeight: 6,
                  ),
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PageWeightAge(
                    weightController: _weightController,
                    ageController: _ageController,
                    weightError: _weightError,
                    ageError: _ageError,
                    onChanged: () => setState(() {
                      _weightError = null;
                      _ageError = null;
                    }),
                    onNext: _goNext,
                  ),
                  _PageYesNo(
                    step: 'Step 2 of 5',
                    icon: Icons.brush_outlined,
                    iconColor: AppTheme.purple,
                    title: 'Recent tattoo?',
                    subtitle:
                        'Getting a tattoo in the last 6 months may affect your eligibility to donate.',
                    selected: _hasTattoo,
                    onSelected: (v) => setState(() => _hasTattoo = v),
                    onNext: _goNext,
                  ),
                  _PageYesNo(
                    step: 'Step 3 of 5',
                    icon: Icons.medical_information_outlined,
                    iconColor: AppTheme.red,
                    title: 'Any chronic diseases?',
                    subtitle:
                        'Such as diabetes, heart disease, hepatitis, HIV, or cancer.',
                    selected: _hasChronicDisease,
                    onSelected: (v) =>
                        setState(() => _hasChronicDisease = v),
                    onNext: _goNext,
                  ),
                  _PageLastDonation(
                    selectedDate: _lastDonationDate,
                    neverDonated: _neverDonated,
                    onNeverDonatedTap: () => setState(() {
                      _neverDonated = true;
                      _lastDonationDate = null;
                    }),
                    onDateSelected: (d) => setState(() {
                      _lastDonationDate = d;
                      _neverDonated = false;
                    }),
                    onNext: _goNext,
                  ),
                  _PageHospital(
                    selectedHospital: _selectedHospital,
                    hospitals: _kHospitals,
                    onSelected: (v) =>
                        setState(() => _selectedHospital = v),
                    onNext: _goNext,
                  ),
                  _PageResult(
                    isEligible: _isEligible,
                    reason: _ineligibleReason,
                    onClose: _onResultClose,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1 ───────────────────────────────────────────────────────────────────

class _PageWeightAge extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController ageController;
  final String? weightError;
  final String? ageError;
  final VoidCallback onChanged;
  final VoidCallback onNext;

  const _PageWeightAge({
    required this.weightController,
    required this.ageController,
    required this.weightError,
    required this.ageError,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _QuestionHeader(
            icon: Icons.monitor_weight_outlined,
            iconColor: AppTheme.blue,
            step: 'Step 1 of 5',
            title: 'Basic Information',
            subtitle: 'We need a few details to check your eligibility.',
          ),
          const SizedBox(height: 32),
          _InputField(
            controller: weightController,
            label: 'Weight',
            hint: 'e.g. 70',
            suffixText: 'kg',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            error: weightError,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: ageController,
            label: 'Age',
            hint: 'e.g. 25',
            suffixText: 'yrs',
            keyboardType: TextInputType.number,
            error: ageError,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 32),
          _NextButton(label: 'Continue', onNext: onNext),
        ],
      ),
    );
  }
}

// ─── Steps 2 & 3 ─────────────────────────────────────────────────────────────

class _PageYesNo extends StatelessWidget {
  final String step;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool? selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onNext;

  const _PageYesNo({
    required this.step,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuestionHeader(
            icon: icon,
            iconColor: iconColor,
            step: step,
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _SelectableTile(
                  label: 'Yes',
                  icon: Icons.check,
                  isSelected: selected == true,
                  selectedColor: AppTheme.red,
                  onTap: () => onSelected(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectableTile(
                  label: 'No',
                  icon: Icons.close,
                  isSelected: selected == false,
                  selectedColor: AppTheme.green,
                  onTap: () => onSelected(false),
                ),
              ),
            ],
          ),
          const Spacer(),
          _NextButton(label: 'Continue', onNext: onNext),
        ],
      ),
    );
  }
}

// ─── Step 4 ───────────────────────────────────────────────────────────────────

class _PageLastDonation extends StatelessWidget {
  final DateTime? selectedDate;
  final bool neverDonated;
  final VoidCallback onNeverDonatedTap;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onNext;

  const _PageLastDonation({
    required this.selectedDate,
    required this.neverDonated,
    required this.onNeverDonatedTap,
    required this.onDateSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _QuestionHeader(
            icon: Icons.bloodtype_outlined,
            iconColor: AppTheme.red,
            step: 'Step 4 of 5',
            title: 'Last donation date?',
            subtitle:
                'You must wait at least 3 months (90 days) between donations.',
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onNeverDonatedTap,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: neverDonated
                        ? AppTheme.red
                        : Colors.transparent,
                    border: Border.all(
                      color:
                          neverDonated ? AppTheme.red : AppTheme.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: neverDonated
                      ? const Icon(Icons.check,
                          size: 14, color: AppTheme.white)
                      : null,
                ),
                const SizedBox(width: 10),
                const Text("I've never donated before",
                    style: TextStyle(
                        fontSize: 15, color: Color(0xFF444444))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: neverDonated ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: neverDonated
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: AppTheme.red),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) onDateSelected(picked);
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: !neverDonated && selectedDate != null
                        ? AppTheme.red
                        : AppTheme.grey.withValues(alpha: 0.4),
                    width:
                        !neverDonated && selectedDate != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: !neverDonated && selectedDate != null
                          ? AppTheme.red
                          : AppTheme.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      !neverDonated && selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Select donation date',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            !neverDonated && selectedDate != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                        color: !neverDonated && selectedDate != null
                            ? AppTheme.black
                            : AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          _NextButton(label: 'Continue', onNext: onNext),
        ],
      ),
    );
  }
}

// ─── Step 5 ───────────────────────────────────────────────────────────────────

class _PageHospital extends StatelessWidget {
  final String? selectedHospital;
  final List<String> hospitals;
  final ValueChanged<String?> onSelected;
  final VoidCallback onNext;

  const _PageHospital({
    required this.selectedHospital,
    required this.hospitals,
    required this.onSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _QuestionHeader(
            icon: Icons.local_hospital_outlined,
            iconColor: AppTheme.red,
            step: 'Step 5 of 5',
            title: 'Where will you donate?',
            subtitle:
                'Select the hospital where you plan to donate blood.',
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            value: selectedHospital,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Hospital',
              hintText: 'Choose a hospital',
              prefixIcon: const Icon(Icons.local_hospital_outlined,
                  color: AppTheme.grey),
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppTheme.grey.withValues(alpha: 0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppTheme.grey.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.red, width: 2),
              ),
            ),
            items: hospitals
                .map((h) =>
                    DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: onSelected,
          ),
          const Spacer(),
          _NextButton(label: 'Check Eligibility', onNext: onNext),
        ],
      ),
    );
  }
}

// ─── Result ───────────────────────────────────────────────────────────────────

class _PageResult extends StatelessWidget {
  final bool isEligible;
  final String reason;
  final VoidCallback onClose;

  const _PageResult({
    required this.isEligible,
    required this.reason,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isEligible
                  ? AppTheme.green.withValues(alpha: 0.12)
                  : AppTheme.red.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEligible
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              size: 56,
              color: isEligible ? AppTheme.green : AppTheme.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isEligible ? "You're Eligible!" : 'Not Eligible Right Now',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            isEligible
                ? "Great news! Based on your answers, you're eligible to donate blood. Your donation can save up to 3 lives!"
                : reason,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF444444),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEligible ? AppTheme.green : AppTheme.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                isEligible ? 'Proceed' : 'Close',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _QuestionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String step;
  final String title;
  final String subtitle;

  const _QuestionHeader({
    required this.icon,
    required this.iconColor,
    required this.step,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 16),
        Text(step,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF444444),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.black)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
                height: 1.5)),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffixText;
  final TextInputType keyboardType;
  final String? error;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
    this.suffixText,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
            errorText: error,
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppTheme.grey.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppTheme.grey.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.red, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color selectedColor;

  const _SelectableTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor = AppTheme.red,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.08)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : AppTheme.grey.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (icon != null)
              Icon(icon,
                  color: isSelected ? selectedColor : AppTheme.grey,
                  size: 28),
            if (icon != null) const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? selectedColor
                    : const Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onNext;

  const _NextButton({required this.label, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}