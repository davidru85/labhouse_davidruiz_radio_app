import 'package:flutter/material.dart';
import 'package:radio_app/presentation/widgets/glass_surface.dart';

/// A Material [AppBar] with the brand's translucent glass treatment.
///
/// The bar itself is transparent and its [AppBar.flexibleSpace] is a square
/// [GlassSurface], so the content scrolling beneath it is blurred through the
/// hairline-bordered translucent surface (DESIGN.md §Stations/§Favorites). Used
/// on the Material branch of the tab screens; iOS uses the natively translucent
/// `CupertinoNavigationBar`.
PreferredSizeWidget glassAppBar({required Widget title}) {
  return AppBar(
    title: title,
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    flexibleSpace: const GlassSurface(
      borderRadius: BorderRadius.zero,
      child: SizedBox.expand(),
    ),
  );
}
