import 'package:flutter/material.dart';

/// Maps curriculum icon keys to Material icons for lesson nodes.
abstract class LessonIcons {
  static const Map<String, IconData> _icons = {
    'wave': Icons.waving_hand_rounded,
    'flag': Icons.flag_rounded,
    'notebook': Icons.menu_book_rounded,
    'food': Icons.room_service_rounded,
    'numbers': Icons.pin_rounded,
    'family': Icons.family_restroom_rounded,
    'restaurant': Icons.restaurant_rounded,
    'directions': Icons.signpost_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'weather': Icons.wb_sunny_rounded,
    'routine': Icons.schedule_rounded,
    'friends': Icons.group_rounded,
    'celebration': Icons.celebration_rounded,
    'opinions': Icons.forum_rounded,
    'toys': Icons.bedroom_baby_rounded,
    'tech': Icons.devices_rounded,
    'gift': Icons.card_giftcard_rounded,
    'work': Icons.work_rounded,
    'plane': Icons.flight_rounded,
    'health': Icons.favorite_rounded,
    'nature': Icons.park_rounded,
    'future': Icons.rocket_launch_rounded,
    'memories': Icons.photo_album_rounded,
    'cooking': Icons.soup_kitchen_rounded,
    'sports': Icons.sports_soccer_rounded,
    'news': Icons.newspaper_rounded,
    'debate': Icons.record_voice_over_rounded,
    'idioms': Icons.format_quote_rounded,
    'business': Icons.business_center_rounded,
    'culture': Icons.museum_rounded,
    'chat': Icons.chat_rounded,
    'star': Icons.star_rounded,
    'book': Icons.auto_stories_rounded,
    'music': Icons.music_note_rounded,
    'city': Icons.location_city_rounded,
    'heart': Icons.volunteer_activism_rounded,
  };

  static IconData of(String key) => _icons[key] ?? Icons.school_rounded;
}
