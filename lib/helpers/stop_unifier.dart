import 'package:latlong2/latlong.dart';
import '/models/stop_area.dart';
import '/commons/geo_utils.dart';
import '/models/stop.dart';

const _distance = Distance();

/// Merge a list of [Stop]s to a bundle of [StopArea]s based on a given merge distance.
/// Note: This algorithm can still lead to overlapping stop areas/circles.

Iterable<StopArea> unifyStops(Iterable<Stop> stops, double stopAreaRadius) sync* {
  // pre sort stops by latitude for faster processing later
  // use latitude because distance basically never varies and can therefore be calculated cheaply
  final unassignedStops = stops.toList()..sort(
    (Stop a, Stop b) => a.location.latitude.compareTo(b.location.latitude)
  );

  while (unassignedStops.isNotEmpty) {
    final stops = <Stop>[];
    Stop? currentStop = unassignedStops.removeLast();
    Circle perimeter = Circle(currentStop.location, stopAreaRadius);

    while (currentStop != null) {
      stops.add(currentStop);

      perimeter = _joinCircles(
        perimeter,
        Circle(currentStop.location, stopAreaRadius)
      );

      currentStop = _takeStopByCircle(unassignedStops, perimeter, stopAreaRadius);
    }

    yield StopArea(stops, perimeter.center, perimeter.radius);
  }
}


/// Finds the smallest enclosing circle for 2 given circles.

Circle _joinCircles(Circle c1, Circle c2) {
  final distance = _distance(c1.center, c2.center);

  final bearing = _distance.bearing(c1.center, c2.center);

  final offset = (c2.radius - c1.radius + distance) / 2;

  final newCenter = _distance.offset(c1.center, offset, bearing);

  final newRadius = (c1.radius + c2.radius + distance) / 2;

  return Circle(newCenter, newRadius);
}


/// Gets and removes the first [Stop] that lies within the given [Circle] and stopAreaRadius.
/// If no stop is found null will be returned.
///
/// This requires the given [Stop]s to be sorted by latitude in order to work correctly.

Stop? _takeStopByCircle(List<Stop> unassignedStops, Circle circle, double stopAreaRadius) {
  // always enlarge main circle by the merge distance
  // because the compared stops needs to be treated as circles
  // which is identical to treating them as points and enlarging the radius of the main circle
  circle = Circle(circle.center, circle.radius + stopAreaRadius);

  // iterate list in reverse to circumvent the problem of deleting elements while iterating
  for (int i = unassignedStops.length - 1; i >= 0; i--) {
    final stop = unassignedStops[i];
    final latDelta = (circle.center.latitude - stop.location.latitude).abs();
    final latDistance = metersPerLatitude * latDelta;
    if (latDistance > circle.radius) {
      // leave iteration if lat difference is greater than the merge distance
      // since the stops are sorted by lat, all values after this will differ more in its distance
      break;
    }
    if (circle.isPointInside(stop.location)) {
      // remove current stop from unassigned list
      return unassignedStops.removeAt(i);
    }
  }
}
