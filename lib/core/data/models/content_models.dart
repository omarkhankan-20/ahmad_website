import 'package:flutter/widgets.dart';

import '../../enums/offering_type.dart';

class Offering {
  const Offering({
    required this.id,
    required this.type,
    required this.title,
    required this.meta,
    required this.bullets,
    required this.ctaLabel,
    required this.icon,
    this.featured = false,
    this.badge,
    this.priceLabel,
  });

  final String id;
  final OfferingType type;
  final String title;
  final String meta;
  final List<String> bullets;
  final String ctaLabel;
  final IconData icon;
  final bool featured;
  final String? badge;

  /// Null until GET /products is live. Never hardcode a price here: Ahmad
  /// must be able to change it without a new build.
  final String? priceLabel;
}

class Module {
  const Module({
    required this.order,
    required this.title,
    required this.description,
  });

  final int order;
  final String title;
  final String description;
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class Stat {
  const Stat({required this.value, required this.label});

  final String value;
  final String label;
}

/// A screenshot of a reel we worked on. The view count is already part of the
/// image, so nothing here restates it.
class ResultShot {
  const ResultShot({required this.asset, this.label});

  final String asset;

  /// Optional line under the image - the page or the kind of work. Left null
  /// where naming a client is not wanted.
  final String? label;
}