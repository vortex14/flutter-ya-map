import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'widgets/change_theme_btn.dart';
import 'widgets/custom_textfield.dart';

void main() {
  runApp(const MaterialApp(home: YandexWidget()));
}

class YandexWidget extends StatefulWidget {
  const YandexWidget({Key? key}) : super(key: key);

  @override
  State<YandexWidget> createState() => _YandexWidgetState();
}

class _YandexWidgetState extends State<YandexWidget> {
  late YandexMapController controller;
  GlobalKey mapKey = GlobalKey();

  final List<MapObject> mapObjects = [];

  final MapObjectId mapObjectIdA = const MapObjectId('A');
  final MapObjectId mapObjectIdB = const MapObjectId('B');

  bool _isDarkMapTheme = false;

  final TextEditingController searchController = TextEditingController();
  final List<SearchItem> suggestions = [];

  final darkThemeMap = [
    {
      "tags": {
        "all": ["road"]
      },
      "stylers": {
        "color": "0x535353",
      }
    },
    {
      "tags": {
        "all": ["landscape"]
      },
      "stylers": {
        "color": "0x222222",
      }
    },
    {
      "tags": {
        "all": ["admin"]
      },
      "stylers": {
        "color": "0x000000",
      }
    },
    {
      "tags": {
        "all": ["water"]
      },
      "stylers": {
        "color": "0x000000",
      }
    },
    {
      "tags": {
        "all": ["structure"]
      },
      "stylers": {
        "color": "0x333333",
      }
    },
  ];

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
                        // yandexMapController.moveCamera(
                        //   CameraUpdate.newCameraPosition(
                        //     CameraPosition(
                        //       target: Point(latitude: position.latitude, longitude: position.longitude),
                        //       zoom: 15,
                        //     ),
                        //   ),
                        //   animation: const MapAnimation(),
                        // );
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChangeThemeBtnWidget(
                        backgroundColor: _isDarkMapTheme ? Colors.black.withOpacity(0.8) : Colors.white,
                        iconColor: _isDarkMapTheme ? Colors.white : Colors.black,
                        onTap: () {
                          setState(() {
                            _isDarkMapTheme = !_isDarkMapTheme;
                            if (_isDarkMapTheme) {
                              controller.setMapStyle(jsonEncode(darkThemeMap));
                            } else {
                              controller.setMapStyle('');
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (suggestions.isEmpty) const Spacer(),
                          if (suggestions.isNotEmpty)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                                child: ListView.separated(
                                  reverse: true,
                                  itemCount: suggestions.length,
                                  separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, thickness: 0.5, color: Colors.grey),
                                  itemBuilder: (context, i) {
                                    return DecoratedBox(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: ListTile(
                                        title: Text(suggestions[i].name),
                                        subtitle: Text(
                                          suggestions[i].toponymMetadata != null
                                              ? suggestions[i].toponymMetadata!.address.formattedAddress
                                              : suggestions[i].businessMetadata != null
                                                  ? suggestions[i].businessMetadata!.address.formattedAddress
                                                  : '',
                                          maxLines: 2,
                                        ),
                                        tileColor: Colors.white,
                                        onTap: () {
                                          _navigate(Point(latitude: suggestions[i].geometry[0].point!.latitude, longitude: suggestions[i].geometry[0].point!.longitude));
                                          _clearSuggestions();
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          CustomTextFieldWidget(
                            onSearchTextChanged: () => _search(),
                            onCleanTextField: () => _clearSuggestions(),
                            controller: searchController,
                          ),
                        ],
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

  void _clearSuggestions() {
    setState(() {
      suggestions.clear();
    });
  }

  void _search() async {
    final query = searchController.text;
    final userPosition = await Geolocator.getCurrentPosition();
    final userPoint = Point(latitude: userPosition.latitude, longitude: userPosition.longitude);

    final resultWithSession = YandexSearch.searchByText(
      searchText: query,
      geometry: Geometry.fromPoint(userPoint),
      searchOptions: const SearchOptions(
        geometry: false,
        resultPageSize: 15,
      ),
    );

    await resultWithSession.result.then((result) async {
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          if (searchController.value.text.isNotEmpty) suggestions.replaceRange(0, suggestions.length, result.items!);
        });
      } else {
        _clearSuggestions();
      }
    });
  }

  void _navigate(Point point) async {
    // устанавливаем точку Б
    final mapObjectB = PlacemarkMapObject(
      mapId: mapObjectIdB,
      point: point,
      opacity: 0.7,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
          scale: 0.5,
        ),
      ),
    );

    // устанавливаем точку А
    PlacemarkMapObject mapObjectA = mapObjects.firstWhere((mapObject) => mapObject.mapId == mapObjectIdA) as PlacemarkMapObject;

    // Запрашиваем маршрут
    var resultWithSession = YandexDriving.requestRoutes(points: [
      RequestPoint(point: mapObjectA.point, requestPointType: RequestPointType.wayPoint),
      RequestPoint(point: mapObjectB.point, requestPointType: RequestPointType.wayPoint),
    ], drivingOptions: const DrivingOptions(initialAzimuth: 0, routesCount: 3, avoidTolls: true));

    final drivingResult = await resultWithSession.result;

    // удаляем предыдущий маршрут
    mapObjects.removeWhere((mapObject) => mapObject is PolylineMapObject);
    // add new routes
    drivingResult.routes!.asMap().forEach((i, route) {
      mapObjects.add(PolylineMapObject(
          mapId: MapObjectId('route_${i}_polyline'), polyline: Polyline(points: route.geometry), strokeColor: Colors.primaries[Random().nextInt(Colors.primaries.length)], strokeWidth: 3, dashLength: 10, dashOffset: 5, gapLength: 5));
    });

    setState(() {
      // update B
      if (!mapObjects.contains(mapObjectB)) {
        mapObjects.add(mapObjectB);
      } else {
        mapObjects[mapObjects.indexOf(mapObjects.firstWhere((element) => element.mapId == mapObjectB.mapId))] = mapObjectB;
      }
    });

    // получаем текущию геопозицию
    Geolocator.getPositionStream().listen((Position position) async {
      // устанавливаем точку А
      mapObjectA = mapObjects.firstWhere((mapObject) => mapObject.mapId == mapObjectIdA) as PlacemarkMapObject;
    });
  }
}
