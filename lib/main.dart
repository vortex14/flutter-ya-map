import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_map_example/data/models/map_data_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'utils/math_utils.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late YandexMapController controller;
  GlobalKey mapKey = GlobalKey();

  final List<MapObject> mapObjects = [];
  final List<SearchItem> suggestions = [];

  final MapObjectId mapObjectIdA = const MapObjectId('A');
  final MapObjectId mapObjectIdB = const MapObjectId('B');

  bool _isDarkMapThemeEnabled = false;
  bool _isRealTimeNavigationEnabled = false;
  bool _isRealTimeGeoEnabled = true;

  final TextEditingController searchController = TextEditingController();
  StreamSubscription<Position>? navigationStreamSubscription;
  StreamSubscription<Position>? positionStreamSubscription;
  double _minDistanceinMeters = 0;
  BicycleRoute? fastestRoute;

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

  final List<MapDataModel> mapData = [
    MapDataModel(
      id: '7sd6d7sdbsu7',
      lat: 45.034436,
      long: 38.970983,
      meta: Meta(
        title: 'title1',
        desc: 'Центральный парк - это знаменитый парк в Нью-Йорке, который простирается на площадь парка. Он предлагает огромное количество развлечений и возможностей для отдыха, такие как прогулки на лодках, велосипедные прогулки, концерты и многое другое. В парке вы можете насладиться красивыми видами и посетить множество достопримечательностей, таких как зоопарк, Бельведер-карт и многие другие.',
      ),
    ),
    MapDataModel(
      id: 'sddsnd7isnd',
      lat: 45.034718,
      long: 38.983953,
      meta: Meta(
        title: 'title2',
        desc: 'Если вы ищете ресторан с изысканной кухней, то ресторан "La Tour Argent - это идеальный выбор для вас. Мы находимся в Париже и предлагаем блюда французской кухни высокого уровня, которые готовятся из свежих и качественных продуктов. Наша команда профессиональных поваров и официантов готова помочь вам провести незабываемый вечер в нашем ресторане.',
      ),
    ),
    MapDataModel(
      id: 'sudbusybd sds',
      lat: 45.009557,
      long: 39.029032,
      meta: Meta(
        title: 'title3',
        desc:
            'Большой театр - это знаменитый театр в Москве, который предлагает широкий выбор спектаклей и концертов. Мы приглашаем вас присоединиться к нам на любой из наших представлений, чтобы насладиться высоким уровнем исполнения и уникальной атмосферой театра. Вас ждут незабываемые впечатления и эмоции, которые останутся с вами на долгое время.Большой театр - это знаменитый театр в Москве, который предлагает широкий выбор спектаклей и концертов. Мы приглашаем вас присоединиться к нам на любой из наших представлений, чтобы насладиться высоким уровнем исполнения и уникальной атмосферой театра. Вас ждут незабываемые впечатления и эмоции, которые останутся с вами на долгое время.Большой театр - это знаменитый театр в Москве, который предлагает широкий выбор спектаклей и концертов. Мы приглашаем вас присоединиться к нам на любой из наших представлений, чтобы насладиться высоким уровнем исполнения и уникальной атмосферой театра. Вас ждут незабываемые впечатления и эмоции, которые останутся с вами на долгое время.Большой театр - это знаменитый театр в Москве, который предлагает широкий выбор спектаклей и концертов. Мы приглашаем вас присоединиться к нам на любой из наших представлений, чтобы насладиться высоким уровнем исполнения и уникальной атмосферой театра. Вас ждут незабываемые впечатления и эмоции, которые останутся с вами на долгое время.Большой театр - это знаменитый театр в Москве, который предлагает широкий выбор спектаклей и концертов. Мы приглашаем вас присоединиться к нам на любой из наших представлений, чтобы насладиться высоким уровнем исполнения и уникальной атмосферой театра. Вас ждут незабываемые впечатления и эмоции, которые останутся с вами на долгое время.',
      ),
    ),
    MapDataModel(
      id: 'sdsdsdsaw',
      lat: 45.006195,
      long: 39.060288,
      meta: Meta(
        title: 'title4',
        desc: 'Музей Лувр - это знаменитый музей в Париже, который предлагает посетителям уникальную возможность познакомиться с множеством произведений искусства из разных эпох и культур. Наша команда готова помочь вам провести интересную и познавательную экскурсию по музею, чтобы вы могли узнать больше о истории искусства и насладиться красотой произведений, которые хранятся в музее.',
      ),
    ),
  ];

  bool _isShowObjectInfo = false;
  MapDataModel? _selectedObject;

  void setObjects() {
    for (var element in mapData) {
      mapObjects.add(
        PlacemarkMapObject(
          mapId: MapObjectId(element.id),
          point: Point(latitude: element.lat, longitude: element.long),
          icon: PlacemarkIcon.single(PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage('assets/star.png'))),
          onTap: (mapObject, point) => setState(() {
            _isShowObjectInfo = true;
            _selectedObject = element;
          }),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Permission.location.request();
    setObjects();
  }

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    navigationStreamSubscription?.cancel();
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                      Point point = await getPosition();
                      yandexMapController.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: point,
                            zoom: 15,
                          ),
                        ),
                        animation: const MapAnimation(),
                      );
                      final mapObjectA = PlacemarkMapObject(
                        mapId: mapObjectIdA,
                        point: point,
                        opacity: 0.7,
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
                            scale: 0.5,
                          ),
                        ),
                      );
                      if (_isRealTimeGeoEnabled) realtimeGeo();
                      setState(() {
                        if (mapObjects.any((element) => element.mapId == mapObjectA)) {
                          mapObjects[mapObjects.indexOf(mapObjects.firstWhere((element) => element.mapId == mapObjectA.mapId))] = mapObjectA;
                        } else {
                          mapObjects.add(mapObjectA);
                        }
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ChangeThemeBtnWidget(
                            backgroundColor: _isDarkMapThemeEnabled ? Colors.black.withOpacity(0.8) : Colors.white,
                            iconColor: _isDarkMapThemeEnabled ? Colors.white : Colors.black,
                            onTap: () {
                              setState(() {
                                _isDarkMapThemeEnabled = !_isDarkMapThemeEnabled;
                                if (_isDarkMapThemeEnabled) {
                                  controller.setMapStyle(jsonEncode(darkThemeMap));
                                } else {
                                  controller.setMapStyle('');
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 8.0),
                          FloatingActionButton(
                            onPressed: () {},
                            backgroundColor: Colors.white,
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Switch(
                              value: _isRealTimeNavigationEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isRealTimeNavigationEnabled = value;
                                });
                                if (_isRealTimeNavigationEnabled && fastestRoute != null) {
                                  realtimeNavigation();
                                } else {
                                  stopRealtimeNavigation();
                                }
                              },
                            ),
                          ),
                          //* realtime location
                          // const SizedBox(height: 8.0),
                          // FloatingActionButton(
                          //   onPressed: () {},
                          //   backgroundColor: Colors.white,
                          //   elevation: 4.0,
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(16.0),
                          //   ),
                          //   child: Switch(
                          //     value: _isRealTimeGeoEnabled,
                          //     onChanged: (value) {
                          //       setState(() {
                          //         _isRealTimeGeoEnabled = value;
                          //       });
                          //       if (_isRealTimeGeoEnabled) {
                          //         realtimeGeo();
                          //       } else {
                          //         stopRealtimeGeo();
                          //       }
                          //     },
                          //   ),
                          // ),
                        ],
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
                                        onTap: () async {
                                          final Point pointB = Point(latitude: suggestions[i].geometry[0].point!.latitude, longitude: suggestions[i].geometry[0].point!.longitude);
                                          await buildRoute(pointB);
                                          _clearSuggestions();
                                          if (_isRealTimeNavigationEnabled && fastestRoute != null) {
                                            realtimeNavigation();
                                          } else {}
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
                  if (_isShowObjectInfo && _selectedObject != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 300,
                              minHeight: 250,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      _selectedObject!.meta.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _isShowObjectInfo = true;
                                          _selectedObject = null;
                                        });
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Рейтинг',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    Icon(Icons.star, color: Colors.yellow),
                                    Spacer(),
                                    Text(
                                      '4.5',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          _selectedObject!.meta.desc,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    final userPoint = await getPosition();

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

  Future<void> buildRoute(Point pointB) async {
    // устанавливаем точку А
    PlacemarkMapObject mapObjectA = mapObjects.firstWhere((mapObject) => mapObject.mapId == mapObjectIdA) as PlacemarkMapObject;

    // устанавливаем точку Б
    final mapObjectB = PlacemarkMapObject(
      mapId: mapObjectIdB,
      point: pointB,
      opacity: 0.7,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/arrow.png'),
          scale: 0.5,
        ),
      ),
    );

    fastestRoute = await getFastestRoute(mapObjectA.point, mapObjectB.point);

    setState(() {
      // remove old route
      mapObjects.removeWhere((mapObject) => mapObject is PolylineMapObject);
      // add new route
      mapObjects.add(
        PolylineMapObject(
          mapId: const MapObjectId('route_polyline'),
          polyline: Polyline(points: fastestRoute!.geometry),
          strokeColor: Colors.blueAccent,
          strokeWidth: 3,
          dashLength: 10,
          dashOffset: 5,
          gapLength: 5,
        ),
      );
      // update B
      if (!mapObjects.contains(mapObjectB)) {
        mapObjects.add(mapObjectB);
      } else {
        mapObjects[mapObjects.indexOf(mapObjects.firstWhere((element) => element.mapId == mapObjectB.mapId))] = mapObjectB;
      }
    });
  }

  void realtimeNavigation() {
    navigationStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      final Point userGeo = Point(latitude: position.latitude, longitude: position.longitude);
      _minDistanceinMeters = MathUtils().findNearestPointDistance(userGeo, fastestRoute!) * 1000;
      if (_minDistanceinMeters > 500) {
        final Point pointB = Point(latitude: fastestRoute!.geometry.last.latitude, longitude: fastestRoute!.geometry.last.longitude);
        buildRoute(pointB);
        debugPrint('minDistance >= 50');
      }
    });
  }

  void stopRealtimeNavigation() {
    navigationStreamSubscription?.cancel();
    navigationStreamSubscription = null;
  }

  void realtimeGeo() {
    positionStreamSubscription = Geolocator.getPositionStream(locationSettings: AndroidSettings(intervalDuration: const Duration(milliseconds: 30))).listen((Position position) {
      //* возвращать камеру к позиции пользователя *//
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
  }

  void stopRealtimeGeo() {
    positionStreamSubscription?.cancel();
    positionStreamSubscription = null;
  }

  Future<BicycleRoute> getFastestRoute(Point pointA, Point pointB) async {
    // Запрашиваем маршрут
    var resultWithSession = YandexBicycle.requestRoutes(points: [
      RequestPoint(point: pointA, requestPointType: RequestPointType.wayPoint),
      RequestPoint(point: pointB, requestPointType: RequestPointType.wayPoint),
    ], bicycleVehicleType: BicycleVehicleType.bicycle);

    final routeResult = await resultWithSession.result;

    List<BicycleRoute>? routes = routeResult.routes;
    routes!.sort((a, b) => a.weight.time.value!.compareTo(b.weight.time.value!));
    final fastestRoute = routes.first;
    return fastestRoute;
  }

  Future<Point> getPosition() async {
    final Position position = await Geolocator.getCurrentPosition();
    final Point point = Point(latitude: position.latitude, longitude: position.longitude);
    return point;
  }
}
