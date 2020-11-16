import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_clean_and_tdd/core/error/exceptions.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  group('getLastNumberTrivia' , () {
    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
          // arrange
          String jsonData;
          final tFixtureJson = FixtureJson('trivia.json');
          jsonData = await tFixtureJson.loadJson();
          final Map<String, dynamic> jsonMap = jsonDecode(jsonData);
          final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonMap);
          when(mockSharedPreferences.getString(any))
              .thenReturn(jsonData);
          // act
          final result = await dataSource.getLastNumberTrivia();
          // assert
          verify(mockSharedPreferences.getString('CACHED_NUMBER_TRIVIA'));
          expect(result, equals(tNumberTriviaModel));
        }
    );

    test(
      'should throw a CacheException when there is not a cached value',
        () async {
          // arrange
          when(mockSharedPreferences.getString(any)).thenReturn(null);
          // act
          final call = dataSource.getLastNumberTrivia;
          // assert
          expect(() => call(), throwsA(isInstanceOf<CacheException>()));
      }
    );
  });
}