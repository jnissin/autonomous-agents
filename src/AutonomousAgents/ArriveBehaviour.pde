class ArriveBehaviour extends Behaviour
{
  private boolean global;
  private float senseRadius;
  private float rampDownDistance;
  
  
  ArriveBehaviour(String name, float multiplier, boolean global, float senseRadius, float rampDownDistance)
  {
    super(name, multiplier);
    this.global = global;
    this.senseRadius = senseRadius;
    this.rampDownDistance = rampDownDistance;
  }
  
  ArriveBehaviour(String name, float multiplier, boolean global, float senseRadius, float rampDownDistance, boolean syncToMusic, int band, float minBandValue, float maxBandValue, float bandSensitivity)
  {
    super(name, multiplier, syncToMusic, band, minBandValue, maxBandValue, bandSensitivity);
    this.global = global;
    this.senseRadius = senseRadius;
    this.rampDownDistance = rampDownDistance;
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  { 
    float currentRampDownDistance = this.rampDownDistance;
    
    // Select the closest target
    PVector target = vc.getClosestTarget(v.location);
   
    // If there are no targets
    if (target == null)
    {
      return new PVector(0, 0);
    }
    
    PVector desired = PVector.sub(target, v.location);

    // Get the distance to the target
    float d = desired.mag();
    
    if (!this.global && d > senseRadius)
    {
      return new PVector(0, 0);
    }
    
    // If we are closer than d pixels - set the magnitude according to how close we are
    if (d < currentRampDownDistance)
    {
      float m = map(d, 0, currentRampDownDistance, 0, v.maxSpeed);
      desired.mult(m);
    }
    
    // Reynold's formula for steering force with a cap
    PVector steer = PVector.sub(desired, v.velocity);
    steer.limit(v.maxForce);
    
    return steer;
  }
}
