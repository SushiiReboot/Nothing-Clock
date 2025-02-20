import 'package:hive/hive.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  DateTime time;

  @HiveField(1)
  List<bool> days;

  @HiveField(2, defaultValue: false)
  bool isEnabled;

  Alarm({required this.time, required this.days, this.isEnabled = false});
}