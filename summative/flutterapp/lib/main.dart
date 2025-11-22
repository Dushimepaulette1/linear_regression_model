import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SinglePageApp());
}

class SinglePageApp extends StatelessWidget {
  const SinglePageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoCar Analyzer',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _engineController = TextEditingController();
  final TextEditingController _cylindersController = TextEditingController();
  final TextEditingController _fuelConsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _engineController.addListener(_clearResultOnInput);
    _cylindersController.addListener(_clearResultOnInput);
    _fuelConsController.addListener(_clearResultOnInput);
  }

  @override
  void dispose() {
    _engineController.removeListener(_clearResultOnInput);
    _cylindersController.removeListener(_clearResultOnInput);
    _fuelConsController.removeListener(_clearResultOnInput);
    _engineController.dispose();
    _cylindersController.dispose();
    _fuelConsController.dispose();
    super.dispose();
  }

  void _clearResultOnInput() {
    if (_resultDisplay != "---" || _emissionMessage.isNotEmpty || _showError) {
      setState(() {
        _resultDisplay = "---";
        _emissionMessage = "";
        _showError = false;
      });
    }
  }

  String? _selectedFuelType;

  // State
  String _resultDisplay = "---";
  String _emissionMessage = "";
  bool _isLoading = false;
  bool _showError = false;

  final String apiUrl = 'https://my-insurance-api.onrender.com/predict';

  // Validation with detailed error messages
  String? _validateEngine(String? val) {
    if (val == null || val.isEmpty) return "Engine size is required";
    final n = double.tryParse(val);
    if (n == null) return "Please enter a valid number";
    if (n <= 0) return "Engine size must be greater than 0";
    if (n > 10) return "Engine size cannot exceed 10.0 Liters";
    return null;
  }

  String? _validateCylinders(String? val) {
    if (val == null || val.isEmpty) return "Number of cylinders is required";
    final n = int.tryParse(val);
    if (n == null) return "Please enter a whole number";
    if (n < 3) return "Minimum 3 cylinders required";
    if (n > 16) return "Maximum 16 cylinders allowed";
    return null;
  }

  String? _validateFuel(String? val) {
    if (val == null || val.isEmpty) return "Fuel consumption is required";
    final n = double.tryParse(val);
    if (n == null) return "Please enter a valid number";
    if (n <= 0) return "Fuel consumption must be positive";
    if (n > 50) return "Fuel consumption cannot exceed 50 L/100km";
    return null;
  }

  Future<void> _getPrediction() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _resultDisplay = "Please fix validation errors above";
        _showError = true;
      });
      return;
    }

    if (_selectedFuelType == null) {
      setState(() {
        _resultDisplay = "Please select a fuel type";
        _showError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "engine_size": double.parse(_engineController.text),
          "cylinders": int.parse(_cylindersController.text),
          "fuel_consumption": double.parse(_fuelConsController.text),
          "fuel_type": _selectedFuelType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double co2 = (data['predicted_co2'] as num).toDouble();
        String message;
        if (co2 > 250) {
          message = "High CO₂ emissions (Not Eco-Friendly)";
        } else {
          message = "Low CO₂ emissions (Eco-Friendly)";
        }
        setState(() {
          _resultDisplay = "${co2.toStringAsFixed(1)} g/km";
          _emissionMessage = message;
          _showError = false;
        });
      } else if (response.statusCode == 422) {
        // Server validation error
        final errorData = jsonDecode(response.body);
        String errorMsg = "Invalid input data";
        if (errorData['detail'] != null &&
            (errorData['detail'] as List).isNotEmpty) {
          errorMsg = errorData['detail'][0]['msg'] ?? errorMsg;
        }
        setState(() {
          _resultDisplay = "Error: $errorMsg";
          _emissionMessage = "";
          _showError = true;
        });
      } else {
        setState(() {
          _resultDisplay = "Server Error ${response.statusCode}";
          _emissionMessage = "";
          _showError = true;
        });
      }
    } on SocketException {
      setState(() {
        _resultDisplay = "Connection Failed - Check Internet";
        _emissionMessage = "";
        _showError = true;
      });
    } catch (e) {
      setState(() {
        _resultDisplay = "Error: ${e.toString()}";
        _emissionMessage = "";
        _showError = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EcoCar CO₂ Predictor",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Enter Vehicle Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _engineController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateEngine,
                decoration: const InputDecoration(
                  labelText: "Engine Size (L)",
                  suffixText: "L",
                  helperText: "Max 10.0 Liters",
                  prefixIcon: Icon(Icons.settings_input_component),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _cylindersController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateCylinders,
                decoration: const InputDecoration(
                  labelText: "Cylinders",
                  suffixText: "cyl",
                  helperText: "3 to 16 cylinders",
                  prefixIcon: Icon(Icons.grid_view),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _fuelConsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateFuel,
                decoration: const InputDecoration(
                  labelText: "Fuel Consumption",
                  suffixText: "L/100km",
                  helperText: "Max 50 L/100km",
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                decoration: const InputDecoration(
                  labelText: "Fuel Type",
                  prefixIcon: Icon(Icons.category),
                ),
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
                  DropdownMenuItem(value: "E", child: Text("Ethanol (E)")),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedFuelType = v;
                    _resultDisplay = "---";
                    _emissionMessage = "";
                    _showError = false;
                  });
                },
                validator: (v) => v == null ? "Fuel type is required" : null,
              ),

              const SizedBox(height: 30),

              // The predicting button
              ElevatedButton(
                onPressed: _isLoading ? null : _getPrediction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        "Predict",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 40),

              // Display area
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: _showError ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _showError ? Colors.red : Colors.green,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _showError ? "Error" : "Predicted CO₂ Emissions",
                      style: TextStyle(
                        fontSize: 14,
                        color: _showError ? Colors.red[700] : Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resultDisplay,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _showError ? Colors.red[700] : Colors.green[700],
                      ),
                    ),
                    if (!_showError && _resultDisplay != "---") ...[
                      const SizedBox(height: 12),
                      Text(
                        _emissionMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _emissionMessage.contains('High')
                              ? Colors.red[800]
                              : Colors.green[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
