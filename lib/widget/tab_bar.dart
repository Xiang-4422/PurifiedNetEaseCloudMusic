import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MyTabBar extends StatefulWidget {
  const MyTabBar({Key? key}) : super(key: key);

  @override
  State<MyTabBar> createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> {
  int index = 0;

  @override
  initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Row(
          children: [
            _buildItem(),
            _buildItem(),
            _buildItem(),
            _buildItem(),
          ],
        )),
        Image.asset('assets/images/logo.png',width: 65,height: 65,)
      ],
    );
  }

  Widget _buildItem(){
    return Expanded(child: Container(
      width: 65,
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.blue
      ),
      child: Icon(Icons.add_alarm),
    ));
  }
}
