// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 3;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      role: fields[1] as UserRole,
      name: fields[2] as String,
      email: fields[3] as String,
      avatarUrl: fields[4] as String?,
      assignedTrainerId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.avatarUrl)
      ..writeByte(5)
      ..write(obj.assignedTrainerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final typeId = 4;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      chatId: fields[1] as String,
      senderId: fields[2] as String,
      receiverId: fields[3] as String,
      text: fields[4] as String,
      createdAt: fields[5] as DateTime,
      status: fields[6] as MessageStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chatId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.receiverId)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CallRequestAdapter extends TypeAdapter<CallRequest> {
  @override
  final typeId = 5;

  @override
  CallRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallRequest(
      id: fields[0] as String,
      memberId: fields[1] as String,
      trainerId: fields[2] as String,
      requestedAt: fields[3] as DateTime,
      scheduledFor: fields[4] as DateTime,
      note: fields[5] as String,
      status: fields[6] as CallRequestStatus,
    );
  }

  @override
  void write(BinaryWriter writer, CallRequest obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.trainerId)
      ..writeByte(3)
      ..write(obj.requestedAt)
      ..writeByte(4)
      ..write(obj.scheduledFor)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionLogAdapter extends TypeAdapter<SessionLog> {
  @override
  final typeId = 6;

  @override
  SessionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionLog(
      id: fields[0] as String,
      memberId: fields[1] as String,
      trainerId: fields[2] as String,
      startedAt: fields[3] as DateTime,
      endedAt: fields[4] as DateTime,
      durationSec: (fields[5] as num).toInt(),
      rating: (fields[6] as num?)?.toInt(),
      trainerNotes: fields[7] as String?,
      memberNotes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.trainerId)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.endedAt)
      ..writeByte(5)
      ..write(obj.durationSec)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.trainerNotes)
      ..writeByte(8)
      ..write(obj.memberNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoomMetaAdapter extends TypeAdapter<RoomMeta> {
  @override
  final typeId = 7;

  @override
  RoomMeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomMeta(
      id: fields[0] as String,
      callRequestId: fields[1] as String,
      hmsRoomId: fields[2] as String,
      hmsRoleMember: fields[3] as String,
      hmsRoleTrainer: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RoomMeta obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.callRequestId)
      ..writeByte(2)
      ..write(obj.hmsRoomId)
      ..writeByte(3)
      ..write(obj.hmsRoleMember)
      ..writeByte(4)
      ..write(obj.hmsRoleTrainer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomMetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final typeId = 0;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.trainer;
      case 1:
        return UserRole.member;
      default:
        return UserRole.trainer;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.trainer:
        writer.writeByte(0);
      case UserRole.member:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final typeId = 1;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.sending;
      case 1:
        return MessageStatus.sent;
      case 2:
        return MessageStatus.read;
      default:
        return MessageStatus.sending;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    switch (obj) {
      case MessageStatus.sending:
        writer.writeByte(0);
      case MessageStatus.sent:
        writer.writeByte(1);
      case MessageStatus.read:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CallRequestStatusAdapter extends TypeAdapter<CallRequestStatus> {
  @override
  final typeId = 2;

  @override
  CallRequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CallRequestStatus.pending;
      case 1:
        return CallRequestStatus.approved;
      case 2:
        return CallRequestStatus.declined;
      case 3:
        return CallRequestStatus.cancelled;
      default:
        return CallRequestStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, CallRequestStatus obj) {
    switch (obj) {
      case CallRequestStatus.pending:
        writer.writeByte(0);
      case CallRequestStatus.approved:
        writer.writeByte(1);
      case CallRequestStatus.declined:
        writer.writeByte(2);
      case CallRequestStatus.cancelled:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallRequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
