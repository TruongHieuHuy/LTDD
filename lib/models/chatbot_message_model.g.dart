// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatbotMessageAdapter extends TypeAdapter<ChatbotMessage> {
  @override
  final int typeId = 6;

  @override
  ChatbotMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatbotMessage(
      id: fields[0] as String,
      senderId: fields[1] as String,
      message: fields[2] as String?,
      timestamp: fields[3] as DateTime,
      imageUri: fields[4] as String?,
      isSeen: fields[5] as bool,
      messageType: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatbotMessage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.imageUri)
      ..writeByte(5)
      ..write(obj.isSeen)
      ..writeByte(6)
      ..write(obj.messageType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatbotMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
