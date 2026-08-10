import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';

/// One selectable option in a picker sheet.
class PickerOption {
  final String value;
  final String label;
  final String? emoji;

  const PickerOption({required this.value, required this.label, this.emoji});
}

/// Bottom sheet with emoji title, chip options and "Enregistrer" button.
/// Returns the selected value(s) or null when dismissed.
Future<List<String>?> showPickerSheet(
  BuildContext context, {
  required String emoji,
  required String title,
  required List<PickerOption> options,
  required List<String> selected,
  bool multiSelect = false,
  int visibleCount = 5,
}) {
  Haptics.tap();
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
    builder: (_) => _PickerSheet(
      emoji: emoji,
      title: title,
      options: options,
      initial: selected,
      multiSelect: multiSelect,
      visibleCount: visibleCount,
    ),
  );
}

class _PickerSheet extends StatefulWidget {
  final String emoji;
  final String title;
  final List<PickerOption> options;
  final List<String> initial;
  final bool multiSelect;
  final int visibleCount;

  const _PickerSheet({
    required this.emoji,
    required this.title,
    required this.options,
    required this.initial,
    required this.multiSelect,
    required this.visibleCount,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late final Set<String> _selected = {...widget.initial};
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = _showAll
        ? widget.options
        : widget.options.take(widget.visibleCount).toList();
    final hasMore = widget.options.length > widget.visibleCount && !_showAll;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24.w, 12.h, 24.w, 16.h + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text('${widget.emoji} ${widget.title}',
              style: AppTextStyles.modalTitle),
          SizedBox(height: 26.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              for (final option in visible)
                _OptionChip(
                  option: option,
                  selected: _selected.contains(option.value),
                  onTap: () => setState(() {
                    Haptics.select();
                    if (widget.multiSelect) {
                      _selected.contains(option.value)
                          ? _selected.remove(option.value)
                          : _selected.add(option.value);
                    } else {
                      _selected
                        ..clear()
                        ..add(option.value);
                    }
                  }),
                ),
              if (hasMore)
                GestureDetector(
                  onTap: () {
                    Haptics.tap();
                    setState(() => _showAll = true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 22.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(l10n.more,
                        style: AppTextStyles.chip.copyWith(
                            color: AppColors.primary,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          SizedBox(height: 30.h),
          PrimaryButton(
            label: l10n.save,
            onPressed: () => Navigator.pop(context, _selected.toList()),
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final PickerOption option;
  final bool selected;
  final VoidCallback onTap;

  const _OptionChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: selected
              ? null
              : Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.emoji != null) ...[
              Text(option.emoji!, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
            ],
            Text(
              option.label,
              style: AppTextStyles.chip.copyWith(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
