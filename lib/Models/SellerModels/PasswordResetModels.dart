// lib/Models/SellerModels/PasswordResetModels.dart

// Request Models
class SendOTPRequest {
  final String email;

  SendOTPRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class VerifyOTPRequest {
  final String email;
  final String otp;

  VerifyOTPRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
  };
}

class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

// Response Models
class PasswordResetResponse {
  final bool success;
  final String message;
  final String? email;
  final String? error;

  PasswordResetResponse({
    required this.success,
    required this.message,
    this.email,
    this.error,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      email: json['email'],
      error: json['error'],
    );
  }
}

