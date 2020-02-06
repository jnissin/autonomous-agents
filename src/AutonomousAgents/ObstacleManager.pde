abstract class BoundingShape
{
	BoundingShape()
	{
	}

	abstract PVector lineIntersect(PVector p1, PVector p2);
  abstract void setPosition(float x, float y);
  abstract void setDimensions(float w, float h);
}

class BoundingBox extends BoundingShape
{
	float x;
	float y;
	float w;
	float h;

	PVector tl;
	PVector tr;
	PVector bl;
	PVector br;

	BoundingBox(float x, float y, float w, float h)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;

		this.tl = new PVector(x, y);
		this.tr = new PVector(x+w, y);
		this.bl = new PVector(x, y+h);
		this.br = new PVector(x+w, y+h);
	}

	PVector lineIntersect(PVector p1, PVector p2)
	{
		PVector tIntersect = this.lineLineIntersect(p1, p2, tl, tr);
		PVector rIntersect = this.lineLineIntersect(p1, p2, tr, br);
		PVector bIntersect = this.lineLineIntersect(p1, p2, bl, br);
		PVector lIntersect = this.lineLineIntersect(p1, p2, tl, bl);

		PVector[] intersections = {tIntersect, rIntersect, bIntersect, lIntersect};
		float closest = Float.MAX_VALUE;
		PVector closestIntersection = null;

		for (PVector intersection : intersections)
		{
			if (intersection != null)
			{
				float d = PVector.dist(intersection, p1);
				if (d < closest)
				{
					closest = d;
					closestIntersection = intersection;
				}
			}
		}

		return closestIntersection;
	}

  void setPosition(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
  
  void setDimensions(float w, float h)
  {
    this.w = w;
    this.h = h;
  }

	private PVector lineLineIntersect(PVector p1, PVector p2, PVector p3, PVector p4)
	{
		float x1 = p1.x;
		float x2 = p2.x;
		float x3 = p3.x;
		float x4 = p4.x;
		float y1 = p1.y;
		float y2 = p2.y;
		float y3 = p3.y;
		float y4 = p4.y;

		float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
		float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

		if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1)
		{
			float ix = x1 + (uA * (x2-x1));
			float iy = y1 + (uA * (y2-y1));
			return new PVector(ix, iy);
		}

		return null;
	}

}

class BoundingCircle extends BoundingShape
{
	PVector position;
	float r;

	BoundingCircle(float x, float y, float r)
	{
		this.position = new PVector(x, y);
		this.r = r;
	}

	PVector lineIntersect(PVector p1, PVector p2)
	{
		float baX = p2.x - p1.x;
    float baY = p2.y - p1.y;
    float caX = this.position.x - p1.x;
    float caY = this.position.y - p1.y;

    float a = baX * baX + baY * baY;
    float bBy2 = baX * caX + baY * caY;
    float c = caX * caX + caY * caY - this.r * this.r;

    float pBy2 = bBy2 / a;
    float q = c / a;

    float disc = pBy2 * pBy2 - q;

    if (disc < 0)
    {
        return null;
    }

    // if disc == 0 ... dealt with later
    float tmpSqrt = sqrt(disc);
    float abScalingFactor1 = -pBy2 + tmpSqrt;
    float abScalingFactor2 = -pBy2 - tmpSqrt;

    PVector ip1 = new PVector(p1.x - baX * abScalingFactor1, p1.y - baY * abScalingFactor1);
    
    // abScalingFactor1 == abScalingFactor2
    if (disc == 0)
    {
        return ip1;
    }

    PVector ip2 = new PVector(p1.x - baX * abScalingFactor2, p1.y - baY * abScalingFactor2);
    
    if (PVector.dist(p1, ip1) < PVector.dist(p1, ip2))
    {
    	return ip1;
    }

  	return ip2;
	}

  void setPosition(float x, float y)
  {
    this.position.set(x, y);
  }
  
  void setDimensions(float r, float _)
  {
    this.r = r;
  }
}

class Obstacle
{
  PVector originalPosition;
	PVector position;
	PShape shape;
	BoundingShape boundingShape;
  boolean hidden;

