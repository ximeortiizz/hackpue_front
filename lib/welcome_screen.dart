//import 'package:educational_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_1/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const mainGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        
        Color.fromARGB(255, 7, 67, 115),
        Colors.lightBlueAccent,
        Color.fromARGB(255, 97, 218, 234),

        
      ],
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: mainGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              /*Image.asset(
                "",
                width: 180,
              )
                  .animate()
                  .fadeIn(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 1500))
                  .slideY(begin: -0.2, curve: Curves.easeOut),*/
              const SizedBox(height: 30),
              const Text(
                'Nombre App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white,
                  fontFamily: 'Cocogoose',
                ),
              )
                  .animate()
                  .fadeIn(
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 1200))
                  .slideX(begin: -0.2),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'poner nuestro slogan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Cocogoose',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                      delay: const Duration(milliseconds: 900),
                      duration: const Duration(milliseconds: 1200))
                  .slideX(begin: -0.2),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE3005D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '¡Vamos!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cocogoose',
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                      delay: const Duration(milliseconds: 1100),
                      duration: const Duration(milliseconds: 1000))
                  .slideY(begin: 0.5),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
