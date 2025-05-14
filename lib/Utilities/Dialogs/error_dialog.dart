import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/generic/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
){
  return showGenericDialog(context: context, 
  title: "Error", 
  content: text, optionsbuilder: () => {
    'ok' : null,
  });
}