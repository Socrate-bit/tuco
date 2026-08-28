import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../curriculum/data/lesson_icons.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../cubit/path_cubit.dart';

/// One level section: divider title + winding path of lesson nodes.
/// Layout pattern repeats every 3 lessons: center → right → left (same row).
class LevelSection extends StatelessWidget {
  final String title;
  final List<Lesson> lessons;
  final PathState pathState;
  final void Function(Lesson) onLessonTap;

  const LevelSection({
    super.key,
    required this.title,
    required this.lessons,
    required this.pathState,
    required this.onLessonTap,
  });

  static double _rowHeight() => 178.h;
  static double _nodeSize() => 92.r;
  static double _headerHeight() => 84.h;

  /// Row index on the grid for lesson [i] (pairs share a row).
  static int _rowOf(int i) => (i ~/ 3) * 2 + (i % 3 == 0 ? 0 : 1);

  /// Horizontal slot: 0 = center, 1 = right, 2 = left.
  static int _slotOf(int i) => i % 3;

  /// Total height of a section holding [lessonCount] lessons.
  static double sectionHeight(int lessonCount) =>
      _headerHeight() + _bodyHeight(lessonCount);

  /// Offset of lesson [i] from the top of its section — lets the home screen
  /// scroll straight to a given node.
  static double lessonOffset(int i) =>
      _headerHeight() + _rowOf(i) * _rowHeight();

  static double _bodyHeight(int lessonCount) =>
      (lessonCount == 0 ? 0 : _rowOf(lessonCount - 1) + 1) * _rowHeight() + 20.h;

  @override
  Widget build(BuildContext context) {
    final height = _bodyHeight(lessons.length);

    return Column(
      children: [
        // "── Débutant ──" divider (fixed height: the home screen relies on
        // the section geometry to scroll to the current lesson).
        SizedBox(
          height: _headerHeight(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              children: [
                const Expanded(
                    child: Divider(color: AppColors.levelDivider, thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Text(
                    title,
                    style: AppTextStyles.pageTitle.copyWith(
                        color: AppColors.levelDivider, fontSize: 24.sp),
                  ),
                ),
                const Expanded(
                    child: Divider(color: AppColors.levelDivider, thickness: 1)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: height,
          width: 1.sw,
          child: Stack(
            children: [
              // Winding connector line behind the nodes.
              Positioned.fill(
                child: CustomPaint(
                  painter: _PathPainter(
                    count: lessons.length,
                    rowHeight: _rowHeight(),
                    nodeSize: _nodeSize(),
                    width: 1.sw,
                  ),
                ),
              ),
              for (var i = 0; i < lessons.length; i++)
                Positioned(
                  top: _rowOf(i) * _rowHeight(),
                  left: _nodeLeft(i),
                  child: _LessonNode(
                    lesson: lessons[i],
                    status: pathState.statusOf(lessons[i]),
                    onTap: () => onLessonTap(lessons[i]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  double _nodeLeft(int i) {
    final labelWidth = 170.w;
    final centerX = switch (_slotOf(i)) {
      0 => 0.5.sw,
      1 => 0.5.sw + 100.w,
      _ => 0.5.sw - 100.w,
    };
    return centerX - labelWidth / 2;
  }
}

/// A lesson circle + label. Status drives color, lock and check badge.
class _LessonNode extends StatelessWidget {
  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback onTap;

  const _LessonNode({
    required this.lesson,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = LevelSection._nodeSize();
    final color = switch (status) {
      LessonStatus.locked => AppColors.lockedNode,
      _ => Color(lesson.color),
    };
    final ringColor = switch (status) {
      LessonStatus.current => Color(lesson.color),
      _ => AppColors.pathLine,
    };

    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: SizedBox(
        width: 170.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Outer ring + colored circle with 3D bottom edge.
                Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 2.5.r),
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(color, Colors.black, 0.25)!,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      LessonIcons.of(lesson.icon),
                      color: Colors.white,
                      size: size * 0.46,
                    ),
                  ),
                ),
                // Lock / check badge bottom-right.
                if (status == LessonStatus.locked)
                  _Badge(
                    color: const Color(0xFFCFD2D6),
                    icon: Icons.lock_rounded,
                    iconColor: const Color(0xFF8A8F98),
                  ),
                if (status == LessonStatus.completed)
                  _Badge(
                    color: AppColors.green,
                    icon: Icons.check_rounded,
                    iconColor: Colors.white,
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              lesson.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.itemTitle.copyWith(
                color: status == LessonStatus.locked
                    ? AppColors.textDark
                    : AppColors.navy,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;

  const _Badge({
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -2.r,
      bottom: -2.r,
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.r),
        ),
        child: Icon(icon, color: iconColor, size: 20.r),
      ),
    );
  }
}

/// Draws the light-grey rounded connector between node centers:
/// center → (curve right) → right node → (straight) → left node →
/// (curve left) → next center …
class _PathPainter extends CustomPainter {
  final int count;
  final double rowHeight;
  final double nodeSize;
  final double width;

  _PathPainter({
    required this.count,
    required this.rowHeight,
    required this.nodeSize,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    final paint = Paint()
      ..color = AppColors.pathLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    Offset centerOf(int i) {
      final slot = i % 3;
      final row = (i ~/ 3) * 2 + (slot == 0 ? 0 : 1);
      final x = switch (slot) {
        0 => width / 2,
        1 => width / 2 + 100.w,
        _ => width / 2 - 100.w,
      };
      return Offset(x, row * rowHeight + nodeSize / 2 + 5);
    }

    final path = Path();
    final radius = 44.0;
    final rightEdge = width / 2 + 100.w + 90.w;
    final leftEdge = width / 2 - 100.w - 90.w;

    path.moveTo(centerOf(0).dx, centerOf(0).dy);
    for (var i = 1; i < count; i++) {
      final prev = centerOf(i - 1);
      final next = centerOf(i);
      final slot = i % 3;
      if (slot == 1) {
        // center → right node: out to the right edge, corner, down, into node.
        path.lineTo(rightEdge - radius, prev.dy);
        path.arcToPoint(Offset(rightEdge, prev.dy + radius),
            radius: Radius.circular(radius));
        path.lineTo(rightEdge, next.dy - radius);
        path.arcToPoint(Offset(rightEdge - radius, next.dy),
            radius: Radius.circular(radius), clockwise: true);
        path.lineTo(next.dx, next.dy);
      } else if (slot == 2) {
        // right → left node: straight horizontal line.
        path.lineTo(next.dx, next.dy);
      } else {
        // left → next center: out to the left edge, corner, down, into node.
        path.lineTo(leftEdge + radius, prev.dy);
        path.arcToPoint(Offset(leftEdge, prev.dy + radius),
            radius: Radius.circular(radius), clockwise: false);
        path.lineTo(leftEdge, next.dy - radius);
        path.arcToPoint(Offset(leftEdge + radius, next.dy),
            radius: Radius.circular(radius), clockwise: false);
        path.lineTo(next.dx, next.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.count != count || old.width != width;
}
