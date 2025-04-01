import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/comment/comment_bloc.dart';
import 'package:luanvan/blocs/comment/comment_event.dart';
import 'package:luanvan/blocs/comment/comment_state.dart';
import 'package:luanvan/models/comment.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';

class ReplyCommentScreen extends StatefulWidget {
  static const String routeName = '/reply-comment-screen';

  const ReplyCommentScreen({super.key});

  @override
  State<ReplyCommentScreen> createState() => _ReplyCommentScreenState();
}

class _ReplyCommentScreenState extends State<ReplyCommentScreen> {
  final TextEditingController _replyController = TextEditingController();
  Comment? comment;
  Product? product;
  UserInfoModel? user;

  @override
  void initState() {
    super.initState();
    _replyController.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {
      // This empty setState will trigger a rebuild to update the counter text
    });
  }

  @override
  void dispose() {
    _replyController.removeListener(_updateCharCount);
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    comment = args['comment'] as Comment;
    product = args['product'] as Product;
    user = args['user'] as UserInfoModel;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Phản hồi của Người bán',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Save reply logic
              final replyText = _replyController.text.trim();
              if (replyText.isNotEmpty) {
                comment!.replyContent = replyText;
                comment!.replyAt = DateTime.now();
                context.read<CommentBloc>().add(ReplyCommentEvent(comment!));
                await context
                    .read<CommentBloc>()
                    .stream
                    .firstWhere((element) => element is CommentLoaded);
                context
                    .read<CommentBloc>()
                    .add(LoadCommentsShopIdEvent(comment!.shopId!));
                Navigator.of(context).pop();
                showAlertDialog(context,
                    iconPath: IconHelper.check,
                    message: 'Phản hồi đã được gửi thành công');
              } else {
                // Show a snackbar or alert if the reply is empty
                showAlertDialog(context,
                    message: 'Vui lòng nhập nội dung phản hồi');
              }
            },
            child: const Text(
              'Gửi',
              style: TextStyle(
                color: Colors.brown,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildOriginalComment(),
                  const SizedBox(height: 16),
                  _buildShopReply(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalComment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(
                  user?.avataUrl ?? '',
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 14,
                        color: index < comment!.rating
                            ? Colors.amber[700]
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    comment?.imageProduct ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    comment?.variant ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('dd/MM/yyyy').format(comment!.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopReply() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _replyController,
            decoration: InputDecoration(
              hintText: 'Viết phản hồi...',
              counterText: '${_replyController.text.length}/300',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.brown, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLength: 300,
            maxLines: 5,
            minLines: 3,
            buildCounter: (context,
                {required currentLength, required isFocused, maxLength}) {
              return Text(
                '$currentLength/${maxLength ?? 300}',
                style: TextStyle(
                  color: currentLength >= (maxLength ?? 300)
                      ? Colors.red
                      : Colors.grey,
                  fontSize: 12,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              const Text(
                'Bạn chỉ có thể phản hồi 1 lần.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
