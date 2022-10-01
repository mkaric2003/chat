// ignore_for_file: unused_import, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:chat/allCostants/color_costants.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.grey,
        ),
      ),
    );
  }
}
