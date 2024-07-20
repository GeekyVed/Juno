import 'package:dio/dio.dart';

class RequestAssistant {
  static Future<dynamic> recieveRequest(String url) async {
    Dio dio = Dio();
    try {
      Response response = await dio.get(url);
      return response.data;
    } on DioException catch (e) {
      print("Dio Error Occured : $e");
    } catch (e) {
      print("Error Occured : $e");
    }
  }
}
