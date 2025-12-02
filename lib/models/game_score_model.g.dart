// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_score_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameScoreModelAdapter extends TypeAdapter<GameScoreModel> {
  @override
  final int typeId = 3;

  @override
  GameScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameScoreModel(
      id: fields[0] as String,
      playerName: fields[1] as String,
      gameType: fields[2] as String,
      score: fields[3] as int,
      attempts: fields[4] as int,
      timestamp: fields[5] as DateTime,
      difficulty: fields[6] as String,
      timeSpent: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameScoreModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playerName)
      ..writeByte(2)
      ..write(obj.gameType)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.attempts)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.timeSpent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
