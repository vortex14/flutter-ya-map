import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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

  final MapObjectId mapObjectIdA = const MapObjectId('A');
  final MapObjectId mapObjectIdB = const MapObjectId('B');

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Permission.location.request();
  }

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
      body: FutureBuilder(
        future: Permission.location.status,
        builder: (context, AsyncSnapshot<PermissionStatus> snapshot) {
          switch (snapshot.data) {
            case PermissionStatus.denied:
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Для работы приложения необходим доступ к геолокации'),
                  TextButton(
                    onPressed: () => Permission.location.request().then((value) => setState(() {})),
                    child: const Text('Запросить'),
                  ),
                ],
              ));
            default:
              return Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  YandexMap(
                    key: mapKey,
                    mapObjects: mapObjects,
                    onMapCreated: (YandexMapController yandexMapController) async {
                      controller = yandexMapController;
                      Position position = await Geolocator.getCurrentPosition();
                      yandexMapController.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: Point(latitude: position.latitude, longitude: position.longitude),
                            zoom: 15,
                          ),
                        ),
                        animation: const MapAnimation(),
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
                        if (mapObjects.isEmpty) {
                          mapObjects.add(mapObjectA);
                        } else {
                          mapObjects[mapObjects.indexOf(mapObjects.firstWhere((element) => element.mapId == mapObjectA.mapId))] = mapObjectA;
                        }
                      });
                      Geolocator.getPositionStream().listen((Position position) {
                        yandexMapController.moveCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: Point(latitude: position.latitude, longitude: position.longitude),
                              zoom: 15,
                            ),
                          ),
                          animation: const MapAnimation(),
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
                          if (mapObjects.isEmpty) {
                            mapObjects.add(mapObjectA);
                          } else {
                            mapObjects[mapObjects.indexOf(mapObjects.firstWhere((element) => element.mapId == mapObjectA.mapId))] = mapObjectA;
                          }
                        });
                      });
                    },
                  ),
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextFieldWidget(
                        onSubmitted: () => _search(),
                        controller: searchController,
                      ),
                    ),
                  ),
                ],
              );
          }
        },
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
        // Geolocator.getPositionStream().listen((Position position) async {
        // устанавливаем точку А
        final mapObjectA = mapObjects.firstWhere((mapObject) => mapObject.mapId == mapObjectIdA) as PlacemarkMapObject;
        // Запрашиваем маршрут
        var resultWithSession = YandexDriving.requestRoutes(points: [
          RequestPoint(point: mapObjectA.point, requestPointType: RequestPointType.wayPoint),
          RequestPoint(point: mapObjectB.point, requestPointType: RequestPointType.wayPoint),
        ], drivingOptions: const DrivingOptions(initialAzimuth: 0, routesCount: 5, avoidTolls: true));

        final drivingResult = await resultWithSession.result;

        // удаляем предыдущий маршрут
        mapObjects.removeWhere((mapObject) => mapObject is PolylineMapObject);
        // add new routes
        drivingResult.routes!.asMap().forEach((i, route) {
          mapObjects.add(PolylineMapObject(
            mapId: MapObjectId('route_${i}_polyline'),
            polyline: Polyline(points: route.geometry),
            strokeColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
            strokeWidth: 3,
          ));
        });

        setState(() {
          // update B
          if (!mapObjects.contains(mapObjectB)) {
            mapObjects.add(mapObjectB);
          } else {
            mapObjects[mapObjects.indexOf(mapObjects.firstWhere((element) => element.mapId == mapObjectB.mapId))] = mapObjectB;
          }
        });
        // });
      }
    });
  }
}
