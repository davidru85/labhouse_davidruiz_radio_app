import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';
import 'package:radio_app/presentation/widgets/glass_surface.dart';

/// Slice 2b — Glassmorphic surface (DESIGN.md §Effects, ADR-0042).
///
/// Pins the glass treatment: a backdrop blur, a translucent fill, a hairline
/// `glass-stroke` border, and clipping to the rounded shape.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('blurs the backdrop clipped to its rounded shape', (
    tester,
  ) async {
    await tester.pumpWidget(host(const GlassSurface(child: Text('x'))));

    expect(find.byType(BackdropFilter), findsOneWidget);
    final clip = tester.widget<ClipRRect>(
      find
          .ancestor(
            of: find.byType(BackdropFilter),
            matching: find.byType(ClipRRect),
          )
          .first,
    );
    expect(clip.borderRadius, const BorderRadius.all(Radius.circular(24)));
  });

  testWidgets('defaults to a 20px backdrop blur on bars/cards', (tester) async {
    await tester.pumpWidget(host(const GlassSurface(child: Text('x'))));

    final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
    expect(surface.blurSigma, 20);

    final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
    expect(filter.filter, ImageFilter.blur(sigmaX: 20, sigmaY: 20));
  });

  testWidgets('the panel variant uses a denser 40px blur', (tester) async {
    await tester.pumpWidget(host(const GlassSurface.panel(child: Text('x'))));

    final surface = tester.widget<GlassSurface>(find.byType(GlassSurface));
    expect(surface.blurSigma, 40);
  });

  testWidgets('draws a translucent fill with a hairline glass stroke', (
    tester,
  ) async {
    await tester.pumpWidget(host(const GlassSurface(child: Text('x'))));

    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(BackdropFilter),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;

    expect(decoration.border!.top.color, AppColors.glassStroke);
    expect(decoration.border!.top.width, 1);
    // Translucent so the blurred backdrop shows through.
    expect(decoration.color!.a, lessThan(1.0));
  });
}
