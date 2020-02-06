class FollowFlowFieldBehaviour extends Behaviour
{
  FlowField flowField;

  FollowFlowFieldBehaviour(String name, float multiplier, FlowField flowField)
  {
    super(name, multiplier);
    this.flowField = flowField;
  }
  
  FollowFlowFieldBehaviour(String name, float multiplier, FlowField flowField, boolean syncToMusic, int band, float minBandValue, float maxBandValue, float bandSensitivity)
  {
    super(name, multiplier, syncToMusic, band, minBandValue, maxBandValue, bandSensitivity);
    this.flowField = flowField;
  }
  
  PVector getForce(Vehicle v, VehicleContext vc)
  {
    PVector desired = this.flowField.lookup(v.location);
    // The magnitude is usually 1, but it can be greater if there are multiple visitors in the same location
    float magSq = desired.magSq();
    desired.mult(v.maxSpeed);

    // Reynold's formula for steering force with a cap
    PVector steer = PVector.sub(desired, v.velocity);
    steer.limit(v.maxForce*magSq);

    v.maxSpeedMult = magSq;

    return steer;
  }
}
