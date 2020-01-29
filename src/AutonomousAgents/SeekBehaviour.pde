class SeekBehaviour extends Behaviour
{
  SeekBehaviour(String name, float multiplier)
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
