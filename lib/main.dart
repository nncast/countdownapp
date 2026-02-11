import 'package:flutter/material.dart';

void main() {
  runApp(const CountdownApp());
}

class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CountdownScreen(),
    );
  }
}

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  // CONSTANTS
  static const double minTime = 10.0;
  static const double maxTime = 60.0;
  static const int defaultTime = 30;

  // VARIABLES
  late int seconds;
  late int setTime;
  late String status;
  late bool isRunning;

  // PRE-CALCULATED QUICK TIMES
  static const List<int> quickTimes = [15, 30, 45];

  // STATUS MESSAGES
  static const String statusReady = "Ready";
  static const String statusCounting = "Counting Down";
  static const String statusTimesUp = "Time's Up!";

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    seconds = defaultTime;
    setTime = defaultTime;
    status = statusReady;
    isRunning = false;
  }

  void startTimer() {
    if (!isRunning && seconds > 0) {
      setState(() {
        isRunning = true;
        status = statusCounting;
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !isRunning || seconds <= 0) return;

      setState(() {
        seconds--;
        _updateStatus();
      });

      if (isRunning && seconds > 0) {
        _startCountdown();
      }
    });
  }

  void _updateStatus() {
    status = switch (seconds) {
      10 => "10 seconds left",
      5 => "5 seconds left",
      0 => statusTimesUp,
      _ => statusCounting,
    };

    if (seconds == 0) {
      isRunning = false;
    }
  }

  void resetTimer() {
    setState(() {
      seconds = setTime;
      status = statusReady;
      isRunning = false;
    });
  }

  void showQuickSet() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text(
          "Quick Set Timer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: quickTimes.map((time) {
            return ListTile(
              leading: const Icon(Icons.timer),
              title: Text(
                "$time seconds",
                style: const TextStyle(fontSize: 18),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _setQuickTime(time);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _setQuickTime(int time) {
    setState(() {
      setTime = time;
      seconds = time;
      status = statusReady;
      isRunning = false;
    });
  }

  void _onSliderChanged(double value) {
    if (!isRunning) {
      setState(() {
        setTime = value.toInt();
        seconds = value.toInt();
      });
    }
  }

  String _getTimerStateText() {
    return isRunning ? "Active" : "Stopped";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Countdown Timer",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerDisplay(),
              const SizedBox(height: 40),
              _buildSliderSection(),
              const SizedBox(height: 40),
              _buildButtonRow(),
              const SizedBox(height: 30),
              _buildTimerStateIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isRunning ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isRunning ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          seconds.toString(),
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: seconds <= 5 && seconds > 0 ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Set Timer: $setTime seconds",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            if (isRunning)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Locked",
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
          ],
        ),
        Slider(
          value: setTime.toDouble(),
          min: minTime,
          max: maxTime,
          divisions: ((maxTime - minTime) ~/ 5).toInt(),
          label: setTime.toString(),
          onChanged: isRunning ? null : _onSliderChanged,
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: isRunning ? null : startTimer,
          icon: const Icon(Icons.play_arrow),
          label: const Text("Start"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: resetTimer,
          icon: const Icon(Icons.refresh),
          label: const Text("Reset"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: showQuickSet,
          icon: const Icon(Icons.timer),
          label: const Text("Quick Set"),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerStateIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRunning ? Icons.timer : Icons.timer_off,
            size: 20,
            color: isRunning ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            "Timer: ${_getTimerStateText()}",
            style: TextStyle(
              fontSize: 16,
              color: isRunning ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}