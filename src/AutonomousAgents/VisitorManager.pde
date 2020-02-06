import TUIO.*;
import java.util.HashMap;

class VisitorManager implements TuioListener
{
  float tableSize;
  boolean verbose;
  float scaleFactor;
  TuioClient tuioClient;

  ArrayList<Visitor> visitors;
  HashMap<String, Visitor> idToVisitor;

  VisitorManager(float tableSize, boolean verbose)
  {
    this.tableSize = tableSize;
    this.scaleFactor = height/tableSize;
    this.verbose = verbose;

    // Create an instance of the TuioProcessing client
    // since we add "this" class as an argument the TuioProcessing class expects
    // an implementation of the TUIO callback methods in this class (see below)
    this.tuioClient  = new TuioClient(3333);
    this.tuioClient.addTuioListener(this);
    this.tuioClient.connect();
    
    this.visitors = new ArrayList<Visitor>();
    this.idToVisitor = new HashMap<String, Visitor>();
  }

  void initialize()
  {
    this.visitors.clear();
    this.idToVisitor.clear();

    for (int i = 0; i < Config.numMouseVisitors; i++)
    {
      int padding = 100;
      Visitor v = new Visitor(
        String.format("M%d", i),
        VisitorType.MOUSE,
        new PVector(random(padding, width-padding), random(padding, height-padding)),
        20.0,
        120.0);
      this.addVisitor(v);
    }
  }

  void update()
  {
    synchronized(this.visitors)
    {
      for (int i = this.visitors.size()-1; i >= 0; i--)
      {
        Visitor v = this.visitors.get(i);
        v.update();

        if (v.removedTime() > Config.visitorRemovedDelay)
        {
          this.removeVisitor(v.id);
        }
      }
    }
  }
  
  void display()
  {
    synchronized(this.visitors)
    {
      for (Visitor v : this.visitors)
      {
        if (v.isInteractable())
        {
          v.display();
        }
      } 
    }
  }

  void addVisitor(Visitor v)
  {    
    if (!this.idToVisitor.containsKey(v.id))
    {
      synchronized (this.visitors)
      {
        this.visitors.add(v);
      }
      this.idToVisitor.put(v.id, v);
    }
    else
    {
      this.idToVisitor.get(v.id).removedAt = -1;
      println("ERROR: Visitor with ID: %s already found", v.id);
    }
  }
  
  void removeVisitor(String id)
  { 
    if (this.idToVisitor.containsKey(id))
    {
      Visitor v = this.idToVisitor.get(id);
      synchronized(this.visitors)
      {
        v.alive = false;
        this.visitors.remove(v);
      }
      this.idToVisitor.remove(id);
    }
    else
    {
      println("ERROR: Cannot remove visitor with ID: %s - key not found", id);
    }
  }

  // --------------------------------------------------------------
  // these callback methods are called whenever a TUIO event occurs
  // there are three callbacks for add/set/del events for each object/cursor/blob type
  // the final refresh callback marks the end of each TUIO frame

  // called when an object is added to the scene
  void addTuioObject(TuioObject tobj)
  {
    if (this.verbose)
    {
      println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
    }
  }

  // called when an object is moved
  void updateTuioObject (TuioObject tobj)
  {
    if (this.verbose)
    {
      println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
            +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
    }
  }

  // called when an object is removed from the scene
  void removeTuioObject(TuioObject tobj) 
  {
    if (this.verbose)
    {
      println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
    }
  }

  // --------------------------------------------------------------
  // called when a cursor is added to the scene
  void addTuioCursor(TuioCursor tcur)
  {
    if (this.verbose)
    {
      println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
    }
    
    Visitor v = new Visitor(
      String.format("T%d", tcur.getCursorID()),
      VisitorType.TUIO,
      new PVector(tcur.getX()*width, tcur.getY()*height),
      20.0,
      120.0);
    
    this.addVisitor(v);
  }

  // called when a cursor is moved
  void updateTuioCursor (TuioCursor tcur)
  {
    if (this.verbose)
    {
      //println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()+" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
    }
    
    String id = String.format("T%d", tcur.getCursorID());

    if (this.idToVisitor.containsKey(id))
    {
      synchronized (this.visitors)
      {
        Visitor v = this.idToVisitor.get(id);
        v.location.set(tcur.getX() * width, tcur.getY() * height);
      }
    }
  }

  // called when a cursor is removed from the scene
  void removeTuioCursor(TuioCursor tcur)
  {
    if (this.verbose)
    {
      println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
    }
    
    String id = String.format("T%d", tcur.getCursorID());
    
    if (this.idToVisitor.containsKey(id))
    {
      this.idToVisitor.get(id).removedAt = millis();
    }
    
    //this.removeVisitor(id);
  }

  // --------------------------------------------------------------
  // called when a blob is added to the scene
  void addTuioBlob(TuioBlob tblb) 
  {
    if (this.verbose)
    {
      println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
    }
  }

  // called when a blob is moved
  void updateTuioBlob (TuioBlob tblb)
  {
    if (this.verbose)
    {
      println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
            +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
    }
  }

  // called when a blob is removed from the scene
  void removeTuioBlob(TuioBlob tblb)
  {
    if (this.verbose)
    {
      println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
    }
  }

  // --------------------------------------------------------------
  // called at the end of each TUIO frame
  void refresh(TuioTime frameTime)
  {
    if (this.verbose)
    {
      //println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
    }
  }
  
  void dispose()
  {
    // This should only be called by PApplet. dispose() is what gets 
    // called when the host applet is stopped, so this should shut down
    // any threads, disconnect from the net, unload memory, etc. 
    if (this.tuioClient.isConnected())
    {
      this.tuioClient.disconnect();
    }
  }
  
  public void mouseClicked()
  {
    PVector mousePosition = new PVector(mouseX, mouseY);
  
    for (Visitor v : this.visitors)
    {
      if (v.type == VisitorType.MOUSE && PVector.dist(mousePosition, v.location) < v.r)
      {
        v.active = !v.active;
        break;
      }
    }
  }
}
