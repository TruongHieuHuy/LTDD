// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendRequestAdapter extends TypeAdapter<FriendRequest> {
  @override
  final int typeId = 7;

  @override
  FriendRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendRequest(
      id: fields[0] as String,
      senderId: fields[1] as String,
      receiverId: fields[2] as String,
      sentAt: fields[3] as DateTime,
      status: fields[4] as String,
      respondedAt: fields[5] as DateTime?,
      message: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FriendRequest obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.receiverId)
      ..writeByte(3)
      ..write(obj.sentAt)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.respondedAt)
      ..writeByte(6)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FriendshipAdapter extends TypeAdapter<Friendship> {
  @override
  final int typeId = 8;

  @override
  Friendship read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Friendship(
      id: fields[0] as String,
      userId1: fields[1] as String,
      userId2: fields[2] as String,
      createdAt: fields[3] as DateTime,
      isBlocked: fields[4] as bool,
      blockedBy: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Friendship obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId1)
      ..writeByte(2)
      ..write(obj.userId2)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isBlocked)
      ..writeByte(5)
      ..write(obj.blockedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendshipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
