class FlockManager
{
  ArrayList<Flock> flocks;
  int numInitialFlocks;
  int initialFlockSize;
  int resolution;
  ArrayList<Vehicle>[][][] vehicleGrid;

  FlockManager(int numInitialFlocks, int initialFlockSize)
  {
    this.flocks = new ArrayList<Flock>();
    this.numInitialFlocks = numInitialFlocks;
    this.initialFlockSize = initialFlockSize;

    this.resolution = 200;
    int columns = width/this.resolution;
    int rows = height/this.resolution;
    this.vehicleGrid = new ArrayList[this.numInitialFlocks][columns][rows];
    
    for (int i = 0; i < this.numInitialFlocks; i++)
    {
      for (int c = 0; c < columns; c++)
      {
        for (int r = 0; r < rows; r++)
        {
          this.vehicleGrid[i][c][r] = new ArrayList<Vehicle>();
        }
      }
    }
  }

  void initialize()
  {
    // Initialize flocks
    flocks.clear();
    
    for (int i = 0; i < this.numInitialFlocks; i++)
    {
      BehaviourSet bs = new BehaviourSet();
      bs.addBehaviour(new FollowFlowFieldBehaviour("followFlowField", random(0.8, 1.2), field));
      bs.addBehaviour(new SeparateBehaviour("separate", random(1.3, 1.7), 40.0));
      bs.addBehaviour(new AlignBehaviour("align", random(0.8, 1.2), 50.0));
      bs.addBehaviour(new CohesionBehaviour("cohesion", random(0.8, 1.2), 50.0, false, 0, 1, -1, 0.5));
      bs.addBehaviour(new ArriveBehaviour("arriveToVisitor", random(0, 1) < 0.5 ? -0.5 : 0.2, false, 300.0, 100.0));
      bs.addBehaviour(new AvoidObstaclesBehaviour("avoidObstacles", 1.0));
      
      this.addFlock(i, this.initialFlockSize, selectedTheme.getNextThemeColor(), bs);
    }
  }

  void update()
  {
    if (frameCount%5 == 0)
    {
      updateVehicleGrid();
    }
    
    // Check current visitor positions
    int numVisitors = visitorManager.visitors.size();
    PVector[] targets = new PVector[numVisitors];   
    
    synchronized (visitorManager.visitors)
    {
      for (int i = 0; i < numVisitors; i++)
      {
        targets[i] = visitorManager.visitors.get(i).location;
      }
    }

    for (Flock f : flocks)
    {
      f.update(targets);
    }
  }

  void display()
  {
    for (Flock f : flocks)
    {
      f.display();
    }
    
    /*
    for (int c = 0; c < width/this.resolution; c++)
    {
      stroke(255);
      strokeWeight(1);
      line(c*this.resolution, 0, c*this.resolution, height);
    }
    
    for (int r = 0; r < height/this.resolution; r++)
    {
      stroke(255);
      strokeWeight(1);
      line(0, r*this.resolution, width, r*this.resolution);
    }
    */
  }

  void addFlock(int id, int size, color flockColor, BehaviourSet bs)
  {
      this.flocks.add(new Flock(id, size, flockColor, bs));
  }

  void removeFlock(int id)
  {
    // TODO
  }

  void updateVehicleGrid()
  {
    int cols = width/this.resolution;
    int rows = height/this.resolution;

    for (int i = 0; i < this.numInitialFlocks; i++)
    {
      for (int c = 0; c < cols; c++)
      {
        for (int r = 0; r < rows; r++)
        {
          this.vehicleGrid[i][c][r].clear();
        }
      }
    }

    // Update vehicle grid
    for (Flock f : flocks)
    {
      for (Vehicle v : f.vehicles)
      {
        int c = constrain((int)v.location.x / this.resolution, 0, cols-1);
        int r = constrain((int)v.location.y / this.resolution, 0, rows-1);
        this.vehicleGrid[f.id][c][r].add(v);
      }
    }
  }

  ArrayList<Vehicle> getVehiclesAt(PVector position, int flockId)
  {
    int cols = width/this.resolution;
    int rows = height/this.resolution;
    int c = constrain((int)position.x / this.resolution, 0, cols-1);
    int r = constrain((int)position.y / this.resolution, 0, rows-1);
    return this.vehicleGrid[flockId][c][r];
  }
}
