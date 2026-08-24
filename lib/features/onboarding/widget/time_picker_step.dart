import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

/// "When do you want to practice?" page — Levio-style picker: big live
/// HH:mm readout above two Cupertino wheels (hours / minutes).
class TimePickerStep extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String initialTime; // 'HH:mm'
  final ValueChanged<String> onChanged;

  const TimePickerStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.initialTime,
    required this.onChanged,
  });

  @override
  State<TimePickerStep> createState() => _TimePickerStepState();
}

class _TimePickerStepState extends State<TimePickerStep> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final parts = widget.initialTime.split(':');
    _time =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    _hourController = FixedExtentScrollController(initialItem: _time.hour);
    _minuteController = FixedExtentScrollController(initialItem: _time.minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String get _formatted =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  void _update(TimeOfDay time) {
    setState(() => _time = time);
    widget.onChanged(_formatted);
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required ValueChanged<int> onSelected,
  }) =>
      Expanded(
        child: CupertinoPicker(
          scrollController: controller,
          itemExtent: 40.h,
          onSelectedItemChanged: onSelected,
          children: [
            for (var i = 0; i < count; i++)
              Center(
                child: Text(i.toString().padLeft(2, '0'),
                    style: AppTextStyles.body.copyWith(fontSize: 22.sp)),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppTextStyles.pageTitle),
          if (widget.subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(widget.subtitle!, style: AppTextStyles.bodyGrey),
          ],
          const Spacer(),
          Center(
            child: Text(
              _formatted,
              style: AppTextStyles.sectionTitle
                  .copyWith(fontSize: 64.sp, color: AppColors.titleDark),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: Row(
              children: [
                _wheel(
                  controller: _hourController,
                  count: 24,
                  onSelected: (i) =>
                      _update(TimeOfDay(hour: i, minute: _time.minute)),
                ),
                _wheel(
                  controller: _minuteController,
                  count: 60,
                  onSelected: (i) =>
                      _update(TimeOfDay(hour: _time.hour, minute: i)),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
