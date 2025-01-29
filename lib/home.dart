import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: const PomodoroTimerScreen(),
    );
  }
}

class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({Key? key}) : super(key: key);

  @override
  _PomodoroTimerScreenState createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  int workTime = 25 * 60; // Default work duration
  int shortBreakTime = 5 * 60; // Default short break
  int longBreakTime = 15 * 60; // Default long break
  int currentTime = 25 * 60; // Timer countdown
  int pomodoroCount = 0;
  bool isWorkPeriod = true;
  Timer? timer;
  bool isRunning = false;

  final List<int> workDurations = [15, 25, 30, 45]; // Options for work duration
  final List<int> breakDurations = [
    5,
    10,
    15,
    20
  ]; // Options for break duration
  int selectedWorkDuration = 25; // Default selected work duration
  int selectedBreakDuration = 5; // Default selected break duration

  TextEditingController taskController = TextEditingController(
      text: "Ali Hoca'nın ödevlerini yap!"); // Task description
  int totalTasks = 4; // Total number of tasks
  TextEditingController taskCountController =
      TextEditingController(text: '4'); // Task count controller
  List<String> completedTasks = []; // List of completed tasks

  void startTimer() {
    if (!isRunning) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (currentTime > 0) {
          setState(() {
            currentTime--;
          });
        } else {
          handleTimerEnd();
        }
      });

      setState(() {
        isRunning = true;
      });
    }
  }

  void handleTimerEnd() {
    if (isWorkPeriod) {
      pomodoroCount++;
      completedTasks.add("${taskController.text} - ${DateTime.now()}");
      checkTaskCompletion(); // Check if tasks completed
      if (pomodoroCount % 4 == 0) {
        setTime(longBreakTime);
      } else {
        setTime(shortBreakTime);
      }
    } else {
      setTime(workTime);
    }
    setState(() {
      isWorkPeriod = !isWorkPeriod;
      isRunning = false;
    });
  }

  void checkTaskCompletion() {
    if (pomodoroCount >= totalTasks) {
      showTaskCompletionDialog();
    }
  }

  void showTaskCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Görev Tamamlandı!'),
          content: const Text(
              'Hedeflenen Pomodoro sayısına ulaştın! biraz mola vermelisin.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void pauseTimer() {
    if (timer != null) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

  void stopTimer() {
    if (timer != null) {
      timer?.cancel();
    }
    setState(() {
      isRunning = false;
      currentTime = workTime;
      pomodoroCount = 0;
      isWorkPeriod = true;
    });
  }

  void setTime(int seconds) {
    setState(() {
      currentTime = seconds;
    });
  }

  void skipPeriod() {
    if (timer != null) {
      timer?.cancel();
      isRunning = false;
    }
    handleTimerEnd();
    startTimer();
  }

  void openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: taskController,
                  decoration: const InputDecoration(
                    labelText: 'Görev Adı',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: taskCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Toplam Görev Sayısı',
                  ),
                  onChanged: (value) {
                    setState(() {
                      totalTasks = int.tryParse(value) ?? totalTasks;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCompletedTasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tamamlanan Görevler'),
          content: completedTasks.isEmpty
              ? const Text('Henüz tamamlanmış bir görev yok.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(completedTasks[index]),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (currentTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (currentTime % 60).toString().padLeft(2, '0');
    final periodText = isWorkPeriod ? 'Çalışma Zamanı' : 'Mola Zamanı';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Zamanlayıcı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => showCompletedTasks(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => openSettings(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              taskController.text,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Görev ${pomodoroCount + 1} / $totalTasks - $periodText',
              style: const TextStyle(fontSize: 18, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Timer and progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: currentTime /
                        (isWorkPeriod
                            ? workTime
                            : (pomodoroCount % 4 == 0
                                ? longBreakTime
                                : shortBreakTime)),
                    strokeWidth: 12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 45, 141, 220)),
                    backgroundColor: const Color.fromARGB(167, 97, 97, 97),
                  ),
                ),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Dropdown for Work Time selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedWorkDuration,
                  items: workDurations.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value dk çalışma'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedWorkDuration = newValue!;
                      workTime = selectedWorkDuration * 60;
                      if (isWorkPeriod) {
                        currentTime = workTime;
                      }
                    });
                  },
                  hint: const Text('Çalışma Süresi'),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedBreakDuration,
                  items: breakDurations.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value dk mola'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedBreakDuration = newValue!;
                      shortBreakTime = selectedBreakDuration * 60;
                      longBreakTime = shortBreakTime * 3; // Example ratio
                    });
                  },
                  hint: const Text('Mola Süresi'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Control buttons (Start, Pause, Reset, Skip)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: startTimer,
                  child: const Text(
                    'Başlat',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isRunning ? pauseTimer : stopTimer,
                  child: Text(
                    isRunning ? 'Duraklat' : 'Sıfırla',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(223, 249, 168, 37)),
                  onPressed: skipPeriod,
                  child: const Text(
                    'Atla',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
