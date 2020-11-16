import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class NumberTrivia extends Equatable {
  final String text;
  final int number;

  const NumberTrivia({
    this.text,
    this.number
  });

  @override
  // TODO: implement props
  List<Object> get props => [text, number];
}