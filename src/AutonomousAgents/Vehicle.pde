class Vehicle
{
  int flockId;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxSpeed;      // Current maximum
  float maxSpeedStore; // A value for storing the real non-ramped maximum
  float maxSpeedMult;
  float maxForce;      // Current maximum
  float maxForceStore; // A value for storing the real non-ramped maximum
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
    this.maxSpeedStore = maxSpeed;
    this.maxSpeed = maxSpeed;
    this.maxSpeedMult = 1.0;
    this.maxForceStore = maxForce;
    this.maxForce = maxForce;
    this.vehicleColor = vehicleColor;
    this.lifeTime = lifeTime;
    this.remainingLifeTime = lifeTime;
    this.birthTime = millis();
    this.trail = new Trail(12, this.vehicleColor);
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
    
    // Ramp up max speed and max force
    this.maxSpeed = getRampedValue(this.getUsedLife(), 0.1*this.maxSpeedStore, this.maxSpeedStore, 0.3, 0.05);
    this.maxForce = getRampedValue(this.getUsedLife(), 0.1*this.maxForceStore, this.maxForceStore, 0.3, 0.05);
    
    // Update position, velocity and acceleration
    this.velocity.add(this.acceleration.mult(deltaTime));
    this.velocity.limit(this.maxSpeed*this.maxSpeedMult);
    this.location.add(this.velocity.mult(deltaTime));
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
    this.trail.addVertex(this.location.x, this.location.y);
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
  
  float getUsedLife()
  {
    return max((float)(this.lifeTime-this.remainingLifeTime)/this.lifeTime, 0);
  }
  
  void display()
  {
    // Ramp up the alpha from min to max during ramp up period
    // Ramp down the alpha from max to min during ramp down period
    float alpha = getRampedValue(this.getUsedLife(), 10, 255, 0.3, 0.05);
    float currentRadius = getRampedValue(this.getUsedLife(), this.r*0.3, this.r*1.5, 0.3, 0.0);

    // Draw the trail
    this.trail.display(currentRadius, alpha);
    
    fill(this.vehicleColor, alpha);
    noStroke();
    circle(this.location.x, this.location.y, currentRadius);
    
    // Vehicle is a triangle pointing in the direction of velocity; since it is drawn pointing up, we rotate it an additional 90 degrees.
    /*float theta = this.velocity.heading() + PI/2;
    fill(this.vehicleColor, alpha);
    strokeWeight(0);
    stroke(0);
    noStroke();

    pushMatrix();
    translate(this.location.x, this.location.y);
    rotate(theta);
    float currentRadius = getRampedValue(this.getUsedLife(), this.r*0.3, this.r, 0.3, 0.0);
    triangle(0, -currentRadius*2, -currentRadius, currentRadius*2, currentRadius, currentRadius*2);
    popMatrix();*/
  }
}
