abstract class Behaviour
{
  String name;
  float multiplier;
  boolean syncToMusic;
  int band;
  float minBandValue;
  float maxBandValue;
  float bandSensitivity;
  
  Behaviour(String name, float multiplier)
  {
    this(name, multiplier, false, 0, 0, 1, 1);
  }
  
  Behaviour(String name, float multiplier, boolean syncToMusic, int band, float minBandValue, float maxBandValue, float bandSensitivity)
  {
    this.name = name;
    this.multiplier = multiplier;
    this.syncToMusic = syncToMusic;
    this.band = band;
    this.minBandValue = minBandValue;
    this.maxBandValue = maxBandValue;
    this.bandSensitivity = bandSensitivity;
  }
    
  void apply(Vehicle v, VehicleContext vc)
  {
    PVector force = this.getForce(v, vc);
    
    if (this.syncToMusic)
    {
      float musicMult = map(audioManager.getFrequency(band), 0, 1, this.minBandValue, this.maxBandValue) * this.bandSensitivity;
      
      // The value at minimum band value might be negative or positive and vice versa
      if (this.minBandValue > this.maxBandValue)
      {
        musicMult = constrain(musicMult, this.maxBandValue, this.minBandValue);
      }
      else
      {
        musicMult = constrain(musicMult, this.minBandValue, this.maxBandValue);
      }
      
      float m = this.multiplier * musicMult;
      force.mult(m);
    }
    else
    {
      force.mult(this.multiplier);
    }
    
    v.applyForce(force);
  }
  
  abstract PVector getForce(Vehicle v, VehicleContext vc);
}
