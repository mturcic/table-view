import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:table_view/models/comment.dart';
import 'package:table_view/storage/boxes.dart';
import 'package:table_view/utils/api/api_constants.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CommentsScreen> {
  @override
  void initState() {
    fetchComments();
    super.initState();
    _scrollController.addListener(() => {
          if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent)
            fetchMore()
        });
  }

  final ScrollController _scrollController = ScrollController();
  int start = 0;
  int limit = 20;

  void fetchMore() async {
    await Future.delayed(
      const Duration(seconds: 1),
      () => setState(() {
        start += 20;
      }),
    ).then((value) => fetchComments());
  }

  @override
  void dispose() {
    Hive.box('comments').close();
    super.dispose();
  }

  Future fetchComments() async {
    final queryParameters = {
      '_start': start.toString(),
      '_limit': limit.toString(),
    };
    final uri = Uri.https(
        apiUrl(Environment.development), '/comments', queryParameters);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Comment> comments = [];
      for (var comment in data) {
        comments.add(Comment.fromJson(comment));
        final box = Boxes.getComments();
        box.add(Comment.fromJson(comment));
      }
      return comments;
    }
    throw Exception('Failed to load comments');
  }

  void onTap(BuildContext context, Comment comment) {
    showDialog(
        context: context,
        builder: (builder) => AlertDialog(
              title: Text(comment.name!.toUpperCase()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Post/Comment id: ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${comment.postId.toString()}/${comment.id.toString()}')
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text('E-mail: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(comment.eMail!))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(comment.body!)
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Hive.box<Comment>('comments').clear();
          setState(() {
            start = 0;
          });
          await Future.delayed(const Duration(seconds: 1), fetchComments);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: ValueListenableBuilder<Box<Comment>>(
            valueListenable: Boxes.getComments().listenable(),
            builder: (context, box, _) {
              final comments = box.values.toList().cast<Comment>();
              if (comments.isNotEmpty) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('POST ID'), numeric: true),
                          DataColumn(label: Text('#'), numeric: true),
                          DataColumn(label: Text('TITLE')),
                          DataColumn(label: Text('E-MAIL')),
                          DataColumn(label: Text('CONTENT'))
                        ],
                        rows: [
                          ...List.generate(comments.length, (index) {
                            return DataRow(cells: [
                              DataCell(Text(comments[index].postId.toString()),
                                  onTap: () => onTap(context, comments[index])),
                              DataCell(Text(comments[index].id.toString()),
                                  onTap: () => onTap(context, comments[index])),
                              DataCell(Text(comments[index].name!),
                                  onTap: () => onTap(context, comments[index])),
                              DataCell(Text(comments[index].eMail!),
                                  onTap: () => onTap(context, comments[index])),
                              DataCell(Text(comments[index].body!),
                                  onTap: () => onTap(context, comments[index])),
                            ]);
                          })
                        ],
                      ),
                      if (comments.length == start + limit)
                        const SizedBox(
                            height: 100,
                            width: 100,
                            child: Center(child: CircularProgressIndicator()))
                    ],
                  ),
                );
              } else if (comments.isEmpty) {
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: Text('Fetching data'),
                  ),
                );
              }
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
