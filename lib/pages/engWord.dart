import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/text.dart';

class EngWord extends StatelessWidget {
  EngWord({Key? key}) : super(key: key);

  // late TextEditingController textControler;
  List<String> wordList = MyText.split("\n");

  @override
  Widget build(BuildContext context) {
    wordList.shuffle();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(10.r),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Center(
              child: Text(
                "English words",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            // TextField(
            //   controller: textControler,
            //   decoration: InputDecoration(
            //       hintText: "Gpt API Key",
            //       border: const OutlineInputBorder(),
            //       hintStyle: const TextStyle(color: Colors.white),
            //       suffixIcon: IconButton(
            //           onPressed: () {},
            //           icon: const Icon(
            //             Icons.sunny,
            //             color: Colors.white,
            //           ))),
            //   style: const TextStyle(color: Colors.white),
            // ),
            for (var i in wordList.sublist(0, 10))
              Padding(
                padding: EdgeInsets.all(10.r),
                child: Text(
                  i,
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
              )
          ],
        ),
      ),
    );
  }
}
