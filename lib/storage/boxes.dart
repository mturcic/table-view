import 'package:hive/hive.dart';
import '../models/comment.dart';

class Boxes {
  static Box<Comment> getComments() => Hive.box<Comment>('comments');
}
