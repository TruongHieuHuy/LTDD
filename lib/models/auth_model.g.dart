// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthModelAdapter extends TypeAdapter<AuthModel> {
  @override
  final int typeId = 5;

  @override
  AuthModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthModel(
      email: fields[0] as String?,
      sessionToken: fields[1] as String?,
      lastLoginTime: fields[2] as DateTime?,
      rememberMe: fields[3] as bool,
      sessionExpiry: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.sessionToken)
      ..writeByte(2)
      ..write(obj.lastLoginTime)
      ..writeByte(3)
      ..write(obj.rememberMe)
      ..writeByte(4)
      ..write(obj.sessionExpiry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
