import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 1)
class Entry {
  Entry({
    required this.code,
    required this.value,
  });

  @HiveField(0)
  late String code;

  @HiveField(1)
  late double value;

  @override
  String toString() {
    return 'Entry(Code: $code, Value: $value)';
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'value': value,
    };
  }

  Entry.fromJson(Map<dynamic, dynamic> json) {
    code = json['code'];
    value = json['value'];
  }
}
