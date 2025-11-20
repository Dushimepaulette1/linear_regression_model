import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EcoCarProApp());
}

// --- 🎨 PRO THEME: High Contrast & Friendly ---
class AppColors {
  static const Color background = Color(0xFFF8F9FA); // Crisp Off-White
  static const Color cardColor = Colors.white;
  static const Color primaryBrand = Color(
    0xFF2E7D32,
  ); // Professional Forest Green
  static const Color accentGreen = Color(0xFF00C853); // Bright Highlight
  static const Color textDark = Color(
    0xFF1A1A1A,
  ); // Almost Black (High Readability)
  static const Color textGrey = Color(0xFF546E7A); // Blue-Grey for subtitles
  static const Color errorRed = Color(0xFFD32F2F); // Readable Red
}

class EcoCarProApp extends StatelessWidget {
  const EcoCarProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoCar Analyzer',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryBrand,
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primaryBrand,
          secondary: AppColors.accentGreen,
        ),
        // Making the inputs look inviting and clear
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          labelStyle: const TextStyle(
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primaryBrand,
            fontWeight: FontWeight.bold,
          ),
          helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          errorStyle: const TextStyle(
            color: AppColors.errorRed,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryBrand,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrand,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Input Controllers ---
  final TextEditingController _engineController = TextEditingController();
  final TextEditingController _cylindersController = TextEditingController();
  final TextEditingController _fuelConsController = TextEditingController();
  String? _selectedFuelType;

  // --- State ---
  String _co2Result = "0";
  String _statusMessage = "Ready to Analyze";
  bool _isLoading = false;
  bool _hasResult = false;

  // --- Validation Logic (User Friendly Messages) ---
  String? _validateEngine(String? val) {
    if (val == null || val.isEmpty) return "Please enter engine size.";
    final n = double.tryParse(val);
    if (n == null) return "Numbers only (e.g. 2.0)";
    if (n <= 0) return "Must be greater than 0";
    if (n > 10) return "Max engine size is 10.0 Liters"; // Specific help!
    return null;
  }

  String? _validateCylinders(String? val) {
    if (val == null || val.isEmpty) return "Please enter cylinders.";
    final n = int.tryParse(val);
    if (n == null) return "Whole numbers only (e.g. 4)";
    if (n < 3) return "Minimum 3 cylinders required"; // Specific help!
    if (n > 16) return "Max 16 cylinders allowed";
    return null;
  }

  String? _validateFuel(String? val) {
    if (val == null || val.isEmpty) return "Required.";
    final n = double.tryParse(val);
    if (n == null) return "Numbers only.";
    if (n <= 0) return "Must be positive.";
    if (n > 50) return "Max consumption is 50 L/100km"; // Specific help!
    return null;
  }

  // --- API Logic ---
  Future<void> _calculateEmission() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFuelType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Fuel Type")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Analyzing vehicle specs...";
    });

    // ⚠️ PASTE YOUR RENDER URL HERE
    const String apiUrl = 'https://my-insurance-api.onrender.com/predict';

    try {
      final requestData = {
        "engine_size": double.parse(_engineController.text),
        "cylinders": int.parse(_cylindersController.text),
        "fuel_consumption": double.parse(_fuelConsController.text),
        "fuel_type": _selectedFuelType,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final co2 = data['predicted_co2'];
        setState(() {
          _co2Result = (co2 as double).toStringAsFixed(0);
          _statusMessage = co2 < 250
              ? "✅ Low Emissions (Eco-Friendly)"
              : "⚠️ High Emissions (Gas Heavy)";
          _hasResult = true;
        });
      } else {
        setState(() {
          _statusMessage =
              "Server Error: ${response.statusCode}. Check inputs.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Connection Failed. Check internet.";
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Makes everything full width
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "EcoCar",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                        Text(
                          "Analyzer",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrand.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: AppColors.primaryBrand,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- INTRO CARD (User Request) ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What is this tool?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Emission Analyzer is a smart tool designed to predict how much Carbon Dioxide (CO₂) new cars emit. By analyzing engine size and fuel consumption, we help you understand the environmental impact of your vehicle.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- RESULT DASHBOARD ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _hasResult
                          ? [AppColors.primaryBrand, AppColors.accentGreen]
                          : [Colors.grey.shade800, Colors.grey.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _hasResult
                            ? AppColors.accentGreen.withOpacity(0.4)
                            : Colors.transparent,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _hasResult ? "PREDICTED CO₂ OUTPUT" : "AWAITING INPUTS",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _hasResult ? _co2Result : "--",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          if (_hasResult)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12, left: 6),
                              child: Text(
                                "g/km",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                const Text(
                  "VEHICLE SPECIFICATIONS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),

                // --- INPUTS ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _engineController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateEngine,
                        decoration: const InputDecoration(
                          labelText: "Engine Size",
                          helperText: "Max 10.0L", // Helpful guide
                          suffixText: "L",
                          prefixIcon: Icon(
                            Icons.settings_input_component_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cylindersController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateCylinders,
                        decoration: const InputDecoration(
                          labelText: "Cylinders",
                          helperText: "Min 3, Max 16", // Helpful guide
                          suffixText: "cyl",
                          prefixIcon: Icon(Icons.grid_view),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _fuelConsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateFuel,
                  decoration: const InputDecoration(
                    labelText: "Combined Fuel Consumption",
                    helperText: "Average L/100km (Max 50)", // Helpful guide
                    suffixText: "L/100km",
                    prefixIcon: Icon(Icons.local_gas_station_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown with Style
                DropdownButtonFormField<String>(
                  value: _selectedFuelType,
                  decoration: const InputDecoration(
                    labelText: "Fuel Type",
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  hint: const Text("Select fuel source"),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: const [
                    DropdownMenuItem(
                      value: "X",
                      child: Text("Regular Gasoline (X)"),
                    ),
                    DropdownMenuItem(
                      value: "Z",
                      child: Text("Premium Gasoline (Z)"),
                    ),
                    DropdownMenuItem(value: "D", child: Text("Diesel (D)")),
                    DropdownMenuItem(
                      value: "E",
                      child: Text("Ethanol / E85 (E)"),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedFuelType = val),
                  validator: (val) => val == null ? "Required" : null,
                ),
                const SizedBox(height: 40),

                // --- BIG ACTION BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _calculateEmission,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("ANALYZE IMPACT"),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
