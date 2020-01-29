abstract class Behaviour
{
  String name;
  float multiplier;
  
  Behaviour(String name, float multiplier)
  {
    this.name = name;
    this.multiplier = multiplier;
  }
  
  void apply(Vehicle v, VehicleContext vc)
  {
    PVector force = this.getForce(v, vc);
    force.mult(this.multiplier);
    v.applyForce(force);
  }
  
  abstract PVector getForce(Vehicle v, VehicleContext vc);
}
