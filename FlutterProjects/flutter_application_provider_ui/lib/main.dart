import 'package:flutter/material.dart';
import 'package:flutter_application_provider_ui/counter.dart';
import 'package:flutter_application_provider_ui/counter_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp( MultiProvider(
     providers: [
      ChangeNotifierProvider(create: (_)=> CounterProvider())
     ],child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CounterPage(),
    );
  }
}
