import 'dart:math';

import 'package:yandex_mapkit/yandex_mapkit.dart';

class MathUtils {
  double findNearestPointDistance(Point p, BicycleRoute route) {
    var minDistance = double.infinity;
    for (var i = 0; i < route.geometry.length - 1; i++) {
      var a = route.geometry[i];
      var b = route.geometry[i + 1];
      var distanceToSegment = minDistanceToSegment( p, a, b);
      if (distanceToSegment < minDistance) {
        minDistance = distanceToSegment;
      }
    }
    return minDistance;
  }

  double degToRad(double deg) {
    return deg * (pi / 180);
  }

  double haversineDistance(Point p1, Point p2) {
    const earthRadius = 6371; // радиус Земли в километрах
    double dLat = degToRad(p2.latitude - p1.latitude);
    double dLon = degToRad(p2.longitude - p1.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) + cos(degToRad(p1.latitude)) * cos(degToRad(p2.latitude)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double minDistanceToSegment(Point p, Point a, Point b) {
    double lengthAB = haversineDistance(a, b);
    if (lengthAB == 0) {
      return haversineDistance(p, a);
    }

    double t = ((p.latitude - a.latitude) * (b.latitude - a.latitude) + (p.longitude - a.longitude) * (b.longitude - a.longitude)) / pow(lengthAB, 2);

    if (t <= 0) {
      return haversineDistance(p, a);
    }
    if (t >= 1) {
      return haversineDistance(p, b);
    }

    Point projection = Point(
      latitude: a.latitude + t * (b.latitude - a.latitude),
      longitude: a.longitude + t * (b.longitude - a.longitude),
    );

    return haversineDistance(p, projection);
  }
}
