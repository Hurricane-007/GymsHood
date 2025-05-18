import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';

class Mydrawer extends StatelessWidget {
  const Mydrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white
                    )
                  )
                ),
                child: Center(
                child: const Icon(Icons.fitness_center_rounded, 
                size: 90 , color: Colors.white,)
              )),

              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: Text(
                    'P L A N S', style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.checklist , color: Colors.white,),
                  onTap: () {
                    
                  },
                ),
              ),
              Divider(color: Colors.white,),
                            Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: Text(
                    'E q u i p m e n t', style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.fitness_center , color: Colors.white,),
                  onTap: () {
                    
                  },
                ),
              ),Divider(color: Colors.white,),
                            Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: Text(
                    'S L O T S', style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.schedule , color: Colors.white,),
                  onTap: () {
                    
                  },
                ),
              ),
              Divider(color: Colors.white,),

            ],
          ),
                                      Padding(
                padding: const EdgeInsets.only(left: 25 , bottom: 25),
                child: ListTile(
                  title: Text(
                    'L O G O U T', style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.logout , color: Colors.white,),
                  onTap: () {
                    context.read<AuthBloc>().add(AuthEventLogOut());
                  },
                ),
              ),
        ],
      ),
      
    );
  }
}