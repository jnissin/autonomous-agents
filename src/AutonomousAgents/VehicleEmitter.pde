class VehicleEmitter
{
  PVector position;
  float r;
  
  VehicleEmitter(float x, float y, float r)
  {
    this.position = new PVector(x, y);
    this.r = r;
  }
  
  Vehicle emitVehicle(int flockId, color vehicleColor)
  {
    float r2 = this.r * this.r;

    // Pick a random point from within a circle
    float x = random(-r, r);
    float y = random(-1, 1) * sqrt(r2 - x*x);

    // Move the circle center to the emitter position
    float posX = x + this.position.x;
    float posY = y + this.position.y;

    Vehicle v = new Vehicle(flockId, posX, posY, 3.0, 1.5, 0.1, vehicleColor, (int)random(30, 60)*1000);
    return v;
  }
  
  void display()
  {
    fill(color(255, 0, 0, 50));
    circle(this.position.x, this.position.y, r*2);
  }
}
