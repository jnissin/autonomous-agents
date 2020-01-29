class Vehicle
{
  int flockId;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxSpeed;
  float maxForce;
  color vehicleColor;
  Trail trail;
  
  int lifeTime;
  int remainingLifeTime;
  int birthTime;
  
  
  Vehicle(int flockId, float x, float y, float r, float maxSpeed, float maxForce, color vehicleColor, int lifeTime)
  {
    this.flockId = flockId;
    this.acceleration = new PVector(0, 0);
    this.velocity = new PVector(0, 0);
    this.location = new PVector(x, y);
    this.r = r;
    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;
    this.vehicleColor = vehicleColor;
    this.lifeTime = lifeTime;
    this.remainingLifeTime = lifeTime;
    this.birthTime = millis();
    this.trail = new Trail(8, this.vehicleColor);
  }
  
  void update()
  {
    // First update is determined as the birth time
    if (birthTime == 0)
    {
      birthTime = millis();
    }

    // Update remaining life time
    this.remainingLifeTime = lifeTime - (millis() - this.birthTime);
    
    // Update position, velocity and acceleration
    this.velocity.add(this.acceleration);
    // TODO: Fix this, the max speed must be limited
    //this.velocity.limit(this.maxSpeed);
    this.location.add(this.velocity);
    this.acceleration.mult(0);
    
    // Use modulus arithmetic to keep the vehicle within screen bounds
    if (this.location.x < 0)
    {
      this.trail.reset();
      this.location.add(width, 0);
    }
    else if (this.location.x > width)
    {
      this.trail.reset();
      this.location.sub(width, 0);
    }
    
    if (this.location.y < 0)
    {
      this.trail.reset();
      this.location.add(0, height);
    }
    else if (this.location.y > height)
    {
      this.trail.reset();
      this.location.sub(0, height);
    }
    
    // Update the trail vertices every n frames (otherwise this gets heavy)
    if (frameCount%5 == 0)
    {
      this.trail.addVertex(this.location.x, this.location.y);
    }
  }
  
  void setColor(color c)
  {
    this.vehicleColor = c;
    this.trail.trailColor = c;
  }
  
  void applyForce(PVector force)
  {
    this.acceleration.add(force);
  }
  
  boolean isAlive()
  {
    return this.remainingLifeTime > 0;
  }
  
  private void stayWithinWalls()
  {
    // If we are within a distance d of a wall, move at maximum speed
    // in the opposite direction of the wall
    int d = 50;
    
    if (location.x < d || location.x > width - d)
    {
      // Determine the sign of the required movement
      int sign = location.x < d ? 1 : -1;
      
      // Zero any existing acceleration
      this.acceleration.mult(0);
      
      // Calculate new steering
      PVector desired = new PVector(sign * this.maxSpeed, this.velocity.y);
      PVector steer = PVector.sub(desired, this.velocity);
      steer.limit(this.maxForce);
      applyForce(steer);
    }
    
    if (location.y < d || location.y > height - d)
    {
      // Determine the sign of the required movement
      int sign = location.x < d ? 1 : -1;
      
      // Zero any existing acceleration
      this.acceleration.mult(0);
      
      // Calculate new steering
      PVector desired = new PVector(this.velocity.x, sign * this.maxSpeed);
      PVector steer = PVector.sub(desired, this.velocity);
      steer.limit(this.maxForce);
      applyForce(steer);
    }
  }
  
  void display()
  {
    // Draw the trail
    this.trail.display();
    
    // Vehicle is a triangle pointing in the direction of velocity; since it is drawn pointing up, we rotate it an additional 90 degrees.
    float theta = this.velocity.heading() + PI/2;
    float alpha = 255.0;
    fill(this.vehicleColor, alpha);
    strokeWeight(0);
    stroke(0);
    noStroke();

    pushMatrix();
    translate(this.location.x, this.location.y);
    rotate(theta);
    triangle(0, -this.r*2, -this.r, this.r*2, this.r, this.r*2);
    popMatrix();
  }
}
