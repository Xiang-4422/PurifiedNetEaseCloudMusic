import 'package:bujuan/controllers/app_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CoffeePageView extends GetView<AppController> {
  const CoffeePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/coffee.jpg',
                    width: context.width,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(6)),
                      width: 12,
                      height: 12,
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                    const Text(
                      '桃花潭水深千尺\n不及汪伦送我情',
                      style: TextStyle(fontSize: 36,height: 1.5),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(6)),
                      width: 12,
                      height: 12,
                    ),
                  ],
                ),
                Text('︶',style: TextStyle(fontSize: 36,color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),).paddingOnly(top: 50),
              ],
            ),
          ),
        );
  }
}
