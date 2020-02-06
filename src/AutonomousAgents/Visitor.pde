enum VisitorType
{
  MOUSE,
  TUIO
}

class Visitor
{
  String id;
  PVector location;
  float r;
  float vfr;
  boolean active;
  boolean alive;
  int vfType;
  VisitorType type;
  int createdAt;
  int removedAt;
  
  color activeColor = color(255);
  color inactiveColor = color(180);//selectedTheme.backgroundColor; //color(180);
  
  Visitor(String id, VisitorType type, PVector location, float r, float vfr)
  {
    this.id = id;
    this.location = location;
    this.r = r;
    this.vfr = vfr;
    this.vfType = round(random(0, 1));
    this.type = type;
    this.alive = true;
    this.createdAt = millis();
    this.removedAt = -1;
  }
  
  void update()
  {
    if (this.active && this.type == VisitorType.MOUSE)
    {
      this.location.set(mouseX, mouseY);
    }
  }
  
  void display()
  {
    noStroke();
    fill(this.active ? this.activeColor : this.inactiveColor);
    circle(this.location.x, this.location.y, this.r);
  }
  
  boolean isInteractable()
  {
    return this.alive && this.lifeTime() > Config.visitorAddedDelay;
  }
  
  int lifeTime()
  {
    return millis() - this.createdAt;
  }
  
  int removedTime()
  {
    if (this.removedAt <= 0)
    {
      return 0;
    }
    
    return millis() - this.removedAt;
  }
  
  boolean positionInRange(PVector position)
  {
    if (this.isInteractable() && PVector.dist(position, this.location) < this.vfr)
    {
      return true;
    }
    
    return false;
  }
  
  PVector getVectorField(PVector position, int vfResolution)
  {
    if (this.isInteractable())
    {
      if (positionInRange(position))
      {
        if (this.vfType == 0)
        {
          float row = position.y/vfResolution;
          float col = position.x/vfResolution;
          return new PVector(-(row - this.location.y/vfResolution), (col - this.location.x/vfResolution));
        }
        else if (this.vfType == 1)
        {
          // Calculate an arbitrary vector field centered around a point
          // Counter the effect of the vector field resolution resolution
          
          // Center around visitor position
          float x = position.x - this.location.x;
          float y = position.y - this.location.y;
          
          // Use the vector field function
          float vx = ((x*x) - (y*y) - 4);
          float vy = (2*x*y);
          
          // Scale back to our resolution and normalize
          return new PVector(vx/vfResolution, vy/vfResolution);
        }
      }
    }
    
    return new PVector(0.0, 0.0);
  }
}
