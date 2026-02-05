import 'bar.dart';

class Alimento {
  final String tipo;
  final String preparacion;
  final double cantidad;
  final Bar bar;

  Alimento({
    required this.tipo,
    required this.preparacion,
    required this.cantidad,
    required this.bar,
  });

  @override
  String toString() => "$tipo-$preparacion-$cantidad-$bar";
}
