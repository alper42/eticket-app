import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A simple visual QR-code placeholder drawn with CustomPainter.
/// For a real QR code, replace with the `qr_flutter` package.
class QrWidget extends StatelessWidget {
  final String data;
  final double size;

  const QrWidget({super.key, required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _QrPainter(data),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;
  late List<List<bool>> _matrix;

  _QrPainter(this.data) {
    _matrix = _generateMatrix(data);
  }

  static const int _size = 21;

  List<List<bool>> _generateMatrix(String seed) {
    final rng = Random(seed.hashCode);
    final m = List.generate(
      _size,
      (_) => List.generate(_size, (_) => rng.nextBool()),
    );
    // Draw the three finder squares
    _drawFinder(m, 0, 0);
    _drawFinder(m, 0, _size - 7);
    _drawFinder(m, _size - 7, 0);
    return m;
  }

  static void _drawFinder(List<List<bool>> m, int r, int c) {
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        final border = i == 0 || i == 6 || j == 0 || j == 6;
        final inner  = i >= 2 && i <= 4 && j >= 2 && j <= 4;
        m[r + i][c + j] = border || inner;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell  = size.width / _size;
    final dark  = Paint()..color = const Color(0xFF0A0A0F);
    final light = Paint()..color = Colors.white;

    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        canvas.drawRect(
          Rect.fromLTWH(c * cell, r * cell, cell, cell),
          _matrix[r][c] ? dark : light,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.data != data;
}
