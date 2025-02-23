import 'package:hive/hive.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  DateTime time;

  @HiveField(1)
  Map<String, bool> days;

  @HiveField(2, defaultValue: false)
  bool isEnabled;

  @HiveField(3)
  int id;

  Alarm({int? id, required this.time, required this.days, this.isEnabled = false}) : id = id ?? DateTime.now().millisecondsSinceEpoch % (1 << 31);
}