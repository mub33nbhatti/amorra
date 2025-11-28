/// Form Validators
/// Contains validation functions for form inputs
class Validators {
  /// Email validation with advanced checks
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final trimmedValue = value.trim();
    
    // Check for spaces
    if (value.contains(' ')) {
      return 'Email cannot contain spaces';
    }
    
    // Check for @ symbol
    if (!trimmedValue.contains('@')) {
      return 'Email must contain @ symbol';
    }
    
    // Check for multiple @ symbols
    if (trimmedValue.split('@').length - 1 > 1) {
      return 'Email can only contain one @ symbol';
    }
    
    // Split email into local and domain parts
    final parts = trimmedValue.split('@');
    if (parts.length != 2) {
      return 'Please enter a valid email address';
    }
    
    final localPart = parts[0];
    final domainPart = parts[1];
    
    // Validate local part
    if (localPart.isEmpty) {
      return 'Email must have a name before @';
    }
    
    if (localPart.length > 64) {
      return 'Email name is too long (max 64 characters)';
    }
    
    // Validate domain part
    if (domainPart.isEmpty) {
      return 'Email must have a domain after @';
    }
    
    if (!domainPart.contains('.')) {
      return 'Email domain must contain a dot (.)';
    }
    
    // Check for consecutive dots
    if (domainPart.contains('..')) {
      return 'Email domain cannot contain consecutive dots';
    }
    
    // Advanced email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9](?:[a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9](?:[a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address (e.g., name@example.com)';
    }
    
    // Check for invalid characters
    final invalidCharsRegex = RegExp(r'[<>()[\]\\,;:"\s]');
    if (invalidCharsRegex.hasMatch(trimmedValue)) {
      return 'Email contains invalid characters';
    }
    
    return null;
  }

  /// Password validation with advanced checks
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    // Minimum length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    // Maximum length
    if (value.length > 128) {
      return 'Password is too long (max 128 characters)';
    }
    
    // Check for spaces
    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }
    
    // Check for common weak passwords
    final weakPasswords = ['password', '123456', '12345678', 'qwerty', 'abc123', 'password123'];
    if (weakPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a stronger one';
    }
    
    // Check if password is all the same character
    if (value.split('').every((char) => char == value[0])) {
      return 'Password cannot be all the same character';
    }
    
    // Check if password is all numbers
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return 'Password should contain letters, not just numbers';
    }
    
    // Check if password is all letters
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'For better security, add numbers or special characters';
    }
    
    return null;
  }

  /// Name validation with advanced checks
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    final trimmedValue = value.trim();
    
    // Minimum length
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    // Maximum length
    if (trimmedValue.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    // Check for only spaces
    if (trimmedValue.isEmpty) {
      return 'Name cannot be only spaces';
    }
    
    // Check for numbers only
    if (RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return 'Name cannot be only numbers';
    }
    
    // Check for special characters (allow only common ones like hyphen, apostrophe)
    final invalidCharsRegex = RegExp(r'[!@#$%^&*()+=\[\]{}|;:"<>?/\\]');
    if (invalidCharsRegex.hasMatch(trimmedValue)) {
      return 'Name contains invalid characters. Only letters, spaces, hyphens, and apostrophes are allowed';
    }
    
    // Check for consecutive spaces
    if (trimmedValue.contains('  ')) {
      return 'Name cannot contain consecutive spaces';
    }
    
    // Check if name starts or ends with space
    if (value != trimmedValue) {
      return 'Name cannot start or end with spaces';
    }
    
    return null;
  }

  /// Age validation with advanced checks
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final trimmedValue = value.trim();
    
    // Check for non-numeric characters
    if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return 'Age must be a number';
    }
    
    final age = int.tryParse(trimmedValue);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    // Check minimum age
    if (age < 1) {
      return 'Age must be at least 1';
    }
    
    if (age < 18) {
      return 'You must be 18 years or older to use this app';
    }
    
    // Check maximum age (reasonable limit)
    if (age > 120) {
      return 'Please enter a valid age (maximum 120)';
    }
    
    return null;
  }

  /// Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    if (value.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    if (value.length > 1000) {
      return 'Message must be less than 1000 characters';
    }
    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }
}

