float getRampedValue(float v, float vMin, float vMax, float rampUpPeriod, float rampDownPeriod)
{
 float rValue = 0.0;
 
 // Constrain the value to interval [0, 1]
 v = constrain(v, 0, 1);
 
 // If we are within the ramp up period
 if (rampUpPeriod > 0.0 && v <= rampUpPeriod)
 {
   rValue = map(v, 0, rampUpPeriod, vMin, vMax);
 }
 // If we are within the ramp down period
 else if (rampDownPeriod > 0.0 && v >= 1.0 - rampDownPeriod)
 {
   rValue = map(v, 1.0 - rampDownPeriod, 1.0, vMax, vMin);
 }
 // Otherwise we use the maximum
 else
 {
   rValue = vMax;
 }
 
 return constrain(rValue, vMin, vMax);
}
