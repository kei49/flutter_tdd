import 'package:dartz/dartz.dart';
import 'package:flutter_clean_and_tdd/core/error/exceptions.dart';
import 'package:flutter_clean_and_tdd/core/error/failures.dart';
import 'package:flutter_clean_and_tdd/core/network/network_info.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_clean_and_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';

typedef Future<NumberTrivia> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const NumberTriviaRepositoryImpl({
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) async {
    return await _getTrivia(() {
      return remoteDataSource.getConcreteNumberTrivia(number);
    });
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() {
      return remoteDataSource.getRandomNumberTrivia();
    });
  }


  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _ConcreteOrRandomChooser getConcreteOrRandom,
    ) async {
      if (await networkInfo.isConnected) {
        try {
          final remoteTrivia = await getConcreteOrRandom();
          localDataSource.cacheNumberTrivia(remoteTrivia);
          return Right(remoteTrivia);
        } on ServerException {
          return Left(ServerFailure());
        }
      } else {
        try {
          final localTrivia = await localDataSource.getLastNumberTrivia();
          return Right(localTrivia);
        } on CacheException {
          return Left(CacheFailure());
        }
      }
  }
}