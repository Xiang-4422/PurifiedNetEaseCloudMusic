import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CoffeePage extends GetView<HomePageController> {
  const CoffeePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => AbsorbPointer(
        absorbing: !HomePageController.to.isDrawerClosed.value,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.w),
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
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(6.w)),
                      width: 12.w,
                      height: 12.w,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20.w)),
                    Text(
                      '桃花潭水深千尺\n不及汪伦送我情',
                      style: TextStyle(fontSize: 36.sp,height: 1.5),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20.w)),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(6.w)),
                      width: 12.w,
                      height: 12.w,
                    ),
                  ],
                ),
                Text('︶',style: TextStyle(fontSize: 36.sp,color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),).paddingOnly(top: 50.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
