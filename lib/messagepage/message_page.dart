import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../chatpage/chatpage.dart';
import '../my profile/myprofile_controller.dart';
import '../my profile/myprofile_page.dart';
import '../styles/text_style.dart';
import 'messagepage_controller.dart';

class MessagePage extends StatelessWidget {
  final MessageController controller = Get.put(MessageController());

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('en', timeago.EnMessages());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AppBar(
            backgroundColor: Colors.black,
            // leading: Padding(
            //   padding: const EdgeInsets.only(left: 24.0),
            //   child: IconButton(
            //     icon: Icon(Icons.search, color: Colors.white),
            //     onPressed: () => Get.to(() => SearchScreen()
            //     ),
            //   ),
            // ),
            title: Center(
              child: Text('Chats', style: TextStyle(color: Colors.white)),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Get.to(() => MyProfileView());
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  // child: Obx(() {
                  //   final userController = Get.find<MyProfileController>();
                  //   // final userProfilePic =
                  //   //     userController.userProfilePic.value;
                  //   final fullName = userController.fullName.value;
                  //
                  //   // return CircleAvatar(
                  //   //   radius: 25.0,
                  //   //   backgroundColor: Colors.white,
                  //   //   backgroundImage: userProfilePic.isNotEmpty
                  //   //       ? AssetImage(userProfilePic)
                  //   //       : null,
                  //   //   child: userProfilePic.isEmpty
                  //   //       ? Text(
                  //   //     fullName.isNotEmpty
                  //   //         ? fullName[0].toUpperCase()
                  //   //         : '',
                  //   //     style: TextStyle(
                  //   //       fontSize: 20.0,
                  //   //       fontWeight: FontWeight.bold,
                  //   //       color: Colors.black,
                  //   //     ),
                  //   //   )
                  //   //       : null,
                  //   // );
                  // }),
                ),
              ),
            ],
          ),

          Positioned(
            top: 120.0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: Colors.white,
              ),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Obx(
                          () => controller.usersWithTimestamp.isEmpty
                          ? Center(
                        child: CircularProgressIndicator(),
                      )
                          : ListView.builder(
                        itemCount: controller.usersWithTimestamp.length,
                        itemBuilder: (context, index) {
                          if (index < 0 || index >= controller.usersWithTimestamp.length) {
                            return SizedBox.shrink();
                          }

                          var user = controller.usersWithTimestamp[index];
                          var lastMessageTimestamp = user.timestamp.toDate();
                          var timeDifference =
                          timeago.format(lastMessageTimestamp, locale: 'en');

                          return GestureDetector(
                            child: Card(
                              color: Colors.white,
                              child: ListTile(
                                title: Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:18.0),
                                      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Text(
                                          //     user.recipientFullName,
                                          //     style: appbar2,
                                          //   ),

                                          Text(
                                              '${user.lastMessage}',
                                              style: TextStyle(fontSize: 14.0),
                                            ),

                                        ],
                                      ),
                                    ),
                                   Spacer(),
                                   Text(
                                        timeDifference,
                                      ),

                                  ],
                                ),
                               /* subtitle: Text(
                                  timeDifference,
                                ),*/
                              ),
                            ),
                            onTap: () {
                              Get.to(() => ChatPage(
                                currentUser: controller.currentUser.value!,
                                selectedUserId: user.userId,
                              ),
                                  arguments: {'selectedUserId': user.userId, 'currentUser': controller.currentUser});
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
