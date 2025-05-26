import 'package:gymshood/services/Auth/auth_server_provider.dart';
import 'package:gymshood/services/gymInfo/gym_server_provider.dart';

class Revenuemang {
late final dio = ServerProvider().dio;

 static final Revenuemang _instance = Revenuemang._internal();

Revenuemang._internal();

factory Revenuemang() => _instance;



}