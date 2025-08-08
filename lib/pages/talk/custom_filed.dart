import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class CustomFiled extends StatefulWidget {
  final IconData? iconData;
  final String? hitText;
  final TextStyle? hintStyle;
  final TextEditingController textEditingController;
  final bool? pass;
  final bool? autoFocus;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final TextInputType? textInputType;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  const CustomFiled({
    Key? key,
     this.iconData,
    this.hitText,
    this.hintStyle,
    required this.textEditingController,
    this.pass,
    this.textInputType,
    this.onSubmitted,
    this.textInputAction,
    this.padding,
    this.margin, this.autoFocus = false,
  }) : super(key: key);

  @override
  State<CustomFiled> createState() => _CustomFiledState();
}

class _CustomFiledState extends State<CustomFiled> {
  bool isPass = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isPass = widget.pass ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary.withOpacity(.6), borderRadius: BorderRadius.circular(50)),
      child: Row(
        children: [
          widget.iconData != null
              ? Icon(
                  widget.iconData,
                  size: 42,
                )
              : const SizedBox.shrink(),
          Expanded(
              child: TextField(
            obscureText: isPass,
            controller: widget.textEditingController,
            keyboardType: widget.textInputType ?? TextInputType.text,
            cursorColor: Theme.of(context).primaryColor.withOpacity(.4),
            onSubmitted: widget.onSubmitted,
            textInputAction: widget.textInputAction,
            autofocus: widget.autoFocus??false,
            decoration: InputDecoration(
              hintText: widget.hitText ?? '',
              hintStyle: const TextStyle(fontSize: 28, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: const UnderlineInputBorder(borderSide: BorderSide.none),
              isDense: true
            ),
          )),
          Visibility(
            visible: widget.pass ?? false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                child: Icon(
                  isPass ? TablerIcons.eye_off : TablerIcons.eye,
                  size: 40,
                ),
                onTap: () => setState(() {
                  isPass = !isPass;
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
