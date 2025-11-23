# 🌿 EcoCar Analyzer: CO₂ Emission Predictor

## 1. Mission & Problem Statement

Carbon emissions from vehicles are a leading cause of climate change. This project aims to solve the lack of transparency in environmental impact by providing a machine learning tool that predicts a vehicle's CO₂ emissions based on its engine specifications. By analyzing technical factors, this tool empowers users to make eco-friendly transportation choices.

## 2. Data Description & Source

The machine learning model was trained on the Fuel Consumption Ratings dataset from Canada Open Data.

**Source:** IBM Developer Skills Network (`FuelConsumptionCo2.csv`)

**Dataset:** Contains 1,067 records with features such as:

- **Inputs:** Engine Size (L), Cylinders, Fuel Consumption (Combined), Fuel Type (X, Z, D, E)
- **Target:** CO₂ Emissions (g/km)

## 3. Project Structure

```text
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb            # Jupyter Notebook (Analysis, Training, Evaluation)
│   │   └── content/
│   │       └── FuelConsumptionCo2.csv    # Dataset
│   ├── API/
│   │   ├── prediction.py                 # FastAPI backend code
│   │   ├── requirements.txt              # Backend dependencies
│   │   ├── my_best_co2_model.pkl         # Saved Decision Tree Model
│   │   ├── my_scaler.pkl                 # Saved Scaler
│   │   ├── model_columns.pkl             # Feature columns
│   └── flutterapp/
│       ├── lib/
│       │   └── main.dart                 # Flutter app source code
│       ├── pubspec.yaml                  # Flutter app config
│       ├── build/web/                    # Web build output (after flutter build web)
│       └── ...                           # Other Flutter platform folders (android, ios, etc.)
└── README.md
```

## 4. Public API Endpoint

The model is deployed on Render as a REST API. It accepts POST requests and includes Pydantic validation for data integrity.

- **Base URL:** https://my-insurance-api.onrender.com
- **Swagger UI (Docs):** https://my-insurance-api.onrender.com/docs

**Example JSON Request:**

```json
POST /predict
{
  "engine_size": 2.0,
  "cylinders": 4,
  "fuel_consumption": 7.5,
  "fuel_type": "X"
}
```

## 5. Video Demo

A 5-minute video demonstrating the Model creation, API deployment, and Mobile App usage.

[Click Here](https://youtu.be/8m1Jb2OaTdg) to Watch the Video Demo

## 6. Model Performance

I trained three models to find the best predictor. The Decision Tree Regressor was selected for deployment due to its superior handling of categorical fuel rules.

| Model             | R² Score | Loss (MSE) | Verdict                                       |
| ----------------- | -------- | ---------- | --------------------------------------------- |
| Linear Regression | 0.9881   | 49.19      | Good baseline, but missed non-linear patterns |
| Random Forest     | 0.9908   | 37.86      | High accuracy, but slightly higher error      |
| Decision Tree     | 0.9936   | 26.47      | Selected (Lowest Error)                       |

## 7. How to Run the Mobile App

To run the Flutter application locally:

**Prerequisites:** Install Flutter SDK and connect an Emulator/Device.

**Navigate to App Folder:**

```sh
cd summative/flutterapp
```

**Install Dependencies:**

```sh
flutter pub get
```

**Run the App:**

```sh
flutter run
```

---

Developed by Dushime Paulette
