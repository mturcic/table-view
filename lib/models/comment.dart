import 'package:hive/hive.dart';

part 'comment.g.dart';

@HiveType(typeId: 0)
class Comment extends HiveObject {
  @HiveField(0)
  late int postId;
  @HiveField(1)
  late int id;
  @HiveField(2)
  late String? name;
  @HiveField(3)
  late String? eMail;
  @HiveField(4)
  late String? body;

  Comment(
      {required this.postId,
      required this.id,
      this.name,
      this.eMail,
      this.body});

  factory Comment.fromJson(Map json) {
    return Comment(
        postId: json['postId'],
        id: json['id'],
        name: json['name'],
        eMail: json['email'],
        body: json['body']);
  }
}
