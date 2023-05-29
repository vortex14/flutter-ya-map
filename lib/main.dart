import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'widgets/custom_textfield.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late YandexMapController controller;
  GlobalKey mapKey = GlobalKey();

  bool _isShowingUserLocation = false;

  bool _isShowingFirst = false;
  bool _isShowingSecond = false;
  bool _isShowingThird = false;

  final List<MapObject> mapObjects = [];

  final MapObjectId mapObjectId1 = const MapObjectId('first');
  final MapObjectId mapObjectId2 = const MapObjectId('two');
  final MapObjectId mapObjectId3 = const MapObjectId('three');
  final MapObjectId mapObjectIdA = const MapObjectId('A');
  final MapObjectId mapObjectIdB = const MapObjectId('B');

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YandexMap examples')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: YandexMap(
              key: mapKey,
              mapObjects: mapObjects,
              onMapCreated: (YandexMapController yandexMapController) async {
                controller = yandexMapController;
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Отображать местоположение:'),
                  Switch(
                    value: _isShowingUserLocation,
                    onChanged: (value) async {
                      setState(() {
                        _isShowingUserLocation = value;
                      });
                      if (value) {
                        final Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                        );

                        final mapObjectA = PlacemarkMapObject(
                          mapId: mapObjectIdA,
                          point: Point(latitude: position.latitude, longitude: position.longitude),
                          opacity: 0.7,
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
                              scale: 0.5,
                            ),
                          ),
                        );

                        setState(() {
                          mapObjects.add(mapObjectA);
                        });
                      } else {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == mapObjectIdA);
                        });
                        // await controller.toggleUserLayer(visible: false);
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isShowingFirst,
                    onChanged: (value) {
                      if (value!) {
                        final mapObject = PlacemarkMapObject(
                          mapId: mapObjectId1,
                          point: const Point(latitude: 59.93296, longitude: 30.320045),
                          opacity: 0.7,
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
                              scale: 0.5,
                            ),
                          ),
                        );
                        setState(() {
                          mapObjects.add(mapObject);
                        });
                      } else {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == mapObjectId1);
                        });
                      }
                      setState(() {
                        _isShowingFirst = value;
                      });
                    },
                  ),
                  const Text('Отображать первую точку'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isShowingSecond,
                    onChanged: (value) {
                      if (value!) {
                        final mapObject = PlacemarkMapObject(
                          mapId: mapObjectId2,
                          point: const Point(latitude: 60.02202, longitude: 30.328777),
                          opacity: 0.7,
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
                              scale: 0.5,
                            ),
                          ),
                        );
                        setState(() {
                          mapObjects.add(mapObject);
                        });
                      } else {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == mapObjectId2);
                        });
                      }
                      setState(() {
                        _isShowingSecond = value;
                      });
                    },
                  ),
                  const Text('Отображать вторую точку'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isShowingThird,
                    onChanged: (value) {
                      if (value!) {
                        final mapObject = PlacemarkMapObject(
                          mapId: mapObjectId3,
                          point: const Point(latitude: 59.852168, longitude: 30.307788),
                          opacity: 0.7,
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
                              scale: 0.5,
                            ),
                          ),
                        );
                        setState(() {
                          mapObjects.add(mapObject);
                        });
                      } else {
                        setState(() {
                          mapObjects.removeWhere((el) => el.mapId == mapObjectId3);
                        });
                      }
                      setState(() {
                        _isShowingThird = value;
                      });
                    },
                  ),
                  const Text('Отображать третью точку'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextFieldWidget(
                  onSubmitted: () => _search(),
                  controller: searchController,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _search() async {
    final query = searchController.text;

    final resultWithSession = YandexSearch.searchByText(
      searchText: query,
      geometry: Geometry.fromBoundingBox(const BoundingBox(
        southWest: Point(latitude: 55.76996383933034, longitude: 37.57483142322235),
        northEast: Point(latitude: 55.785322774728414, longitude: 37.590924677311705),
      )),
      searchOptions: const SearchOptions(
        searchType: SearchType.geo,
        geometry: false,
      ),
    );

    await resultWithSession.result.then((result) async {
      setState(() {
        mapObjects.removeWhere((el) => el.mapId == mapObjectId3);
        mapObjects.removeWhere((el) => el.mapId == mapObjectId2);
        mapObjects.removeWhere((el) => el.mapId == mapObjectId1);
        _isShowingFirst = false;
        _isShowingSecond = false;
        _isShowingThird = false;
      });

      if (result.items != null && result.items!.isNotEmpty) {
        searchController.text = result.items![0].name;
        // устанавливаем точку Б
        final mapObjectB = PlacemarkMapObject(
          mapId: mapObjectIdB,
          point: result.items![0].geometry.first.point!,
          opacity: 0.7,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
              scale: 0.5,
            ),
          ),
        );
        // получаем текущию геопозицию
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        // устанавливаем точку А
        final mapObjectA = PlacemarkMapObject(
          mapId: mapObjectIdA,
          point: Point(latitude: position.latitude, longitude: position.longitude),
          opacity: 0.7,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
              scale: 0.5,
            ),
          ),
        );
        // Запрашиваем маршрут
        var resultWithSession = YandexDriving.requestRoutes(points: [
          RequestPoint(point: mapObjectA.point, requestPointType: RequestPointType.wayPoint),
          RequestPoint(point: mapObjectB.point, requestPointType: RequestPointType.wayPoint),
        ], drivingOptions: const DrivingOptions(initialAzimuth: 0, routesCount: 5, avoidTolls: true));

        final drivingResult = await resultWithSession.result;
        drivingResult.routes!.asMap().forEach((i, route) {
          mapObjects.add(PolylineMapObject(
            mapId: MapObjectId('route_${i}_polyline'),
            polyline: Polyline(points: route.geometry),
            strokeColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
            strokeWidth: 3,
          ));
        });

        setState(() {
          mapObjects.add(mapObjectA);
          mapObjects.add(mapObjectB);
        });
      }
    });
  }
}
