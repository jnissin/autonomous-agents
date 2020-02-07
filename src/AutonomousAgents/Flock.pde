class Flock
{
  int id;
  int size;
  color flockColor;
  ArrayList<Vehicle> vehicles;
  ArrayList<Vehicle> deadVehicles;
  BehaviourSet behaviourSet;
  VehicleEmitter vehicleEmitter;
  
  Flock(int id, int size, color flockColor, BehaviourSet behaviourSet, float emitterPositionX, float emitterPositionY, float emitterRadius)
  {
    this.id = id;
    this.size = size;
    this.flockColor = flockColor;
    this.vehicles = new ArrayList<Vehicle>();
    this.deadVehicles = new ArrayList<Vehicle>();
    this.behaviourSet = behaviourSet;
    this.vehicleEmitter = new VehicleEmitter(emitterPositionX, emitterPositionY, emitterRadius);
    
    this.initialize();
  }
  
  void initialize()
  {
    vehicles.clear();
    
    for (int i = 0; i < this.size; i++)
    {
      vehicles.add(vehicleEmitter.emitVehicle(this.id, this.flockColor));
    }
  }
  
  void update(PVector[] targets)
  {
    VehicleContext vc = new VehicleContext(this.vehicles, targets);
    
    for (Vehicle v : this.vehicles)
    {
      if (v.isAlive())
      {
        vc.vehicles = flockManager.getVehiclesAt(v.location, this.id);
        this.behaviourSet.apply(v, vc, null);
        v.update();
      }
      else
      {
        this.deadVehicles.add(v);
      }
    }
    
    if (this.vehicles.size() < this.size)
    {
      this.vehicles.add(this.vehicleEmitter.emitVehicle(this.id, this.flockColor));
    }
    
    // Remove dead vehicles from flock
    this.vehicles.removeAll(deadVehicles);
    
    // Reset dead vehicles
    this.deadVehicles.clear();
  }
  
  void display()
  {
    for (Vehicle v : this.vehicles)
    {
      v.display();
    }
    
    this.vehicleEmitter.display();
  }
  
  void setColor(color c)
  {
    this.flockColor = c;
    
    for (Vehicle v : this.vehicles)
    {
      v.setColor(c);
    }
  }
  
  @Override
  String toString() {
    return String.format("%d", this.id);
  }
}
