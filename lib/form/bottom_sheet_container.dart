import 'package:flutter/material.dart';

class BottomSheetContainer extends StatelessWidget {
  const BottomSheetContainer(
      {Key? key, this.header, required this.content, this.footer})
      : super(key: key);
  final Widget? header;
  final Widget content;
  final Widget? footer;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: header,
          ),
          content,
          Container(
            child: footer,
          )
        ],
      ),
    );
  }
}
