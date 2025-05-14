import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String,T?> Function();

Future<T?> showGenericDialog<T>({
   required BuildContext context,
   required String title,
   required String content,
   required DialogOptionBuilder optionsbuilder,

   
}){
  final options = optionsbuilder();
  return showDialog(context: context, builder: (context) {
    return AlertDialog(
      title: Text(title , style: TextStyle(color: Colors.white),),
      content: Text(content , style: TextStyle(color: Colors.white),),
      backgroundColor: Theme.of(context).colorScheme.primary,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      actions: options.keys.map((optionTitle){
        final value = options[optionTitle];
        return TextButton(onPressed: () {
          if(value != null){
            Navigator.of(context).pop(value);
          }else{
            Navigator.of(context).pop();
          }
        }, child: Text(optionTitle , style: TextStyle(color: Colors.grey,)));
      }).toList(),
    );
  },);
}