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
      colors: [ Color.fromRGBO(13, 71, 161, 1),
        Colors.lightBlue,
        Color.fromRGBO(102, 187, 106, 1),

        
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
              Image.asset(
                "lib/assets/logo1.png",
                width: 300,
              )
                  .animate()
                  .fadeIn(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 1500))
                  .slideY(begin: -0.2, curve: Curves.easeOut),
              const SizedBox(height: 10),
              const Text(
                'CyberGuardian',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white,
                  fontFamily: 'AGRESSIVE',
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
                  'La mejor contraseña es la educación.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: '',
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
                  foregroundColor: Colors.green,
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
