// ignore_for_file: unused_import

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flixstar/core/utils/constants.dart';
import 'package:flixstar/injection_container.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:html/parser.dart';

class API {
  final TMDB _tmdb = TMDB(
      ApiKeys(
        '215542e83456ec4a845de3e52c518405',
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMTU1NDJlODM0NTZlYzRhODQ1ZGUzZTUyYzUxODQwNSIsInN1YiI6IjY2NDdhMWRiYWJlNzU2M2IxNTkyMTJlMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.TKEx70NdqugVE2Uz5FhSr9zgZte6C4dnVfahY5kNu3Q',
      ),
      // interceptors: Interceptors()..add(PrettyDioLogger()),
      defaultLanguage: 'en-US');
  TMDB get tmdb => _tmdb;

  Future<String> getMovieSource(int id) async {
    final dio = sl<Dio>();

    try {
      String movieUrl = 'https://vidsrc.to/embed/movie/$id';
      log('Getting Movie Source from url $movieUrl');
      final response = await dio.get(movieUrl);
      final html = parse(response.data);
      final noAdScript = html.outerHtml.replaceAll(adScript, '');
      return noAdScript;
    } catch (e) {
      print('Error Occurs While Fetching VidSrc Data');
      print(e.toString());
      rethrow;
    }
  }

  Future<String> getTvSource(int id) async {
    final dio = sl<Dio>();
    try {
      String tvUrl = '$vidSrcBaseUrl/embed/tv/$id';
      final response = await dio.get(tvUrl);
      final html = parse(response.data);
      final noAdScript = html.outerHtml.replaceAll(adScript, '');
      return noAdScript;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

const String adScript = '''<script>
(function () {
  var numb = parseInt(Storage.get('adi'));
  numb = isNaN(numb) ? 0 : numb;
  var success = Storage.set('adi', numb + 1);
  if (!success) numb = Math.floor(Math.random() * 100);

  if (numb % 2) {
    document.write("<script type='text/javascript' src='lm1/com/precedelaxative/6e/93/66/6e936646bd24f8b9bd12af76368155da.js'><\\/script>");
  } else {
    document.write("<script type='text/javascript' src='lm1/com/precedelaxative/88/1d/c4/881dc4c310ba96ddca859431babfc89b.js'><\\/script>");
  }
}());
</script>''';
