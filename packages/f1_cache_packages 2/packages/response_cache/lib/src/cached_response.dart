import 'dart:convert';

import 'package:equatable/equatable.dart';

/// {@template cached_response}
/// A response as it is stored: the body, when it was fetched and the format
/// it was written in. Stored as one JSON string.
/// {@endtemplate}
class CachedResponse extends Equatable {
  /// {@macro cached_response}
  const CachedResponse({
    required this.body,
    required this.fetchedAt,
    required this.formatVersion,
  });

  /// Decodes [source], or returns `null` if it is not a valid stored
  /// response.
  static CachedResponse? tryDecode(String source) {
    try {
      final json = jsonDecode(source);
      if (json is! Map<String, dynamic>) return null;
      final formatVersion = json['formatVersion'];
      final fetchedAt = json['fetchedAt'];
      final body = json['body'];
      if (formatVersion is! int || fetchedAt is! int) return null;
      if (body is! Map<String, dynamic>) return null;
      return CachedResponse(
        body: body,
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(fetchedAt, isUtc: true),
        formatVersion: formatVersion,
      );
    } on FormatException {
      return null;
    }
  }

  /// The decoded response body.
  final Map<String, dynamic> body;

  /// When the body was fetched, in UTC.
  final DateTime fetchedAt;

  /// Version of the format this was written in. A reader that expects another
  /// version should treat it as absent.
  final int formatVersion;

  /// Encodes this as the string to store.
  String encode() => jsonEncode(<String, dynamic>{
        'formatVersion': formatVersion,
        'fetchedAt': fetchedAt.toUtc().millisecondsSinceEpoch,
        'body': body,
      });

  @override
  List<Object> get props => [body, fetchedAt, formatVersion];
}
