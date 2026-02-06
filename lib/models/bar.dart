class Bar {
  final String ean13;

  Bar(this.ean13)
    : assert(ean13.length == 13, 'El código debe tener 13 caracteres');

  @override
  String toString() => ean13;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bar && runtimeType == other.runtimeType && ean13 == other.ean13;

  @override
  int get hashCode => ean13.hashCode;

  String get codigo => ean13;
}
