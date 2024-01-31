import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styles/text_style.dart';
import 'contactpage_controller.dart';

class ContactPage extends StatelessWidget {
  final ContactController controller = Get.put(ContactController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left:10.0, right:10.0),
            child: AppBar(
              backgroundColor: Colors.black,
              title: Padding(
                padding: const EdgeInsets.only(left:58.0),
                child: Text('Contacts', style: TextStyle(color: Colors.white)),
              ),
              leading:
                IconButton(
                  icon: Icon(Icons.search,color: Colors.white,),
                  onPressed: () {
                    showSearch(context: context, delegate: ContactSearchDelegate(controller));
                  },
                ),

            ),
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
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => controller.createNewGroup(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Row(
                        children: [
                          Icon(Icons.groups_2_outlined),
                          SizedBox(width: 28),
                          Text(
                            'New group',
                            style: appbar2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(
                          'My Contacts',
                          style: appbar2,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Obx(() {
                      return ListView(
                        children: controller.contactCards,
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactSearchDelegate extends SearchDelegate {
  final ContactController controller;

  ContactSearchDelegate(this.controller);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      // Build the results asynchronously
      child: FutureBuilder(
        future: controller.updateContactListAsync(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Obx(() {
              return ListView(
                children: controller.contactCards,
              );
            });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}