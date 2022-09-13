import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


extension AnimationUtils on MapController {

  /// Animate the map properties location, zoom and rotation.

  animateTo({
    required TickerProvider ticker,
    LatLng? location,
    double? zoom,
    double? rotation,
    Curve curve = Curves.fastOutSlowIn,
    Duration duration = const Duration(milliseconds: 500),
    String? id,
  }) {
    location ??= center;
    zoom ??= this.zoom;
    rotation ??= this.rotation;

    final latTween = Tween<double>(begin: center.latitude, end: location.latitude);
    final lngTween = Tween<double>(begin: center.longitude, end: location.longitude);
    final zoomTween = Tween<double>(begin: this.zoom, end: zoom);
    final rotationTween = Tween<double>(begin: this.rotation, end: rotation);

    final controller = AnimationController(
      duration: duration,
      vsync: ticker
    );
    final animation = CurvedAnimation(
        parent: controller,
        curve: curve
    );

    animation.addListener(() {
      moveAndRotate(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        rotationTween.evaluate(animation),
        id: id
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }


  animateToBounds({
    required TickerProvider ticker,
    required LatLngBounds bounds,
    EdgeInsets padding = EdgeInsets.zero
  }) {
    final centerZoom = centerZoomFitBounds(
      bounds,
      options: FitBoundsOptions(
        maxZoom: 25,
        padding: padding
      )
    );

    animateTo(
      ticker: ticker,
      location: centerZoom.center,
      // round zoom level so zoom will always stick to integer levels
      // floor so the bounds are always visible
      zoom: centerZoom.zoom.floorToDouble()
    );
  }
}
