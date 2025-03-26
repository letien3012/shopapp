import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String cancelText;
  final String confirmText;

  const ConfirmDialog({
    Key? key,
    this.title = "Hủy thay đổi?",
    this.cancelText = "HỦY",
    this.confirmText = "HỦY THAY ĐỔI",
  }) : super(key: key);

  Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => this,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      title: Text(title),
      titleTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
      actions: [
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.2, color: Colors.grey),
                    right: BorderSide(width: 0.2, color: Colors.grey),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelText,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.2, color: Colors.grey),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
