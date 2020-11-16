import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_clean_and_tdd/core/error/exceptions.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;
  FixtureJson tFixture;
  String jsonData;
  Map<String, dynamic> jsonMap;

  setUp(() async {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
    tFixture = FixtureJson('trivia.json');
    jsonData = await tFixture.loadJson();
    jsonMap = jsonDecode(jsonData);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(jsonData, 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia' , () {
    final tNumber = 1;

    test(
      '''should perform a GET request on a URL with number
      being the endpoint and with application/json header''',
        () async {
          // arrange
          setUpMockHttpClientSuccess200();
          // act
          dataSource.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockHttpClient.get(
            'http://numberapi.com/$tNumber',
            headers: {
              'Content-Type': 'application/json',
            },
          ));
        }
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
        () async {
          // arrange
          final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonMap);
          setUpMockHttpClientSuccess200();
          // act
          final result = await dataSource.getConcreteNumberTrivia(tNumber);
          // assert
          expect(result, equals(tNumberTriviaModel));
        }
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
        () async {
          // arrange
          setUpMockHttpClientFailure404();
          // act
          final call = dataSource.getConcreteNumberTrivia;
          // assert
          expect(() => call(tNumber), throwsA(isInstanceOf<ServerException>()));
        },
    );
  });

  group('getRandomNumberTrivia' , () {

    test(
        '''should perform a GET request on a URL with number
      being the endpoint and with application/json header''',
            () async {
          // arrange
          setUpMockHttpClientSuccess200();
          // act
          dataSource.getRandomNumberTrivia();
          // assert
          verify(mockHttpClient.get(
            'http://numberapi.com/random',
            headers: {
              'Content-Type': 'application/json',
            },
          ));
        }
    );

    test(
        'should return NumberTrivia when the response code is 200 (success)',
            () async {
          // arrange
          final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonMap);
          setUpMockHttpClientSuccess200();
          // act
          final result = await dataSource.getRandomNumberTrivia();
          // assert
          expect(result, equals(tNumberTriviaModel));
        }
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
          () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = dataSource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(isInstanceOf<ServerException>()));
      },
    );
  });
}