  Obstacle(PVector position, PShape shape, BoundingShape boundingShape, boolean hidden)
  {
    this.originalPosition = position.copy();
    this.position = position;
    this.shape = shape;
    this.boundingShape = boundingShape;
    this.hidden = hidden;
  }

	Obstacle(PVector position, PShape shape, BoundingShape boundingShape)
	{
    this(position, shape, boundingShape, false);
	}

	void display()
	{
    if (!this.hidden)
    {
      // If this shape has been moved from it's original position
      // TODO: fix scale
      if (this.position.x != this.originalPosition.x || this.position.y != this.originalPosition.y)
      {
        this.shape.resetMatrix();
        this.shape.translate(this.position.x - this.originalPosition.x, this.position.y - this.originalPosition.y);
      }
      
      shape(this.shape);
    }
	}

  void setPosition(float x, float y)
  {
    this.position.set(x, y);
    this.boundingShape.setPosition(x, y);
  }
  
  void setDimensions(float w, float h)
  {
    this.boundingShape.setDimensions(w, h);
  }

	PVector lineIntersect(PVector p1, PVector p2)
	{
		return this.boundingShape.lineIntersect(p1, p2);
	}
}

class ObstacleHit
{
	Obstacle obstacle;
	PVector hitPoint;
  float distance;

	ObstacleHit(Obstacle obstacle, PVector hitPoint, float distance)
	{
		this.obstacle = obstacle;
		this.hitPoint = hitPoint;
    this.distance = distance;
	}
}

class ObstacleManager
{
	ArrayList<Obstacle> obstacles;

	ObstacleManager()
	{
		this.obstacles = new ArrayList<Obstacle>();
    //this.addRectangleObstacle(width/2, height/2, 250, 20, false);
    //this.addRectangleObstacle(width/2, height/2, 20, 250, false);
    this.addCircleObstacle(450, height-300, 50, false);
    this.addCircleObstacle(width-450, 300, 50, false);
    //this.addCircleObstacle(width/2, height-200, 50, false);
	}

	void display()
	{
		for (Obstacle o : this.obstacles)
		{
			o.display();
		}
	}

  Obstacle addRectangleObstacle(float x, float y, float w, float h, boolean hidden)
  {
    float rcx = x - w/2;
    float rcy = y - h/2;
    
    PShape box = createShape(RECT, rcx, rcy, w, h);
    BoundingBox boundingBox = new BoundingBox(rcx, rcy, w, h);
    Obstacle obstacle = new Obstacle(new PVector(x, y), box, boundingBox, hidden);
    this.obstacles.add(obstacle);
    return obstacle;
  }
  
  Obstacle addCircleObstacle(float x, float y, float r, boolean hidden)
  {
    //PShape circle = createShape(ELLIPSE, x, y, r*2, r*2);
    PShape box = createShape(RECT, x-(r*2), y-(r*2), r*2, r*2);
    box.setStroke(false);
    box.setTexture(loadImage("media/peach-green-flower3.png"));
    BoundingCircle boundingCircle = new BoundingCircle(x, y, r);
    Obstacle obstacle = new Obstacle(new PVector(x, y), box, boundingCircle, hidden);
    this.obstacles.add(obstacle);
    return obstacle;
  }
  
  void removeObstacle(Obstacle obstacle)
  {
    this.obstacles.remove(obstacle);
  }

	ObstacleHit getClosestObstacleHit(PVector p1, PVector p2)
	{
		float range = PVector.dist(p1, p2);
		Obstacle closestObstacle = null;
		PVector closestIntersect = null;
		float closestDistance = Float.MAX_VALUE;

		for (Obstacle o : this.obstacles)
		{
			PVector intersect = o.lineIntersect(p1, p2);

			if (intersect != null)
			{
				float d = PVector.dist(p1, intersect);

				if (d < range && d < closestDistance)
				{
					closestObstacle = o;
					closestIntersect = intersect;
					closestDistance = d;
				}
			}
		}

		if (closestObstacle != null)
		{
			return new ObstacleHit(closestObstacle, closestIntersect, closestDistance);
		}

		return null;
	}
}
