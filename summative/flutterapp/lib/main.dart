import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const InsuranceApp());
}

class InsuranceApp extends StatelessWidget {
  const InsuranceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediCost AI',
      theme: ThemeData(
        // 🎨 Professional Feminine Theme: Mulberry & Rose
        primaryColor: const Color(0xFF880E4F),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF880E4F),
          secondary: const Color(0xFFBC477B),
        ),
        scaffoldBackgroundColor: const Color(
          0xFFFDF7F9,
        ), // Very light rose-grey background
        useMaterial3: true,
        fontFamily: 'Roboto', // Clean, standard font
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), // Softer rounded corners
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.purple.shade50),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF880E4F), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
      home: const PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();

  // --- Variables ---
  String? _selectedSex;
  String? _selectedSmoker;
  String? _selectedRegion;

  // --- State ---
  String _result = "";
  List<String> _insights = []; // To store the "Why" explanations
  bool _isLoading = false;
  bool _isError = false;

  // --- 🧮 BMI Calculator ---
  void _showBMICalculator() {
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "BMI Calculator",
          style: TextStyle(color: Color(0xFF880E4F)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your stats to calculate BMI automatically.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                suffixText: "cm",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                suffixText: "kg",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final double? h = double.tryParse(heightController.text);
              final double? w = double.tryParse(weightController.text);

              if (h != null && w != null && h > 0) {
                final double heightInMeters = h / 100;
                final double bmi = w / (heightInMeters * heightInMeters);
                setState(() {
                  _bmiController.text = bmi.toStringAsFixed(1);
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF880E4F),
              foregroundColor: Colors.white,
            ),
            child: const Text("Calculate"),
          ),
        ],
      ),
    );
  }

  // --- 🧠 Analysis Logic (Client Side) ---
  // This generates the "Explanation" based on inputs
  List<String> _generateInsights(
    double bmi,
    String smoker,
    int age,
    int children,
  ) {
    List<String> notes = [];

    if (smoker == "yes") {
      notes.add(
        "⚠️ Smoker Status: This is the #1 factor increasing your cost.",
      );
    } else {
      notes.add("✅ Non-Smoker: You are saving significantly by not smoking.");
    }

    if (bmi >= 30) {
      notes.add(
        "⚠️ BMI (${bmi.toStringAsFixed(1)}): Being in the obesity range increases health risks and premiums.",
      );
    } else if (bmi < 18.5) {
      notes.add(
        "ℹ️ BMI: Being underweight can sometimes affect health ratings.",
      );
    } else {
      notes.add("✅ BMI: Your healthy weight helps keep costs lower.");
    }

    if (age > 50) {
      notes.add("ℹ️ Age: Insurance premiums naturally rise as age increases.");
    }

    if (children > 2) {
      notes.add(
        "ℹ️ Dependents: Covering ${children} children adds to the base premium.",
      );
    }

    return notes;
  }

  // --- API Function ---
  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = "";
      _insights = [];
      _isError = false;
    });

    // ⚠️ PASTE YOUR RENDER URL HERE
    const String apiUrl = 'https://my-insurance-api.onrender.com/predict';

    try {
      final double bmi = double.parse(_bmiController.text);
      final int age = int.parse(_ageController.text);
      final int children = int.parse(_childrenController.text);

      final Map<String, dynamic> requestData = {
        "age": age,
        "sex": _selectedSex,
        "bmi": bmi,
        "children": children,
        "smoker": _selectedSmoker,
        "region": _selectedRegion,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          double cost = data['predicted_cost'];
          _result = "\$${cost.toStringAsFixed(2)}";
          // Generate the "Why" explanation
          _insights = _generateInsights(bmi, _selectedSmoker!, age, children);
        });
      } else {
        setState(() {
          _isError = true;
          _result = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _result = "Connection Failed.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom Gradient AppBar
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF880E4F),
                Color(0xFFC2185B),
              ], // Mulberry Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
            ), // Heart icon for wellness feel
            SizedBox(width: 10),
            Text(
              "MediCost Insights",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro Text
              const Text(
                "Your Health Profile",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF880E4F),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Enter your details below to get a personalized insurance cost estimate.",
                style: TextStyle(color: Colors.grey[700], height: 1.5),
              ),
              const SizedBox(height: 25),

              // --- INPUT CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ROW 1: Age & Sex
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Age",
                              prefixIcon: Icon(
                                Icons.cake_outlined,
                                color: Color(0xFFBC477B),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSex,
                            decoration: const InputDecoration(
                              labelText: "Sex",
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0xFFBC477B),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "female",
                                child: Text("Female"),
                              ),
                              DropdownMenuItem(
                                value: "male",
                                child: Text("Male"),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedSex = val),
                            validator: (value) =>
                                value == null ? "Required" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ROW 2: BMI & Children
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _bmiController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: "BMI",
                              prefixIcon: const Icon(
                                Icons.monitor_weight_outlined,
                                color: Color(0xFFBC477B),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calculate_outlined,
                                  color: Color(0xFF880E4F),
                                ),
                                tooltip: "Calculate BMI",
                                onPressed: _showBMICalculator,
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _childrenController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Children",
                              prefixIcon: Icon(
                                Icons.child_care,
                                color: Color(0xFFBC477B),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Required" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Smoker Status
                    DropdownButtonFormField<String>(
                      value: _selectedSmoker,
                      decoration: const InputDecoration(
                        labelText: "Do you smoke?",
                        prefixIcon: Icon(
                          Icons.smoke_free_outlined,
                          color: Color(0xFFBC477B),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "yes",
                          child: Text("Yes, I smoke"),
                        ),
                        DropdownMenuItem(
                          value: "no",
                          child: Text("No, I don't"),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedSmoker = val),
                      validator: (value) => value == null ? "Required" : null,
                    ),
                    const SizedBox(height: 20),

                    // Region
                    DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      decoration: const InputDecoration(
                        labelText: "Region (USA)",
                        prefixIcon: Icon(
                          Icons.map_outlined,
                          color: Color(0xFFBC477B),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "southwest",
                          child: Text("Southwest"),
                        ),
                        DropdownMenuItem(
                          value: "southeast",
                          child: Text("Southeast"),
                        ),
                        DropdownMenuItem(
                          value: "northwest",
                          child: Text("Northwest"),
                        ),
                        DropdownMenuItem(
                          value: "northeast",
                          child: Text("Northeast"),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedRegion = val),
                      validator: (value) => value == null ? "Required" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- ACTION BUTTON ---
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF880E4F), Color(0xFFC2185B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF880E4F).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _makePrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ANALYZE COSTS",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // --- RESULTS SECTION ---
              if (_result.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: _isError
                        ? Colors.red.shade50
                        : const Color(0xFFF3E5F5), // Light Purple background
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isError ? Colors.red : const Color(0xFFCE93D8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          _isError ? "Error" : "Estimated Annual Premium",
                          style: TextStyle(
                            color: _isError
                                ? Colors.red
                                : const Color(0xFF6A1B9A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          _result,
                          style: TextStyle(
                            color: _isError
                                ? Colors.red
                                : const Color(0xFF4A148C),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- THE "WHY?" SECTION ---
                      if (!_isError) ...[
                        const Text(
                          "Factors Influencing this Price:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._insights.map(
                          (insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.arrow_right,
                                  color: Color(0xFF880E4F),
                                ),
                                Expanded(
                                  child: Text(
                                    insight,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
