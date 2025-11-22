from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import joblib
import pandas as pd
from fastapi.middleware.cors import CORSMiddleware

# initializing the app
app = FastAPI(
    title="EcoCar CO2 Predictor",
    description="API to predict car CO2 emissions based on engine specs.",
    version="2.0.0"
)

# This is the CORS middleware setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Loaing the new CO2 Model and Scaler
try:
    model = joblib.load('my_best_co2_model.pkl')
    scaler = joblib.load('my_scaler.pkl')
    model_columns = joblib.load('model_columns.pkl')
    print("CO2 Model and tools loaded successfully.")
except Exception as e:
    print(f"Error loading files: {e}")

# Engine Size, Cylinders, Combined Consumption, Fuel Type
class CarInput(BaseModel):
    engine_size: float = Field(..., gt=0.0, le=10.0, description="Engine Size in Liters (0.0 - 10.0)")
    cylinders: int = Field(..., gt=2, le=16, description="Number of Cylinders (3-16)")
    fuel_consumption: float = Field(..., gt=0.0, le=50.0, description="Combined Fuel Cons (L/100km)")
    fuel_type: str = Field(..., pattern="^(X|Z|D|E)$", description="Fuel: X(Regular), Z(Premium), D(Diesel), E(Ethanol)")

    class Config:
        schema_extra = {
            "example": {
                "engine_size": 3.5,
                "cylinders": 6,
                "fuel_consumption": 11.2,
                "fuel_type": "Z"
            }
        }

# 5. Prediction Endpoint
@app.post("/predict")
def predict_emissions(input_data: CarInput):
    try:
        # Mapping Pydantic fields to the exact column names used in Colab
        data_dict = {
            "Engine_Size": input_data.engine_size,
            "Cylinders": input_data.cylinders,
            "Comb_Cons": input_data.fuel_consumption,
            "Fuel_Type": input_data.fuel_type
        }
        
        # Converting to DataFrame
        input_df = pd.DataFrame([data_dict])
    
        input_encoded = pd.get_dummies(input_df)
        
        # Aligning Columns 
        input_encoded = input_encoded.reindex(columns=model_columns, fill_value=0)
        
        # E. Scaling the Data
        input_scaled = scaler.transform(input_encoded)
        
        # F. Predicting
        prediction = model.predict(input_scaled)
        
        return {
            "predicted_co2": float(prediction[0]),
            "message": "Prediction successful"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Root Endpoint
@app.get("/")
def read_root():
    return {"message": "CO2 Emission API is Live. Go to /docs to test."}