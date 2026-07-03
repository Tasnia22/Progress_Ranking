import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SkillProvider(),
      child: const MyApp(),
    ),
  );
}

/// ==================== SKILL MODEL ====================
class Skill {
  String title;
  bool isCompleted;
  Skill({required this.title, this.isCompleted = false});
}

/// ==================== PROVIDER ====================
class SkillProvider extends ChangeNotifier {
  // ===== DEFINE YOUR CHECKLIST HERE =====
  final List<Skill> skills = [
    Skill(title: "Learn Flutter Basics"),
    Skill(title: "Master Provider State Management"),
    Skill(title: "Build REST API"),
    Skill(title: "Database Integration"),
    Skill(title: "Deploy App"),
    // Add more items here:
    // Skill(title: "Push Notifications"),
    // Skill(title: "Authentication"),
    // Skill(title: "Cloud Firestore"),
  ];
  // =====================================

  void toggleSkill(int i, bool v) {
    skills[i].isCompleted = v;
    notifyListeners();
  }

  void addSkill(String title) {
    skills.add(Skill(title: title));
    notifyListeners();
  }

  void editSkill(int i, String title) {
    skills[i].title = title;
    notifyListeners();
  }

  void deleteSkill(int i) {
    skills.removeAt(i);
    notifyListeners();
  }

  double get progress => skills.isEmpty
      ? 0
      : skills.where((e) => e.isCompleted).length / skills.length;

  int get percentage => (progress * 100).round();
}

/// ==================== APP ====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// ==================== HOME PAGE ====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSkill(SkillProvider provider) {
    if (_controller.text.isNotEmpty) {
      provider.addSkill(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 768;

    return Consumer<SkillProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F5F5),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: isSmallScreen
                  ? Center(child: _buildChecklistPanel(provider))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildChecklistPanel(provider),
                        ),
                      ],
                    ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItemDialog(context, provider),
            backgroundColor: Colors.teal,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_task, color: Colors.white, size: 30),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: Colors.teal,
          //  child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       IconButton(
          //         icon: const Icon(Icons.home, color: Colors.white),
          //         onPressed: () {},
          //       ),
          //       const SizedBox(width: 50),
          //       IconButton(
          //         icon: const Icon(Icons.delete, color: Colors.white),
          //         onPressed: () {},
          //       ),
          //     ],
          //   ),
          ),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context, SkillProvider provider) {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Item"),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Enter task name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(
              Icons.add_circle_outline,
              color: Colors.teal,
            ),
          ),
          onSubmitted: (value) {
            _addSkill(provider);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addSkill(provider);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistPanel(SkillProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          const Text(
            "My Checklist",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// Progress Card
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Progress:", style: TextStyle(fontSize: 16)),
                    Text(
                      "${provider.percentage}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: provider.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Checklist Items
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              itemCount: provider.skills.length,
              itemBuilder: (context, index) {
                final skill = provider.skills[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: skill.isCompleted,
                          title: Text(skill.title),
                          activeColor: Colors.teal,
                          onChanged: (value) {
                            provider.toggleSkill(index, value ?? false);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deleteSkill(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
