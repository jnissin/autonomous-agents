static class Config
{
  public static final int numMouseVisitors = 0;
  public static final int numFlocks = 4;
  public static final int numVehicles = 1000;
  public static final float rmsSmoothFactor = 0.4;
  public static final float encounterDistanceMin = 150;
  public static final float encounterDistanceMax = 420;
  public static final float encounterGraphicSizeMin = 50;
  public static final float encounterGraphicSizeMax = 150;
  public static final int visitorAddedDelay = 3000;
  public static final int visitorRemovedDelay = 1000;
  public static final boolean showUserInterface = true;
  public static final int minVehicleLifeTime = 40*1000;
  public static final int maxVehicleLifeTime = 120*1000;
  public static final PVector[] spawnPoints = new PVector[] {
    new PVector(150, 1080/2), new PVector(1920-150, 1080/2)//, new PVector(1920/2, 150), new PVector(1920/2, 1080-150)
  };
  public static int currentSpawnPointIdx = 0;
  public static float spawnAreaRadius = 70;
}
