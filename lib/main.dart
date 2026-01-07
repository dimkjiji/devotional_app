import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const DevotionalApp());

class DevotionalApp extends StatefulWidget {
  const DevotionalApp({super.key});

  @override
  State<DevotionalApp> createState() => _DevotionalAppState();
}

class _DevotionalAppState extends State<DevotionalApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "말씀 한 스푼",
      theme: ThemeData(
        brightness: Brightness.light, 
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, 
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      themeMode: _themeMode,
      home: DevotionalHome(onThemeToggle: toggleTheme),
    );
  }
}

class DevotionalHome extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const DevotionalHome({super.key, required this.onThemeToggle});

  @override
  State<DevotionalHome> createState() => _DevotionalHomeState();
}

class _DevotionalHomeState extends State<DevotionalHome> {
  final TextEditingController _noteController = TextEditingController();
  List<List<dynamic>> listData = [];
  int currentIndex = 1; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Orchestrates loading the CSV and the last saved page
  Future<void> _initializeData() async {
    await _loadCSV();
    await _loadLastState();
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCSV() async {
    try {
      // Relative path to your internal asset folder
      final rawData = await rootBundle.loadString("assets/devotionals.csv");
      setState(() {
        listData = const CsvToListConverter().convert(rawData);
      });
    } catch (e) {
      debugPrint("CSV Load Error: $e");
    }
  }

  // Remembers the last page and the last note
  Future<void> _loadLastState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentIndex = prefs.getInt('last_index') ?? 1;
      _noteController.text = prefs.getString('note_$currentIndex') ?? "";
    });
  }

  // Saves the page and note simultaneously
  Future<void> _saveState(String noteValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_index', currentIndex);
    await prefs.setString('note_$currentIndex', noteValue);
  }

  void _navigateTo(int index) {
    // Safety Check: Ensure the index actually exists in the 365-day list
    if (index >= 0 && index < listData.length) {
      setState(() {
        currentIndex = index;
        _loadNoteForIndex(index);
      });
      _saveState(_noteController.text);
      Navigator.pop(context); // Closes the sidebar
    }
  }

  Future<void> _loadNoteForIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _noteController.text = prefs.getString('note_$index') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || listData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // --- SAFETY GAUGES ---
    // Prevents "RangeError" if a row is missing a column
    String dateLabel = listData[currentIndex].isNotEmpty ? listData[currentIndex][0].toString() : "No Date";
    String verse     = listData[currentIndex].length > 1 ? listData[currentIndex][1].toString() : "";
    String content   = listData[currentIndex].length > 2 ? listData[currentIndex][2].toString() : "";
    String fatherPrayer = listData[currentIndex].length > 3 ? listData[currentIndex][3].toString() : "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("말씀 한 스푼"),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: widget.onThemeToggle)
        ],
      ),
      // Left Navigation Sidebar
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Center(
                child: Text("목차", style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                cacheExtent: 1000, // Boosts performance for 365 entries
                itemCount: listData.length - 1,
                itemBuilder: (context, index) {
                  int actualIndex = index + 1; // Skip header row
                  return ListTile(
                    dense: true,
                    title: Text(listData[actualIndex][0].toString()),
                    selected: currentIndex == actualIndex,
                    onTap: () => _navigateTo(actualIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(verse, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            const Divider(height: 40),
            Text(content, style: const TextStyle(fontSize: 19, height: 1.6)),
            
            // --- 함께하는 기도 (Father's Prayer) ---
            const SizedBox(height: 40),
            const Text("함께하는 기도", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
            const SizedBox(height: 12),
            Text(fatherPrayer, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.5)),
            
            const Divider(height: 50),
            const Text("나의 기도 / 일기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), 
                hintText: "오늘 말씀을 통해 느낀 점을 적어보세요...",
              ),
              onChanged: (value) => _saveState(value),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}