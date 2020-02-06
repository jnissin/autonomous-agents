class CohesionBehaviour extends Behaviour
{
  private float neighbourDist;
  private PVector sum;

  CohesionBehaviour(String name, float multiplier, float neighbourDist)
  {
    super(name, multiplier);
    this.neighbourDist = neighbourDist;
    this.sum = new PVector(0, 0);
  }
  
  CohesionBehaviour(String name, float multiplier, float neighbourDist, boolean syncToMusic, int band, float minBandValue, float maxBandValue, float bandSensitivity)
  {
    super(name, multiplier, syncToMusic, band, minBandValue, maxBandValue, bandSensitivity);
    this.neighbourDist = neighbourDist;
    this.sum = new PVector(0, 0);
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  {
    float currentNeighbourDist = this.neighbourDist;
    this.sum.set(0, 0);
    int count = 0;
    
    for (Vehicle other : vc.vehicles)
    {
      float d = PVector.dist(v.location, other.location);
      
      if ((d > 0) && (d < currentNeighbourDist))
      {
        this.sum.add(other.location);
        count++;
      }
    }
    
    if (count > 0)
    {
      this.sum.div(count);
      return this.seek(v, sum);
    }
    
    return sum;
  }
  
  private PVector seek(Vehicle v, PVector target)
  {
    // Calculate the desired velocity to target at max speed
    PVector desired = PVector.sub(target, v.location);
    desired.normalize();
    desired.mult(v.maxSpeed);
    
    // Reynold's formula for steering force with a cap
    PVector steer = PVector.sub(desired, v.velocity);
    steer.limit(v.maxForce);  
    
    return steer; 
  }
}
