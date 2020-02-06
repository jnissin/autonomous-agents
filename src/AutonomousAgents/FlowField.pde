class FlowField
{
  PVector[][] field;
  PVector[][] blendField;
  int[][]     blendTime;
  float[][]   previousAngle;
  
  int cols;
  int rows;
  int resolution;
  float vectorLength;
  float mutationSpeed;
  
  PShape vectors;
  
  FlowField(int resolution, float vectorLength, float mutationSpeed)
  {
    this.resolution = resolution;
    this.vectorLength = vectorLength;
    this.mutationSpeed = mutationSpeed;
    this.cols = width/this.resolution;
    this.rows = height/this.resolution;
    this.field = new PVector[cols][rows];
    this.blendField = new PVector[cols][rows];
    this.blendTime = new int[cols][rows];
    this.vectors = createShape(PShape.GROUP);
    this.previousAngle = new float[cols][rows];
    
    for (int i = 0; i < cols; i++)
    {
      for (int j = 0; j < rows; j++)
      {
        this.field[i][j] = new PVector(0, 0);
        this.blendField[i][j] = new PVector(0, 0);
        
        float halfLen = this.vectorLength/2;
        PVector d = field[i][j];
        float cx = i*this.resolution + this.resolution/2;
        float cy = j*this.resolution + this.resolution/2;
        float x1 = int(constrain(cx - halfLen*d.x, 0, width));
        float y1 = int(constrain(cy - halfLen*d.y, 0, height));
        float x2 = int(constrain(cx + halfLen*d.x, 0, width));
        float y2 = int(constrain(cy + halfLen*d.y, 0, height));
        
        PShape part = createShape();
        part.beginShape(LINES);
        part.noFill();
        part.noTint();
        part.strokeWeight(2);
        part.stroke(color(255));
        part.normal(0, 0, 1);
        part.vertex(x1, y1, -1);
        part.vertex(x2, y2, -1);
        part.endShape();
        vectors.addChild(part);
      }
    }
  }
  
  void update()
  {
    // Declare visitor variables
    PVector visitorFieldVector = new PVector(0, 0);
    
    // Calculate current color values including alpha
    int baseAlpha = int(constrain(audioManager.getAmplitude()*180.0, 64.0, 180.0));
    color c1 = color(red(selectedTheme.vectorFieldColors[0]), green(selectedTheme.vectorFieldColors[0]), blue(selectedTheme.vectorFieldColors[0]));
    color c2 =  color(red(selectedTheme.vectorFieldColors[1]), green(selectedTheme.vectorFieldColors[1]), blue(selectedTheme.vectorFieldColors[1]));
    
    for (int i = 0; i < cols; i++)
    {
      for (int j = 0; j < rows; j++)
      {
        float alpha = baseAlpha;
        
        // Calculate the effect of visitors on the flow field in this position     
        visitorFieldVector = calculateVisitorFieldVector(i, j, visitorFieldVector);        
    
        // If there were visitors in range the flow field vector is the visitor field vector
        if (visitorFieldVector.x != 0 || visitorFieldVector.y != 0)
        {
          alpha = 255;
          
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
            alpha = 255;
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
        
        // Update the stroke
        PShape part = this.vectors.getChild(i*rows + j);
        float a = atan2(field[i][j].y, field[i][j].x);
        float v = map(a, -PI, PI, 0, 1);
        color c = lerpColor(c1, c2, v);
        part.setStroke(color(red(c), green(c), blue(c), alpha));

        if (frameCount < 2 || abs(a - this.previousAngle[i][j]) > 0.174)
        {
          float halfLen = this.vectorLength/2;
          PVector d = field[i][j];
          float cx = i*this.resolution + this.resolution/2;
          float cy = j*this.resolution + this.resolution/2;
          float x1 = int(constrain(cx - halfLen*d.x, 0, width));
          float y1 = int(constrain(cy - halfLen*d.y, 0, height));
          float x2 = int(constrain(cx + halfLen*d.x, 0, width));
          float y2 = int(constrain(cy + halfLen*d.y, 0, height));
        
          part.setVertex(0, x1, y1, -1);
          part.setVertex(1, x2, y2, -1);
          previousAngle[i][j] = a;
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
    /*
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
         color c = color(d.x*255.0, d.y*255.0, 255.0, constrain(100.0 + audioManager.getAmplitude()*255.0*1.5, 0.0, 255.0));
         fill(c);
         stroke(c);
         line(x1, y1, -1, x2, y2, -1);
      }
    }
    */
    shape(this.vectors);
  }
  
  PVector lookup(PVector position)
  {
    int c = int(constrain(position.x/this.resolution, 0, cols-1));
    int r = int(constrain(position.y/this.resolution, 0, rows-1));
    return this.field[c][r].copy();
  }
}
