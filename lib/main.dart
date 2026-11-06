import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'interceptors.dart';
import 'jokes_list.dart';

// Ключ берётся на https://api-ninjas.com
const apiKey = 'ЗАГЛУШКА';

void setup() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.addAll([
    InterceptorsApp(apiKey),
    PrettyDioLogger(requestHeader: true, requestBody: true),
  ]);

  GetIt.instance.registerSingleton<Dio>(dio);
}

void main() {
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JokesScreen(),
    );
  }
}
