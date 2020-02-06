class SeparateBehaviour extends Behaviour
{
  private PVector sum;
  private float desiredSeparation;
  
  SeparateBehaviour(String name, float multiplier, float desiredSeparation)
  {
    super(name, multiplier);
    this.desiredSeparation = desiredSeparation;
    this.sum = new PVector(0, 0);
  }
  
  SeparateBehaviour(String name, float multiplier, float desiredSeparation, boolean syncToMusic, int band, float minBandValue, float maxBandValue, float bandSensitivity)
  {
    super(name, multiplier, syncToMusic, band, minBandValue, maxBandValue, bandSensitivity);
    this.desiredSeparation = desiredSeparation;
    this.sum = new PVector(0, 0);
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  {
    // Specify the desired separation such as 20 pixels
    float currentDesiredSeparation = this.desiredSeparation;
    this.sum.set(0, 0);
    int count = 0;
 
    for (Vehicle other : vc.vehicles)
    {
      float d = PVector.dist(v.location, other.location);
      
      if ((d > 0) && (d < currentDesiredSeparation))
      {
        // Calculate a vector pointing away from the other's location
        PVector diff = PVector.sub(v.location, other.location);
        diff.normalize();
        
        // What is the magnitude of the PVector pointing away from the other
        // vehicle? The closer it is the more we should flee. So we divide by
        // the distance to weight it appropriately.
        diff.div(d*d);
        
        sum.add(diff);
        count++;
      }
    }
    
    if (count > 0)
    {
      sum.div(count);
      sum.normalize();
      sum.mult(v.maxSpeed);
      
      PVector steer = PVector.sub(sum, v.velocity);
      steer.limit(v.maxForce);
      return steer;
    }
    
    return sum;
  }
}
