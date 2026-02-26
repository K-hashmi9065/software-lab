import 'dart:typed_data';

/// Pure domain entity — no framework dependencies.
class RegisterRequest {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String businessName;
  final String informalName;
  final String address;
  final String city;
  final String state;
  final int zipCode;

  /// Raw bytes of the registration proof file (avoids content:// URI issues on Android).
  final Uint8List registrationProofBytes;

  /// Original filename of the registration proof (e.g. "cert.pdf").
  final String registrationProofName;

  /// Map of day key → list of selected time-slot strings.
  /// Keys: 'mon','tue','wed','thu','fri','sat','sun'
  final Map<String, List<String>> businessHours;

  /// FCM / push notification token. Pass empty string if unavailable.
  final String deviceToken;

  /// Auth type: 'email' | 'facebook' | 'google' | 'apple'
  final String type;

  /// Social provider ID. For email auth, pass the user's email.
  final String socialId;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.businessName,
    required this.informalName,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.registrationProofBytes,
    required this.registrationProofName,
    required this.businessHours,
    this.deviceToken = '',
    this.type = 'email',
    this.socialId = '',
  });
}
