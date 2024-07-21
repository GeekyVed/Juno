import 'package:dio/dio.dart';

class RequestAssistant {
  static Future<dynamic> recieveRequest(String url) async {
    Dio dio = Dio();
    try {
      Response response = await dio.get(url);
      return response.data;
    } on DioException catch (e) {
      throw "Dio Error Occured : $e";
    } catch (e) {
      throw "Error Occured : $e";
    }
  }
}
