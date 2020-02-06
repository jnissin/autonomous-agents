class AlignBehaviour extends Behaviour
{
  private PVector sum;
  private float neighbourDist;

  AlignBehaviour(String name, float multiplier, float neighbourDist)
  {
    super(name, multiplier);
    this.sum = new PVector(0, 0);
    this.neighbourDist = neighbourDist;
  }
  
  AlignBehaviour(String name, float multiplier, float neighbourDist, boolean syncToMusic, int band, float minBandValue, float maxBandValue, float bandSensitivity)
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
        sum.add(other.velocity);
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
