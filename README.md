# EcoCar Analyzer: Intelligent CO₂ Emission Predictor

## 1. Mission & Problem Statement

Climate change is one of the most pressing challenges of our time, with vehicular emissions being a major contributor. The **EcoCar Analyzer** project aims to empower consumers and manufacturers by providing accurate predictions of a vehicle's Carbon Dioxide (CO₂) emissions based on its engine specifications.

By analyzing key technical factors such as **Engine Size**, **Cylinder count**, and **Fuel Consumption** this tool democratizes environmental data, enabling more eco-conscious transportation choices.

---

## 2. Data Description & Source

The machine learning model was trained on the **Fuel Consumption Ratings** dataset, sourced from **Canada Open Data** (via IBM Developer Skills Network).

**Source URL:** https://www.kaggle.com/code/ginny100/ibm-ai-engineering-simple-linear-regression

### Dataset Statistics

- **Volume:** 1,067 unique vehicle records
- **Variety:** Numerical & Categorical data

### Key Features

- **Inputs (X):** Engine Size (L), Cylinders, Fuel Consumption (L/100km), Fuel Type (Regular, Premium, Ethanol, Diesel)
- **Target (y):** CO₂ Emissions (g/km)

**Insight:** Exploratory Data Analysis (EDA) revealed a strong linear correlation between Engine Size and Emissions, with additional non-linear effects introduced by differing fuel types.

---

## 3. Technical Architecture

This project follows a **decoupled Client-Server Architecture**:

### Machine Learning Pipeline (Python/Jupyter)

- Data Cleaning
- Feature Engineering (One-Hot Encoding)
- Model Training

### Backend API (FastAPI)

- REST model-serving endpoints
- Pydantic for strict data validation
- CORS middleware for secure access

### Frontend Mobile App (Flutter)

- Responsive high-contrast interface
- Designed for efficient user interaction

---

## 4. Model Performance

Three regression algorithms were trained and evaluated using **Mean Squared Error (MSE)** and **R² Score**.

| Model             | R² Score | Loss (MSE) | Verdict                                              |
| ----------------- | -------- | ---------- | ---------------------------------------------------- |
| Linear Regression | 0.9881   | 49.19      | High accuracy, but missed subtle fuel-type variances |
| Random Forest     | 0.9908   | 37.86      | Excellent performance, slightly higher complexity    |
| Decision Tree     | 0.9936   | 26.47      | **WINNER**                                           |

**Justification:** The **Decision Tree Regressor** was deployed because it achieved the lowest MSE (26.47) and best captured categorical fuel-type behavior.

---

## 5. Public API Access

The prediction engine is deployed on **Render** and publicly accessible.

- **Base Endpoint:** `https://my-insurance-api.onrender.com/`
- **Docs (Swagger UI):** `https://my-insurance-api.onrender.com/docs`

### Example JSON Request

```json
POST /predict
{
  "engine_size": 2.4,
  "cylinders": 4,
  "fuel_consumption": 8.5,
  "fuel_type": "X"
}
```

---

## 6. Video Demo

A detailed 5-minute demonstration covering model training, API deployment, and a live walkthrough of the mobile application.

**Click Here to Watch the Video Demo**

---

## 7. How to Run the Mobile App

The mobile application is built using **Flutter**.

### Prerequisites

- Flutter SDK installed
- Android Emulator or physical device connected

### Installation Steps

```bash
cd summative/flutterapp
flutter pub get
flutter run
```

---

## 8. Project Structure

```
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb      # Jupyter Notebook (Analysis & Training)
│   │
│   ├── API/
│   │   ├── main.py                 # FastAPI Application Code
│   │   ├── requirements.txt        # Backend Dependencies
│   │   ├── my_best_co2_model.pkl   # Serialized Model
│   │   ├── my_scaler.pkl           # Data Scaler
│   │   ├── model_columns.pkl       # Feature alignment
│   │
│   ├── flutterapp/
│       ├── lib/
│       │   ├── main.dart           # Mobile App Source Code
│       ├── pubspec.yaml            # App Configuration
```

---

**Developed by Paulette for the Linear Regression Summative Assignment.**
