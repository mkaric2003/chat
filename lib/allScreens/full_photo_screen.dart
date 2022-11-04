// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_unnecessary_containers

import 'package:chat/allCostants/app_costants.dart';
import 'package:chat/main.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../allCostants/color_costants.dart';

class FullPhotoScreen extends StatelessWidget {
  final String url;

  FullPhotoScreen({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.grey[900],
        iconTheme: IconThemeData(
          color: ColorConstants.primaryColor,
        ),
        title: Text(
          AppConstants.fullPhotoTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoView(imageProvider: NetworkImage(url)),
      ),
    );
  }
}
