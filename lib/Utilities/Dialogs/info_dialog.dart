import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/generic/generic_dialog.dart';

Future<void> showInfoDialog(BuildContext context,String text){
  return showGenericDialog(context: context, 
  title: 'Hello! from the Gymshood', 
  content: text,
   optionsbuilder: () => {
     'ok': null
   }, );
}