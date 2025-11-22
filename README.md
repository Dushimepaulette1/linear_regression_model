# EcoCar Analyzer: CO₂ Emission Predictor

## Overview

EcoCar Analyzer predicts vehicle CO₂ emissions based on engine specs using a machine learning model. It features:

- Python Jupyter notebook for model training
- FastAPI backend for predictions
- Flutter web/mobile app frontend

## Data Source

- Dataset: Fuel Consumption Ratings (Canada Open Data)
- [Kaggle Link](https://www.kaggle.com/code/ginny100/ibm-ai-engineering-simple-linear-regression)

## Project Structure

```
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb         # Jupyter Notebook (EDA, training)
│   │   └── content/FuelConsumptionCo2.csv
│   ├── API/
│   │   ├── prediction.py              # FastAPI backend
│   │   ├── requirements.txt
│   │   ├── my_best_co2_model.pkl      # Trained model
│   │   ├── my_scaler.pkl              # Scaler
│   │   └── model_columns.pkl          # Feature columns
│   └── flutterapp/
│       ├── lib/main.dart              # Flutter app source
│       ├── pubspec.yaml
│       └── build/web/                 # Web build output (after flutter build web)
└── README.md
```

## Model Performance

| Model             | R² Score |   MSE | Notes                     |
| ----------------- | -------: | ----: | ------------------------- |
| Linear Regression |   0.9881 | 49.19 | Good, but less robust     |
| Random Forest     |   0.9908 | 37.86 | High accuracy             |
| Decision Tree     |   0.9936 | 26.47 | **Deployed model (best)** |

## API Usage

- **Base URL:** `https://my-insurance-api.onrender.com/`
- **Swagger Docs:** `/docs`

**Example request:**

```json
POST /predict
{
  "engine_size": 2.0,
  "cylinders": 4,
  "fuel_consumption": 7.5,
  "fuel_type": "X"
}
```

## Flutter App

- Web demo: [https://ecocar-co2-predictor.netlify.app/](https://ecocar-co2-predictor.netlify.app/)
- To run locally:
  ```sh
  cd summative/flutterapp
  flutter pub get
  flutter run -d chrome
  ```

## Contributors

Developed by Dushime Paulette
