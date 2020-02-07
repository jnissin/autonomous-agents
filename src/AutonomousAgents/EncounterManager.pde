import java.util.Set;
import java.util.HashSet;

class Encounter
{ 
  String id;
  PImage graphic;
  float sMin;
  float sMax;
  float dMin;
  float dMax;
  Visitor v1;
  Visitor v2;
  Obstacle obstacle;
  
  int createdAt;
  float x;
  float y;
  float d;
  float s;
  
  Encounter(String id, PImage graphic, float sMin, float sMax, float dMin, float dMax, Visitor v1, Visitor v2)
  {
    this.id = id;
    this.graphic = graphic;
    this.sMin = sMin;
    this.sMax = sMax;
    this.dMin = dMin;
    this.dMax = dMax;
    this.v1 = v1;
    this.v2 = v2;
    
    // TODO: Fix problem with disappearing visitors
    this.createdAt = millis();
    this.x = (this.v1.location.x + this.v2.location.x) * 0.5;
    this.y = (this.v1.location.y + this.v2.location.y) * 0.5;
    this.d = PVector.dist(v1.location, v2.location);
    this.s =  map(this.d, this.dMin, this.dMax, this.sMax, this.sMin);
    
    this.obstacle = obstacleManager.addCircleObstacle(this.x, this.y, this.s/2, true);
  }
 
  void update()
  {
    this.x = (this.v1.location.x + this.v2.location.x) * 0.5;
    this.y = (this.v1.location.y + this.v2.location.y) * 0.5;
    this.d = PVector.dist(v1.location, v2.location);
    this.s =  map(this.d, this.dMin, this.dMax, this.sMax, this.sMin);
    this.obstacle.setPosition(this.x, this.y);
    this.obstacle.setDimensions(this.s/2, this.s/2);
  }
  
  void display()
  {
    float d = PVector.dist(v1.location, v2.location);
    float alpha = map(this.d, this.dMin, this.dMax, 255, 0);
    color lineColor = color(255, 255, 255, alpha/2.0);
    
    strokeWeight(map(d, this.dMin, this.dMax, 3, 0));
    stroke(lineColor);
    noFill();
    line(v1.location.x, v1.location.y, -1, v2.location.x, v2.location.y, -1);

    imageMode(CENTER);
    pushMatrix();
    translate(x, y, 1);
    rotate((millis()-this.createdAt) * 0.0002);
    image(this.graphic, 0, 0, this.s, this.s);
    popMatrix();
    imageMode(CORNER);
  }
  
  void dispose()
  {
    obstacleManager.removeObstacle(this.obstacle);
  }
  
  boolean isActive()
  {
    if (v1 != null && v1.isInteractable() && v2 != null && v2.isInteractable())
    {
      return PVector.dist(v1.location, v2.location) < dMax;
    }
    
    return false;
  }
}

class EncounterManager
{  
  ArrayList<Encounter> encounters;
  Set<String> encounterSet;
  ArrayList<PImage> encounterGraphics;
  
  EncounterManager()
  {
    this.encounters = new ArrayList<Encounter>();
    this.encounterSet = new HashSet<String>();
    this.encounterGraphics = new ArrayList<PImage>();
    
    this.encounterGraphics.add(loadImage("media/peach-green-flower1.png"));
    this.encounterGraphics.add(loadImage("media/peach-green-flower2.png"));
    this.encounterGraphics.add(loadImage("media/peach-green-flower3.png"));
  }
  
  void update()
  {
    synchronized (visitorManager.visitors)
    {
      for (int i = 0; i < visitorManager.visitors.size(); i++)
      {
        Visitor v1 = visitorManager.visitors.get(i);
        
        for (int j = i + 1; j < visitorManager.visitors.size(); j++)
        {
          Visitor v2 = visitorManager.visitors.get(j);

          if (v1.isInteractable() && v2.isInteractable())
          {
            if (!encounterSet.contains(getEncounterId(v1, v1)) && v1.location.dist(v2.location) < Config.encounterDistanceMax)
            {
              this.addEncounter(v1, v2);
            }
          }
        }
      }
    }
    
    for (int i = this.encounters.size()-1; i >= 0; i--)
    {
      Encounter e = this.encounters.get(i);
      
      if (e.isActive())
      {
        e.update();
      }
      else
      {
        this.removeEncounter(e);
      }
    }
  }
  
  void display()
  {
    for (Encounter e : this.encounters)
    {
      e.display();
    }
  }
  
  String getEncounterId(Visitor v1, Visitor v2)
  {
    return v1.id + "->" + v2.id;
  }
  
  void addEncounter(Visitor v1, Visitor v2)
  {
    String encounterId = getEncounterId(v1, v2);
    
    if (encounterSet.contains(encounterId))
    {
      return;
    }
    
    PImage graphic = this.encounterGraphics.get(round(random(0, this.encounterGraphics.size()-1)));    
    this.encounterSet.add(encounterId);
    this.encounters.add(new Encounter(encounterId, graphic, Config.encounterGraphicSizeMin, Config.encounterGraphicSizeMax, Config.encounterDistanceMin, Config.encounterDistanceMax, v1, v2));
  }
  
  void removeEncounter(Encounter encounter)
  {
    if (!this.encounterSet.contains(encounter.id))
    {
      return;
    }
    
    this.encounterSet.remove(encounter.id);
    this.encounters.remove(encounter);
    
    encounter.dispose();
  }
}
