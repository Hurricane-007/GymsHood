//login Exceptions
class UserNotFoundAuthException implements Exception{}

class WrongPasswordAuthException implements Exception{}

//Register Exceptions
class  WeakPasswordException implements Exception{}

class  EmailAlreadyInUseAuthException implements Exception{}

class  InvalidEmailAuthException implements Exception{}

// generic Exception

class GenericAuthException implements Exception{}

class UserNotLoggedInAuthException implements Exception{}

class PasswordDonotMatchedException implements Exception{}



