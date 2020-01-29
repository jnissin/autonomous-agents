import java.util.Hashtable; 
import java.util.List;

class BehaviourSet
{
  ArrayList<Behaviour> behaviours;
  Hashtable<String, Behaviour> nameToBehaviour;
  
  BehaviourSet()
  {
    this.behaviours = new ArrayList<Behaviour>();
    this.nameToBehaviour = new Hashtable<String, Behaviour>(); 
  }
  
  BehaviourSet(ArrayList<Behaviour> behaviours)
  {
    this.behaviours = new ArrayList<Behaviour>();
    this.nameToBehaviour = new Hashtable<String, Behaviour>();

    if (behaviours != null)
    {
      for (Behaviour b : this.behaviours)
      {
        addBehaviour(b);
      }
    }
  }
  
  void addBehaviour(Behaviour b)
  {
    this.nameToBehaviour.put(b.name, b);
    this.behaviours.add(b);
  }
  
  void removeBehaviour(String name)
  {
    Behaviour b = this.nameToBehaviour.get(name);
    this.behaviours.remove(b);
    this.nameToBehaviour.remove(name);
  }
  
  Behaviour getBehaviour(String name)
  {
    return this.nameToBehaviour.get(name);
  }
  
  void apply(Vehicle v, VehicleContext vc, List<String> filter)
  {
    for (Behaviour b : this.behaviours)
    {
      // Skip behaviours present in filter
      if (filter != null && filter.contains(b.name))
      {
        continue;
      }
      
      b.apply(v, vc);
    }
  }
}
