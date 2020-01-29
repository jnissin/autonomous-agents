class AlignBehaviour extends Behaviour
{
  private PVector sum;

  AlignBehaviour(String name, float multiplier)
  {
    super(name, multiplier);
    this.sum = new PVector(0, 0);
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  {
    this.sum.set(0, 0);
    int count = 0;

    float neighbourDist = 50.0;
    
    for (Vehicle other : vc.vehicles)
    {
      float d = PVector.dist(v.location, other.location);
      
      if ((d > 0) && (d < neighbourDist))
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
