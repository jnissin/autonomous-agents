class FlowField
{
  PVector[][] field;
  PVector[][] blendField;
  int[][]     blendTime;
  
  int cols, rows;
  int resolution;
  float mutationSpeed;
    
  FlowField(int resolution, float mutationSpeed)
  {
    this.resolution = resolution;
    this.mutationSpeed = mutationSpeed;
    this.cols = width/this.resolution;
    this.rows = height/this.resolution;
    this.field = new PVector[cols][rows];
    this.blendField = new PVector[cols][rows];
    this.blendTime = new int[cols][rows];
        
    for (int i = 0; i < cols; i++)
    {
      for (int j = 0; j < rows; j++)
      {
        this.field[i][j] = new PVector(0, 0);
        this.blendField[i][j] = new PVector(0, 0);
      }
    }    
  }
  
  void update()
  {
    // Declare visitor variables
    PVector visitorFieldVector = new PVector(0, 0);
    
    for (int i = 0; i < cols; i++)
    {
      for (int j = 0; j < rows; j++)
      {
        // Calculate the effect of visitors on the flow field in this position     
        visitorFieldVector = calculateVisitorFieldVector(i, j, visitorFieldVector);        

        // If there were visitors in range the flow field vector is the visitor field vector
        if (visitorFieldVector.x != 0 || visitorFieldVector.y != 0)
        {
          field[i][j].set(visitorFieldVector.x, visitorFieldVector.y);
          blendField[i][j].set(visitorFieldVector.x, visitorFieldVector.y);
          blendTime[i][j] = millis();
        }
        // Otherwise the flow field is a blend between past visitor field vector and Perlin noise flow
        // field
        else
        {
          // Calculate the perlin noise flow field in this position
          float m = 0.2;
          float theta = map(noise(j*m + i*m, j*m, frameCount*this.mutationSpeed), 0, 1, 0, TWO_PI);

          // If there is something to blend with blend between the perlin noise field and the blend
          // field
          if (blendTime[i][j] > 0)
          { 
            float t = constrain((millis() - blendTime[i][j]) / 1000.0, 0.0, 1.0);
            
            // If the blend is complete zero out the blend time
            if (t == 1.0)
            {
              field[i][j].set(cos(theta), sin(theta));
              blendTime[i][j] = 0;
            }
            else
            {
              field[i][j] = PVector.lerp(blendField[i][j], new PVector(cos(theta), sin(theta)), this.smoothstep(0.0, 1.0, t));
            }
          }
          else
          {
            field[i][j].set(cos(theta), sin(theta));
          }
          
          // Normalize the force of the flow field if there are no visitors in range
          field[i][j].normalize(field[i][j]);
        }
      }
    }
  }
  
  PVector calculateVisitorFieldVector(int col, int row, PVector out)
  {
    // Initialize the out vector to zero
    if (out != null)
    {
      out.set(0, 0);
    }
    else
    {
      out = new PVector(0, 0);
    }
    
    int visitorsInRange = 0;

    // Calculate the exact pixel value in the middle of the bin
    int px = (col+1)*this.resolution - this.resolution/2;
    int py = (row+1)*this.resolution - this.resolution/2;
    PVector position = new PVector(px, py);
    
    synchronized(visitorManager.visitors)
    {
      for (Visitor v : visitorManager.visitors)
      {
        if (v.positionInRange(position))
        {
          PVector vf = v.getVectorField(position, this.resolution);
          out = out.add(vf.x, vf.y);
          visitorsInRange += 1;
        }
      }
    }
    
    // Multiply the force of the flow field by the number of visitors in range
    return out.normalize(out).mult(visitorsInRange);
  }
  
  float smoothstep(float edge0, float edge1, float x) {
    // Scale, bias and saturate x to 0..1 range
    x = constrain((x - edge0) / (edge1 - edge0), 0.0, 1.0); 

    // HLSL and GLSL smoothstep by cubic Hermite interpolation
    float x2 = x*x;
    float x3 = x*x*x;
    
    return 3.0*x2 * - 2.0*x3;
  }
  
  void display()
  {
    strokeWeight(2);
    for (int i = 0; i < this.cols; i++)
    {
      for (int j = 0; j < this.rows; j++)
      {
         int len = 2;
         PVector d = field[i][j];
         int x1 = int(constrain(i*this.resolution + this.resolution/2, 0, width));
         int y1 = int(constrain(j*this.resolution + this.resolution/2, 0, height));
         int x2 = int(constrain(x1 + len*d.x, 0, width));
         int y2 = int(constrain(y1 + len*d.y, 0, height));
         color c = color(d.x*255.0, d.y*255.0, 255.0, constrain(100.0 + rmsSum*255.0*1.5, 0.0, 255.0));
         fill(c);
         stroke(c);
         line(x1, y1, -1, x2, y2, -1);
      }
    }
  }
  
  PVector lookup(PVector position)
  {
    int c = int(constrain(position.x/this.resolution, 0, cols-1));
    int r = int(constrain(position.y/this.resolution, 0, rows-1));
    return this.field[c][r].copy();
  }
}
