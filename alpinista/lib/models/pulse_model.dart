import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class PulseModel {
  @HiveField(0)
  late double pulso;

  PulseModel(this.pulso);
}