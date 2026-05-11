/// Raw api-enhanced module metadata.
class ApiEnhancedModule {
  /// Creates raw api-enhanced module metadata.
  const ApiEnhancedModule({
    required this.module,
    required this.methodName,
    required this.pathTemplate,
    required this.crypto,
    required this.httpMethod,
    required this.special,
  });

  /// Upstream module file name without `.js`.
  final String module;

  /// Generated Dart convenience method name.
  final String methodName;

  /// First upstream request path template.
  final String pathTemplate;

  /// Upstream crypto option.
  final String crypto;

  /// HTTP method used by the first upstream request.
  final String httpMethod;

  /// Whether the module is implemented by a manual override.
  final bool special;
}
