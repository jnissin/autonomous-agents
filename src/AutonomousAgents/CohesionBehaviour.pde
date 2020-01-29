class CohesionBehaviour extends Behaviour
{
  private PVector sum;

  CohesionBehaviour(String name, float multiplier)
  {
    super(name, multiplier);
    this.sum = new PVector(0, 0);
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  {
    this.sum.set(0, 0);
    float neighbourDist = 50.0;
    int count = 0;
    
    for (Vehicle other : vc.vehicles)
    {
      float d = PVector.dist(v.location, other.location);
      
      if ((d > 0) && (d < neighbourDist))
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
