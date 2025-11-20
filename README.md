
-----

````markdown
# 🌿 EcoCar Analyzer: CO2 Emission Prediction

## 1. Mission & Problem Description
The goal of this project is to build a Machine Learning tool that accurately predicts the Carbon Dioxide (CO₂) emissions of vehicles based on their engine specifications. By analyzing factors like Engine Size, Cylinders, and Fuel Consumption, this app helps drivers and manufacturers estimate the environmental impact of cars, promoting eco-friendly transportation choices.

## 2. Data Description & Source
**Source:** The dataset was sourced from [IBM / Canada Open Data](https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-ML0101EN-SkillsNetwork/labs/Module%202/data/FuelConsumptionCo2.csv).

**Dataset Details:**
* **Volume:** 1,067 vehicle records.
* **Variety:**
    * **Numerical Inputs:** Engine Size (L), Cylinders, Combined Fuel Consumption (L/100km).
    * **Categorical Inputs:** Fuel Type (Regular Gasoline, Premium, Diesel, Ethanol).
    * **Target Output:** CO2 Emissions (g/km).
* **Key Insight:** The analysis revealed a strong positive correlation between Engine Size and Emissions, but specific fuel types (like Ethanol) created non-linear patterns that required advanced modeling.

## 3. Public API Access
The prediction engine is deployed as a REST API using **FastAPI** and hosted on **Render**. It features strict Pydantic validation to ensure realistic inputs (e.g., preventing negative engine sizes).

* **🚀 Base URL:** `https://[YOUR-APP-NAME].onrender.com`
* **📄 Swagger UI (Docs & Testing):** `https://[YOUR-APP-NAME].onrender.com/docs`

> **Note:** You can test the API directly using the Swagger UI link above.

## 4. Video Demo
A 5-minute walkthrough demonstrating the Model training, API deployment, and the Mobile App in action:

* **🎥 YouTube Link:** [PASTE YOUR YOUTUBE LINK HERE]

## 5. Project Structure
The repository is organized as follows:

```text
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb      # Jupyter Notebook (Data Analysis, Model Training)
│   │
│   ├── API/
│   │   ├── main.py                 # FastAPI backend code (Prediction logic)
│   │   ├── requirements.txt        # Python dependencies
│   │   ├── my_best_co2_model.pkl   # Saved Decision Tree Model
│   │   ├── my_scaler.pkl           # Saved Scaler
│   │   ├── model_columns.pkl       # Saved Column names
│   │
│   ├── FlutterApp/
│       ├── lib/
│       │   ├── main.dart           # Flutter Mobile App Source Code
│       ├── pubspec.yaml            # Flutter dependencies
````

## 6\. Model Performance

We trained three different regression models to find the best predictor. The **Decision Tree Regressor** was selected as the winner.

| Model | R² Score | Loss (MSE) | Verdict |
| :--- | :--- | :--- | :--- |
| **Linear Regression** | 0.9881 | 49.19 | Excellent fit, but missed subtle fuel-type rules. |
| **Decision Tree** | **0.9936** | **26.47** | **Selected.** Lowest error; captured exact rules perfectly. |
| **Random Forest** | 0.9908 | 37.86 | Very strong, but slightly higher error than the single tree. |

## 7\. How to Run the Mobile App

The mobile application is built with **Flutter** and features a responsive "Pro-UX" design with real-time input validation.

### Prerequisites

  * Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
  * Ensure you have an Emulator running or a physical device connected via USB.

### Installation Steps

1.  **Navigate to the App folder:**

    ```bash
    cd summative/FlutterApp
    ```

2.  **Install Dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run the App:**

    ```bash
    flutter run
    ```

-----

*Developed by Paulette for the Linear Regression Summative Assignment.*

```
```