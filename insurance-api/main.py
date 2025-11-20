from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import joblib
import pandas as pd
from fastapi.middleware.cors import CORSMiddleware

# 1. Initialize the Application
app = FastAPI(
    title="Insurance Cost Prediction API",
    description="A simple API to predict medical insurance charges based on user data.",
    version="1.0.0"
)

# 2. Add CORS Middleware (REQUIRED by assignment)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows connections from anywhere
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (POST, GET, etc.)
    allow_headers=["*"],
)

# 3. Load the Saved Model and Scaler
try:
    model = joblib.load('my_best_insurance_model.pkl')
    scaler = joblib.load('my_scaler.pkl')
    model_columns = joblib.load('model_columns.pkl')
    print("✅ Model and tools loaded successfully.")
except Exception as e:
    print(f"❌ Error loading files: {e}")

# 4. Define Input Data Rules (Pydantic & Range Constraints)
class InsuranceInput(BaseModel):
    # Enforced types (int, float, str) and Ranges (gt=greater than, le=less than or equal)
    age: int = Field(..., gt=0, le=100, description="Age (1-100)")
    sex: str = Field(..., pattern="^(male|female)$", description="male or female")
    bmi: float = Field(..., gt=10.0, lt=60.0, description="BMI (10-60)")
    children: int = Field(..., ge=0, le=20, description="Children (0-20)")
    smoker: str = Field(..., pattern="^(yes|no)$", description="yes or no")
    region: str = Field(..., pattern="^(southwest|southeast|northwest|northeast)$", description="US Region")

    class Config:
        schema_extra = {
            "example": {
                "age": 30,
                "sex": "male",
                "bmi": 28.5,
                "children": 1,
                "smoker": "no",
                "region": "southeast"
            }
        }

# 5. The Prediction Endpoint (POST Request)
@app.post("/predict")
def predict_insurance_cost(input_data: InsuranceInput):
    try:
        # Convert input to DataFrame
        data_dict = input_data.dict()
        input_df = pd.DataFrame([data_dict])
        
        # Preprocessing: One-Hot Encoding
        input_encoded = pd.get_dummies(input_df)
        
        # Ensure columns match training data (add missing columns as 0)
        input_encoded = input_encoded.reindex(columns=model_columns, fill_value=0)
        
        # Scale the data
        input_scaled = scaler.transform(input_encoded)
        
        # Predict
        prediction = model.predict(input_scaled)
        
        return {
            "predicted_cost": float(prediction[0]),
            "message": "Prediction successful"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))