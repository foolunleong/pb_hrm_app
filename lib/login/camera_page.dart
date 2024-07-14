import 'package:flutter/material.dart';
import 'package:pb_hrsystem/login/ready_page.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle skip
                    },
                    child: const Text("Skip", style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/f/f3/Flag_of_Laos.svg',
                        width: 30,
                        height: 20,
                      ),
                      const SizedBox(height: 4),
                      const Text("Lao", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/camera_image.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Camera and Photo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Many functions in our app require access to the camera or gallery...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReadyPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "4 of 8",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
