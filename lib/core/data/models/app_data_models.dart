class AppPaymentMethod {
  const AppPaymentMethod({
    required this.code,
    required this.name,
    required this.fields,
  });

  final String code;
  final String name;

  /// Shape differs per provider, so it stays a map rather than fixed columns.
  final Map<String, String> fields;

  /// What the buyer copies and transfers to. Never reformatted anywhere in
  /// the UI: what they copy has to match the account exactly.
  String get accountCode => fields['account_code'] ?? '';

  String get qrCodeUrl => fields['account_qr_code'] ?? '';

  bool get hasQr => qrCodeUrl.isNotEmpty;

  factory AppPaymentMethod.fromJson(Map<String, dynamic> json) {
    final raw = json['fields'];
    return AppPaymentMethod(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fields: raw is Map
          ? raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'fields': fields,
  };
}

class AboutUs {
  const AboutUs({
    this.phoneNumber = '',
    this.whatsapp = '',
    this.email = '',
    this.address = '',
    this.description = '',
    this.socialLinks = const {},
  });

  final String phoneNumber;
  final String whatsapp;
  final String email;
  final String address;
  final String description;

  /// Nulls are dropped on parse, so the footer can render whatever is left
  /// without checking each platform.
  final Map<String, String> socialLinks;

  factory AboutUs.fromJson(Map<String, dynamic> json) {
    final links = json['social_links'];
    return AboutUs(
      phoneNumber: json['phone_number']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      socialLinks: links is Map
          ? Map.fromEntries(
              links.entries
                  .where(
                    (e) =>
                        e.value != null && e.value.toString().trim().isNotEmpty,
                  )
                  .map((e) => MapEntry(e.key.toString(), e.value.toString())),
            )
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'whatsapp': whatsapp,
    'email': email,
    'address': address,
    'description': description,
    'social_links': socialLinks,
  };
}

class LegalClause {
  const LegalClause({
    required this.title,
    required this.description,
    this.updatedAt = '',
  });

  final String title;
  final String description;
  final String updatedAt;

  factory LegalClause.fromJson(Map<String, dynamic> json) => LegalClause(
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'updated_at': updatedAt,
  };

  /// Clauses arrive keyed by uuid, not as a list. Dart preserves insertion
  /// order, so the server's ordering is kept.
  static List<LegalClause> listFrom(dynamic data) {
    if (data is! Map) return const [];
    return data.values
        .whereType<Map>()
        .map((e) => LegalClause.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class ConsultationSettings {
  const ConsultationSettings({this.price = '', this.timezone = ''});

  final String price;

  /// Matters when a session time is shown: the backend schedules in this zone.
  final String timezone;

  factory ConsultationSettings.fromJson(Map<String, dynamic> json) =>
      ConsultationSettings(
        price: json['price']?.toString() ?? '',
        timezone: json['timezone']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'price': price, 'timezone': timezone};
}

/// Free key/value pairs Ahmad manages from the dashboard. Kept as a raw map
/// so adding a setting there needs no code change here.
class GeneralSettings {
  const GeneralSettings(this.values);

  final Map<String, String> values;

  String? get telegramGroupUrl {
    final url = values['telegram_group_url'];
    return (url == null || url.trim().isEmpty) ? null : url.trim();
  }

 

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      GeneralSettings(json.map((k, v) => MapEntry(k, v?.toString() ?? '')));

  Map<String, dynamic> toJson() => values;
}
