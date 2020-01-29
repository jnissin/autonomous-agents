class ArriveBehaviour extends Behaviour
{
  ArriveBehaviour(String name, float multiplier)
  {
    super(name, multiplier);
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  { 
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
    
    // If we are closer than d pixels - set the magnitude according to how close we are
    if (d < 100)
    {
      float m = map(d, 0, 100, 0, v.maxSpeed);
      desired.mult(m);
    }
    
    // Reynold's formula for steering force with a cap
    PVector steer = PVector.sub(desired, v.velocity);
    steer.limit(v.maxForce);
    
    return steer;
  }
}
