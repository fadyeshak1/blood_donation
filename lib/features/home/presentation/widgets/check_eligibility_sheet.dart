import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/home/data/models/eligibility_result.dart';
import 'package:flutter/material.dart';

class CheckEligibilitySheet extends StatefulWidget {
  final ValueChanged<bool>? onResult;

  /// Fired before the sheet closes when the user IS eligible.
  /// Receives [EligibilityResult] with all data needed for POST /api/donations.
  final ValueChanged<EligibilityResult>? onEligible;

  const CheckEligibilitySheet({
    super.key,
    this.onResult,
    this.onEligible,
  });

  static Future<bool?> show(
    BuildContext context, {
    ValueChanged<bool>? onResult,
    ValueChanged<EligibilityResult>? onEligible,
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

  // Step 1
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  String? _weightError;
  String? _ageError;

  // Step 2 & 3
  bool? _hasTattoo;
  bool? _hasChronicDisease;

  // Step 4
  DateTime? _lastDonationDate;
  bool _neverDonated = true;

  // Step 5 — hospital
  List<_HospitalItem> _hospitals = [];
  _HospitalItem? _selectedHospital;
  bool _loadingHospitals = true;

  // Result
  bool _isEligible = false;
  String _ineligibleReason = '';

  static const int _resultPageIndex = 5;
  static const int _totalSteps = 5;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      final response =
          await const ApiClient().get(ApiEndpoints.hospitalsDropdown);
      if (response.statusCode == 200) {
        final list = ApiClient.decode(response) as List;
        if (mounted) {
          setState(() {
            _hospitals = list
                .map((j) => _HospitalItem(
                      id: (j['id'] as num).toInt(),
                      name: j['name'] as String? ?? '',
                    ))
                .toList();
            _loadingHospitals = false;
          });
        }
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingHospitals = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _goNext() {
    switch (_currentPage) {
      case 0:
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
                      ? 'Must be 60 years old or younger'
                      : null;
        });
        if (_weightError != null || _ageError != null) return;

      case 1:
        if (_hasTattoo == null) {
          _snack('Please answer the tattoo question');
          return;
        }
        if (_hasTattoo == true) {
          _showIneligible(
            'You have a recent tattoo.\n\n'
            'Please wait at least 6 months after getting a tattoo before donating.',
          );
          return;
        }

      case 2:
        if (_hasChronicDisease == null) {
          _snack('Please answer the chronic diseases question');
          return;
        }
        if (_hasChronicDisease == true) {
          _showIneligible(
            'You have a chronic disease.\n\n'
            'Conditions such as diabetes, heart disease, hepatitis, HIV, or cancer '
            'may affect your eligibility. Please consult your doctor first.',
          );
          return;
        }

      case 3:
        if (!_neverDonated && _lastDonationDate == null) {
          _snack('Please select your last donation date');
          return;
        }
        if (!_neverDonated && _lastDonationDate != null) {
          final days =
              DateTime.now().difference(_lastDonationDate!).inDays;
          if (days < 90) {
            _showIneligible(
              'You donated $days day${days == 1 ? '' : 's'} ago.\n\n'
              'You must wait at least 90 days (3 months) between donations. '
              '${90 - days} day${(90 - days) == 1 ? '' : 's'} remaining.',
            );
            return;
          }
        }

      case 4:
        if (_selectedHospital == null) {
          _snack('Please select a hospital');
          return;
        }
        _showEligible();
        return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _showIneligible(String reason) {
    setState(() {
      _isEligible = false;
      _ineligibleReason = reason;
      _currentPage = _resultPageIndex;
    });
    _pageController.jumpToPage(_resultPageIndex);
  }

  void _showEligible() {
    setState(() {
      _isEligible = true;
      _currentPage = _resultPageIndex;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onResultClose() {
    if (_isEligible && _selectedHospital != null) {
      final result = EligibilityResult(
        age: int.parse(_ageController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        hasTattoo: _hasTattoo ?? false,
        lastDonationDate: _neverDonated ? null : _lastDonationDate,
        medicalCondition: _hasChronicDisease ?? false,
        hospitalId: _selectedHospital!.id,
        hospitalName: _selectedHospital!.name,
      );
      widget.onEligible?.call(result);
    }
    Navigator.of(context).pop(_isEligible);
    widget.onResult?.call(_isEligible);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.grey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          if (_currentPage < _resultPageIndex)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / _totalSteps,
                  backgroundColor: AppTheme.grey.withValues(alpha: 0.3),
                  color: AppTheme.red,
                  minHeight: 6,
                ),
              ),
            ),
          const SizedBox(height: 8),

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
                  icon: Icons.draw_outlined,
                  iconColor: AppTheme.purple,
                  title: 'Do you have a tattoo?',
                  subtitle:
                      'Getting a tattoo in the last 6 months may affect your eligibility.',
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
                  hospitals: _hospitals,
                  selectedHospital: _selectedHospital,
                  isLoading: _loadingHospitals,
                  onSelected: (h) =>
                      setState(() => _selectedHospital = h),
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
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────

class _HospitalItem {
  final int id;
  final String name;
  const _HospitalItem({required this.id, required this.name});
}

// ── Step 1 ─────────────────────────────────────────────────────────────────

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

// ── Steps 2 & 3 ────────────────────────────────────────────────────────────

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

// ── Step 4 ─────────────────────────────────────────────────────────────────

class _PageLastDonation extends StatefulWidget {
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
  State<_PageLastDonation> createState() => _PageLastDonationState();
}

class _PageLastDonationState extends State<_PageLastDonation> {
  bool _isPickingDate = false;

  Future<void> _pickDate() async {
    if (_isPickingDate) return;
    setState(() => _isPickingDate = true);
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ??
          DateTime.now().subtract(const Duration(days: 90)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.red),
        ),
        child: child!,
      ),
    );
    if (mounted) {
      setState(() => _isPickingDate = false);
      if (picked != null) widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = !widget.neverDonated && widget.selectedDate != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _QuestionHeader(
            icon: Icons.calendar_month_outlined,
            iconColor: AppTheme.green,
            step: 'Step 4 of 5',
            title: 'When did you last donate?',
            subtitle:
                'You must wait at least 3 months (90 days) between donations.',
          ),
          const SizedBox(height: 32),
          _SelectableTile(
            label: "I've never donated before",
            isSelected: widget.neverDonated,
            onTap: widget.onNeverDonatedTap,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasDate
                    ? AppTheme.red.withValues(alpha: 0.06)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasDate
                      ? AppTheme.red
                      : AppTheme.grey.withValues(alpha: 0.4),
                  width: hasDate ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: hasDate ? AppTheme.red : AppTheme.grey,
                      size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasDate
                          ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                          : 'Select my last donation date',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: hasDate
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color:
                            hasDate ? AppTheme.black : AppTheme.grey,
                      ),
                    ),
                  ),
                  if (_isPickingDate)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.red),
                    ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _NextButton(label: 'Continue', onNext: widget.onNext),
        ],
      ),
    );
  }
}

// ── Step 5 ─────────────────────────────────────────────────────────────────

class _PageHospital extends StatelessWidget {
  final List<_HospitalItem> hospitals;
  final _HospitalItem? selectedHospital;
  final bool isLoading;
  final ValueChanged<_HospitalItem?> onSelected;
  final VoidCallback onNext;

  const _PageHospital({
    required this.hospitals,
    required this.selectedHospital,
    required this.isLoading,
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
            subtitle: 'Select the hospital where you plan to donate.',
          ),
          const SizedBox(height: 32),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.red),
            )
          else
            DropdownButtonFormField<_HospitalItem>(
              value: selectedHospital,
              isExpanded: true,
              onChanged: onSelected,
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
                  .map((h) => DropdownMenuItem(
                      value: h, child: Text(h.name)))
                  .toList(),
            ),
          const Spacer(),
          _NextButton(label: 'Check Eligibility', onNext: onNext),
        ],
      ),
    );
  }
}

// ── Result ─────────────────────────────────────────────────────────────────

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
                ? "Great news! Your donation can save up to 3 lives!"
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

// ── Shared Widgets ─────────────────────────────────────────────────────────

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
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: isSelected ? selectedColor : AppTheme.grey,
                  size: 22),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
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