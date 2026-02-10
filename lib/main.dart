import 'package:flutter/material.dart';

void main() {
  runApp(const CountdownApp());
}
// test
class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root of the app
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CountdownScreen(),
    );
  }
}

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  // VARIABLES & DATA TYPES
  int seconds = 30;          // current countdown value
  int setTime = 30;          // default countdown time
  String status = "Ready";   // status message to display
  bool isRunning = false;    // timer state

  // START TIMER FUNCTION
  void startTimer() {
    // Only start if timer is not running and seconds > 0
    if (!isRunning && seconds > 0) {
      setState(() {
        isRunning = true;
        status = "Counting Down";
      });
      countdown(); // start countdown
    }
  }

  // COUNTDOWN FUNCTION
  void countdown() {
    // Delay 1 second for each decrement
    Future.delayed(const Duration(seconds: 1), () {
      // Only continue if timer is active and seconds > 0
      if (isRunning && seconds > 0) {
        setState(() {
          seconds--; // decrease seconds by 1

          // SWITCH STATEMENT to show messages at key times
          switch (seconds) {
            case 10:
              status = "10 seconds left";
              break;
            case 5:
              status = "5 seconds left";
              break;
            case 0:
              status = "Time's Up!";
              isRunning = false; // stop timer
              break;
            default:
              status = "Counting Down";
          }
        });

        // Continue countdown if timer is still running
        if (isRunning && seconds > 0) {
          countdown();
        }
      }
    });
  }

  // RESET TIMER FUNCTION
  void resetTimer() {
    setState(() {
      seconds = setTime;   // reset to selected time
      status = "Ready";    // reset status
      isRunning = false;   // stop timer
    });
  }

  // GENERATE QUICK TIMER OPTIONS USING WHILE LOOP
  List<int> getQuickTimes() {
    int i = 1;
    List<int> times = [];
    while (i <= 3) {
      times.add(i * 15); // 15, 30, 45
      i++; // increment to avoid infinite loop
    }
    return times;
  }

  // SHOW QUICK SET OPTIONS
  void showQuickSet() {
    List<int> options = getQuickTimes();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Time"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((time) {
            return ListTile(
              title: Text("$time seconds"),
              onTap: () {
                setState(() {
                  setTime = time;
                  seconds = time; // set current countdown
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // UI BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beginner Countdown Timer")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status display
          Text(
            status,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Seconds display
          Text(
            "$seconds",
            style: const TextStyle(fontSize: 48),
          ),

          const SizedBox(height: 10),

          // Slider to set countdown time
          Slider(
            value: setTime.toDouble(),
            min: 10,
            max: 60,
            divisions: 5,
            label: setTime.toString(),
            onChanged: isRunning
                ? null // disable slider while timer is running
                : (value) {
              setState(() {
                setTime = value.toInt();
                seconds = value.toInt();
              });
            },
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: startTimer, child: const Text("Start")),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: resetTimer, child: const Text("Reset")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: showQuickSet, child: const Text("Quick Set")),
            ],
          ),

          const SizedBox(height: 20),

          // Display timer state
          Text("Timer Running: $isRunning"),
        ],
      ),
    );
  }
}
