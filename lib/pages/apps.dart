import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class Apps extends StatefulWidget {
  const Apps({Key? key}) : super(key: key);

  @override
  _AppsState createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  List<AppInfo> apps = [];
  @override
  void initState() {
    InstalledApps.getInstalledApps(true, true)
        .then((value) => setState(() => apps = value));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(apps.length);
    if (apps.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: apps.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            print(apps[index].packageName!);
            InstalledApps.startApp(apps[index].packageName!);
          },
          onForcePressEnd: (_) {
            InstalledApps.openSettings(apps[index].packageName!);
          },
          child: Container(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.memory(
                    apps[index].icon!,
                    width: 50.w,
                    height: 50.h,
                  ),
                  Text(
                    apps[index].name!.length > 20
                        ? apps[index].name!.substring(0, 20)
                        : apps[index].name!,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        decoration: TextDecoration.none),
                  ),
                ],
              )),
        );
      },
    );
  }
}
