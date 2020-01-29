class Trail
{
  int size;
  int vertexIdx;
  PVector[] vertices;
  boolean verticesPopulated;
  color trailColor;
  
  Trail(int size, color trailColor)
  {
    this.size = size;
    this.trailColor = trailColor;
    this.vertexIdx = 0;
    this.vertices = new PVector[this.size];
    this.verticesPopulated = false;
    
    reset();
  }
  
  void reset()
  {
    for (int i = 0; i < this.vertices.length; i++)
    {
      if (verticesPopulated)
      {
        this.vertices[i].set(0, 0);
      }
      else
      {
        this.vertices[i] = new PVector(0, 0);
      }
    }
    
    this.vertexIdx = 0;
    this.verticesPopulated = false;
  }
  
  void display()
  {        
    int n = this.verticesPopulated ? vertices.length : this.vertexIdx;
    int latestVertexIdx = this.vertexIdx - 1;
    
    strokeWeight(2);
    noFill();
    beginShape();
    for (int i = 0; i < n; i++)
    {
      int idx = latestVertexIdx - i;
      idx = idx < 0 ? idx + n : idx;
      stroke(this.trailColor, map(i, 0, n, 255, 0));
      vertex(this.vertices[idx].x, this.vertices[idx].y);
    }
    endShape();
  }
  
  void addVertex(float x, float y)
  {
    // Set the current vertex idx
    this.vertices[vertexIdx].set(x, y);
   
    // If we have written to each vertex index at least once
    if (this.vertexIdx == this.size-1)
    {
      this.verticesPopulated = true;
    }
    
    // Increase current vertex index
    this.vertexIdx = (this.vertexIdx + 1)%this.size;
  }
}
