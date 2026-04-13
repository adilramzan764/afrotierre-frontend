// lib/Models/BuyerModels/BuyerPasswordResetModels.dart

class SendOTPRequest {
  final String email;

  SendOTPRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class SendOTPResponse {
  final bool success;
  final String message;
  final String? email;

  SendOTPResponse({
    required this.success,
    required this.message,
    this.email,
  });

  factory SendOTPResponse.fromJson(Map<String, dynamic> json) {
    return SendOTPResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'email': email,
    };
  }
}

class VerifyOTPRequest {
  final String email;
  final String otp;

  VerifyOTPRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

class VerifyOTPResponse {
  final bool success;
  final String message;
  final String? email;

  VerifyOTPResponse({
    required this.success,
    required this.message,
    this.email,
  });

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'email': email,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class ChangePasswordResponse {
  final bool success;
  final String message;

  ChangePasswordResponse({
    required this.success,
    required this.message,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

class ResendOTPRequest {
  final String email;

  ResendOTPRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResendOTPResponse {
  final bool success;
  final String message;

  ResendOTPResponse({
    required this.success,
    required this.message,
  });

  factory ResendOTPResponse.fromJson(Map<String, dynamic> json) {
    return ResendOTPResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}