import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/generic/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context){
  return showGenericDialog(context: context,
   title: 'Logout', content: 'Are you sure !, you want to log out?',
    optionsbuilder: () =>{
      'Cancel': false,
      'Logout': true
    }).then((value)=> value??false);

}