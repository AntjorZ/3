import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final service = GetIt.instance;

class JokesService {
  Future<List<String>> fetchJokes() async {
    try {
      final response = await service<Dio>().get('/dadjokes');
      final List data = response.data;
      return data.map((e) => e['joke'].toString()).toList();
    } on DioException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    }
  }
}
