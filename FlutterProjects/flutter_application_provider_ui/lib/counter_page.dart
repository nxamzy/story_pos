import 'package:flutter/material.dart';
import 'package:flutter_application_provider_ui/counter.dart';
import 'package:provider/provider.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    final counterchangeint=Provider.of<CounterProvider>(context);
   
    return LayoutBuilder(
      builder:(context, constraints){ 
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
           double buttonSize =99;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("You catch ${counterchangeint.count.toString()} times"),
          ),
       backgroundColor: counterchangeint.bgColor,
        body: Stack(
          children:[
           Center(
            child:   Text("${counterchangeint.string}",style: TextStyle(
                    color: Colors.black,
                    fontSize: 100,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),),
           ),
           Positioned(
            top: counterchangeint.top,
            left: counterchangeint.left,
             child: SizedBox(
              height: buttonSize,
              width: buttonSize,
              child: ElevatedButton(
                
                          onPressed: () {
                            counterchangeint.changePosition(maxWidth, maxHeight, buttonSize);
                          },
                          child: Center(child: Text("Catch me",style: TextStyle(color: Colors.black,fontSize: 10,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)),
                        ),
              // child: Padding(
              //   padding: const EdgeInsets.only(bottom: 90),
              //   child: Column(
              //     spacing: 100,
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       Text(counterchangeint.count.toString(),style: TextStyle(fontSize: 50),),
              //       // Row(
              //       //   mainAxisAlignment: MainAxisAlignment.center,
              //       //   crossAxisAlignment: CrossAxisAlignment.end,
              //       //   spacing: 12,
              //       //   children: [
              //       //     ElevatedButton(
              //       //       onPressed: () {
              //       //         counterchangeint.increment();
              //       //       },
              //       //       child: const Icon(Icons.arrow_left),
              //       //     ),
                    
              //       //     // ElevatedButton(
              //       //     //   onPressed: () {
              //       //     //     counterchangeint.decrement();
              //       //     //   },
              //       //     //   child: const Icon(Icons.arrow_right),
              //       //     // ),
              //       //   ],
              //       // ),
              //     ],
              //   ),
              // ),
                       ),
           ),
       ] ),
      );}
    );
  }
}