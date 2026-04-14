import 'package:flutter/material.dart';
import 'package:vinosfront/core/theme/app_theme.dart';
import 'package:vinosfront/core/utils/screens_dimension.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final bool isRead;

  const NotificationItem({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final s = ScreenDimensions.of(context);

    final double cardHPadding     = s.wp(4.2);
    final double cardVMargin      = s.hp(0.85);
    final double cardPadding      = s.wp(3.7);
    final double borderRadius     = s.wp(3.2);
    final double iconContainerP   = s.wp(2.7);
    final double iconBorderRadius = s.wp(2.7);
    final double iconSize         = s.wp(5.3);
    final double gapIconText      = s.wp(3.2);
    final double titleFontSize    = s.sp(14);
    final double descFontSize     = s.sp(12.5);
    final double timeFontSize     = s.sp(10.5);
    final double titleDescGap     = s.hp(0.55);

    final unreadDot = isRead
        ? const SizedBox.shrink()
        : Container(
            width: s.wp(1.8),
            height: s.wp(1.8),
            decoration: const BoxDecoration(
              color: VinotecaColors.vinoPastel,
              shape: BoxShape.circle,
            ),
          );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: cardHPadding,
        vertical: cardVMargin,
      ),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: isRead ? VinotecaColors.cremaClaro : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isRead ? Colors.transparent : VinotecaColors.doradoPastel,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: VinotecaColors.vinoOscuro.withOpacity(0.06),
            blurRadius: s.wp(1.6),
            offset: Offset(0, s.hp(0.28)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerP),
            decoration: BoxDecoration(
              color: isRead
                  ? VinotecaColors.doradoPastel.withOpacity(0.5)
                  : VinotecaColors.amarilloVainilla,
              borderRadius: BorderRadius.circular(iconBorderRadius),
            ),
            child: Icon(
              icon,
              color: isRead
                  ? VinotecaColors.vinoOscuro.withOpacity(0.6)
                  : VinotecaColors.vinoPastel,
              size: iconSize,
            ),
          ),

          SizedBox(width: gapIconText),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    color: VinotecaColors.vinoOscuro,
                    letterSpacing: 0.1,
                  ),
                ),
                SizedBox(height: titleDescGap),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: descFontSize,
                    color: const Color(0xFF5A4A50),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: s.wp(2)),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: timeFontSize,
                  color: VinotecaColors.vinoOscuro.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: s.hp(0.55)),
              unreadDot,
            ],
          ),
        ],
      ),
    );
  }
}