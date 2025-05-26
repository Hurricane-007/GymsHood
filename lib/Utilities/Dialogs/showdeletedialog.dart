

import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/generic/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog(
    context: context, 
    title: "Delete", content: "Do you want to delete this!!", 
    optionsbuilder: () => {
      'cancel': false,
      'delete':true
    }).then((value)=>value??false);
}