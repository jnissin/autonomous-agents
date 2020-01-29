class VehicleContext
{
  ArrayList<Vehicle> vehicles;
  PVector[] targets;
  
  VehicleContext(ArrayList<Vehicle> vehicles, PVector[] targets)
  {
    this.vehicles = vehicles;
    this.targets = targets;
  }
  
  PVector getClosestTarget(PVector p)
  {
    // If there are no targets
    if (this.targets == null || this.targets.length == 0)
    {
      return null;
    }
    
    PVector closestTarget = this.targets[0];
    float distToClosestTarget = PVector.dist(this.targets[0], p);
    
    for (PVector t : this.targets)
    {
      if (PVector.dist(t, p) < distToClosestTarget)
      {
        closestTarget = t;
      }
    }
    
    return closestTarget;
  }
}
