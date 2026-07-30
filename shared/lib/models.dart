import 'package:hive_ce/hive_ce.dart';

// This line is CRITICAL. It tells the generator where to put the adapters.
part 'models.g.dart';

@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  trainer,
  @HiveField(1)
  member,
}

@HiveType(typeId: 1)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  read,
}

@HiveType(typeId: 2)
enum CallRequestStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  declined,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 3)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final UserRole role;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String? avatarUrl;
  @HiveField(5)
  final String? assignedTrainerId;

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.assignedTrainerId,
  });
}

@HiveType(typeId: 4)
class Message extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String chatId;
  @HiveField(2)
  final String senderId;
  @HiveField(3)
  final String receiverId;
  @HiveField(4)
  final String text;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final MessageStatus status;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    required this.status,
  });
}

@HiveType(typeId: 5)
class CallRequest extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String memberId;
  @HiveField(2)
  final String trainerId;
  @HiveField(3)
  final DateTime requestedAt;
  @HiveField(4)
  final DateTime scheduledFor;
  @HiveField(5)
  final String note;
  @HiveField(6)
  final CallRequestStatus status;

  CallRequest({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.requestedAt,
    required this.scheduledFor,
    required this.note,
    required this.status,
  });
}

@HiveType(typeId: 6)
class SessionLog extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String memberId;
  @HiveField(2)
  final String trainerId;
  @HiveField(3)
  final DateTime startedAt;
  @HiveField(4)
  final DateTime endedAt;
  @HiveField(5)
  final int durationSec;
  @HiveField(6)
  final int? rating;
  @HiveField(7)
  final String? trainerNotes;
  @HiveField(8)
  final String? memberNotes;

  SessionLog({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    this.rating,
    this.trainerNotes,
    this.memberNotes,
  });
}

@HiveType(typeId: 7)
class RoomMeta extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String callRequestId;
  @HiveField(2)
  final String hmsRoomId;
  @HiveField(3)
  final String hmsRoleMember;
  @HiveField(4)
  final String hmsRoleTrainer;

  RoomMeta({
    required this.id,
    required this.callRequestId,
    required this.hmsRoomId,
    required this.hmsRoleMember,
    required this.hmsRoleTrainer,
  });
}
