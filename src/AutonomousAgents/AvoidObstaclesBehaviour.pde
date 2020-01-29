class AvoidObstaclesBehaviour extends Behaviour
{
  float[] sensors = {0, 60, 120, 180, 240, 300};

  AvoidObstaclesBehaviour(String name, float multiplier)
  {
    super(name, multiplier);
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  {
    float range = 100;
    PVector desired = new PVector(0, 0);
    float dynamicRange = max(range*(v.velocity.mag()/v.maxSpeed), 20);
    
    for (float s : this.sensors)
    {
      PVector p1 = v.location;
      PVector p2 = PVector.add(p1, v.velocity.copy().normalize().rotate(radians(s)).mult(dynamicRange));
      ObstacleHit oh = obstacleManager.getClosestObstacleHit(p1, p2);
      
      //stroke(color(255, 255, 255, 20));
      //strokeWeight(1);
      //line(p1.x, p1.y, p2.x, p2.y);
      
      if (oh != null)
      {
        // Calculate the desired velocity to target at max speed
        desired = PVector.sub(v.location, oh.hitPoint);
        desired.setMag(v.maxSpeed*map(oh.distance, range, 0, 1., 5.));
        
        //stroke(color(255, 0, 0, 128));
        //strokeWeight(1);
        //line(v.location.x, v.location.y, oh.hitPoint.x, oh.hitPoint.y);
        
        // Reynold's formula for steering force with a cap
        PVector steer = PVector.sub(desired, v.velocity);
        steer.limit(v.maxForce*map(oh.distance, range, 0, 1., 5.));
        return steer;
      }
    }

    return desired;
  }
}
