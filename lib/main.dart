
import 'package:flutter/material.dart';

import 'TextoAVoz.dart';


void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //desactivar la etiquetita modo debug      
      debugShowCheckedModeBanner: false,
      title: "TEXTO A VOZ",
      home: TextoAVoz(),      
    );
  }

}//end class