import 'dart:convert';

class MapDataModel {
  final String id;
  final double lat;
  final double long;
  final Meta meta;
  MapDataModel({
    required this.id,
    required this.lat,
    required this.long,
    required this.meta,
  });

  MapDataModel copyWith({
    String? id,
    double? lat,
    double? long,
    Meta? meta,
  }) {
    return MapDataModel(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      meta: meta ?? this.meta,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lat': lat,
      'long': long,
      'meta': meta.toMap(),
    };
  }

  factory MapDataModel.fromMap(Map<String, dynamic> map) {
    return MapDataModel(
      id: map['id'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      long: map['long']?.toDouble() ?? 0.0,
      meta: Meta.fromMap(map['meta']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MapDataModel.fromJson(String source) => MapDataModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MapDataModel(id: $id, lat: $lat, long: $long, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MapDataModel &&
      other.id == id &&
      other.lat == lat &&
      other.long == long &&
      other.meta == meta;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      lat.hashCode ^
      long.hashCode ^
      meta.hashCode;
  }
}

class Meta {
  final String title;
  final String desc;
  Meta({
    required this.title,
    required this.desc,
  });


  Meta copyWith({
    String? title,
    String? desc,
  }) {
    return Meta(
      title: title ?? this.title,
      desc: desc ?? this.desc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'desc': desc,
    };
  }

  factory Meta.fromMap(Map<String, dynamic> map) {
    return Meta(
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Meta.fromJson(String source) => Meta.fromMap(json.decode(source));

  @override
  String toString() => 'MetaData(title: $title, desc: $desc)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Meta &&
      other.title == title &&
      other.desc == desc;
  }

  @override
  int get hashCode => title.hashCode ^ desc.hashCode;
}
