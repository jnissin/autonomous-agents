import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import controlP5.*;

import java.util.Arrays;
import java.util.List;

PApplet applet;

FlockManager flockManager;
VisitorManager visitorManager;
ObstacleManager obstacleManager;
AudioManager audioManager;
EncounterManager encounterManager;

FlowField field;
Theme selectedTheme;
int initializationIdx = 0;
int selectedThemeIdx = 0;
int selectedFlockIdx = 0;
ControlP5 cp5;
Group cp5group;
ScrollableList flockList;
PostFX pfx;
boolean showVectorField = true;

final float FPS = 40;
final float GAMESPEED = 40;
float previousMilli, deltaDiv, deltaTime;

void setup()
{
  size(1920, 1080, P3D);
  //fullScreen(P3D);
  frameRate(FPS);
  smooth(2);
 
  applet = this;

  // Create managers
  visitorManager = new VisitorManager(790, true);
  flockManager = new FlockManager(Config.numFlocks, Config.numVehicles/Config.numFlocks);
  obstacleManager = new ObstacleManager();
  audioManager = new AudioManager(Config.rmsSmoothFactor);
  encounterManager = new EncounterManager();
  
  // Load the audio file
  audioManager.loadAudioFile("media/deceptive.wav");
  
  pfx = new PostFX(this);
  pfx.preload(BloomPass.class);
    
  initialize();
}

void initialize()
{
  randomSeed(777 + initializationIdx);
  selectedTheme = THEMES[selectedThemeIdx%THEMES.length];
  
  // Initialize flow field
  field = new FlowField(10, 5, 0.005);
  
  // Initialize flocks
  flockManager.initialize();

  // Initialize visitors
  visitorManager.initialize();

  initializeControlP5();
  
  selectedThemeIdx += 1;
  initializationIdx += 1;
}

void initializeControlP5()
{
  if (!Config.showUserInterface)
  {
    return;
  }
  
  // Create a new ControlP5 instance if necessary
  if (cp5 == null)
  {
    cp5 = new ControlP5(this);
  }
  
  // Create a new ControlP5 group
  if (cp5group == null)
  {
    cp5group = cp5.addGroup("controls");
  }
  else
  {
    cp5.remove(cp5group);
  }

  int yPosition = 10;
  int xPosition = 10;
  Flock selectedFlock = flockManager.flocks.get(selectedFlockIdx);
  ArrayList<Behaviour> selectedFlockBehaviours = selectedFlock.behaviourSet.behaviours;

  // Add sliders for different behaviours
  for (int i = 0; i < selectedFlockBehaviours.size(); i++)
  {
    Behaviour behaviour = selectedFlockBehaviours.get(i);
    cp5.addSlider(behaviour.name, -10, 10)
       .setPosition(xPosition, yPosition)
       .setGroup(cp5group)
       .setValue(behaviour.multiplier);
    yPosition += 10;
  }
  
  // Add a toggle for the vector field
  Toggle t = cp5.addToggle("vectorField")
     .setPosition(xPosition, yPosition)
     .setGroup(cp5group)
     .setSize(100, 10)
     .setValue(showVectorField);
     
   Label l = t.getCaptionLabel();
   //l.alignX(200);
   l.alignY(-5);
   l.setPaddingX(102);
   yPosition += 10;
  
  // Add a flock selector
  ArrayList<String> flockNames = new ArrayList<String>();
  
  for (Flock f : flockManager.flocks)
  {
    flockNames.add(f.toString());
  }
  
  if (flockList == null)
  {
    flockList = cp5.addScrollableList("flockId")
       .setPosition(xPosition, yPosition)
       .setGroup(cp5group)
       .close()
       .setSize(100, 100)
       .setBarHeight(10)
       .setItemHeight(10)
       .setItems(flockNames);
    yPosition += 10;
  }
  else
  {
    flockList.setPosition(xPosition, yPosition);
    yPosition += 10;
  }
  
  // Add a color picker for the flock color
   cp5.addColorPicker("flockColor")
     .setPosition(200, 10)
     .setGroup(cp5group)
     .setBarHeight(10)
     .setSize(100, 100)
     .setColorValue(selectedFlock.flockColor);
}

void changeTheme(int themeIdx)
{
  selectedThemeIdx = themeIdx%THEMES.length;
  selectedTheme = THEMES[selectedThemeIdx%THEMES.length];

  for (Flock f : flockManager.flocks)
  {
    f.setColor(selectedTheme.getRandomThemeColor());
  }
}

void draw()
{ 
  // Print information to title bar
  surface.setTitle("Autonomous agents: " + selectedTheme.name + " @ " + (int)frameRate + " FPS");

  // Clear background
  background(selectedTheme.backgroundColor);
 
  // Update the simulation
  update();
  
  // Draw the vector field
  if (showVectorField)
  {
    field.display();
  }
  
  // Add bloom to the vector field
  pfx.render()
    .bloom(0.3, 7, 40)
    .compose();
  
  // Draw obstacles
  obstacleManager.display();

  // Draw the visitors
  visitorManager.display();
  
  // Draw the flocks
  flockManager.display();
  
  // Draw encounters
  encounterManager.display();
}

void update()
{
  // Update the delta time
  deltaTime = ((millis() - previousMilli) / 1000.0) * GAMESPEED;
  previousMilli = millis();
  
  // Update the audio values
  audioManager.update();
  
  // Update flow field
  field.update();

  // Update visitor positions
  visitorManager.update();

  // Update each flock and their vehicles
  flockManager.update();
  
  // Update encounters
  encounterManager.update();
}

public void keyPressed()
{
  // Use 'n' to navigate to next theme
  if (key == 'n')
  {
    initialize();
  }
  else if (key == 't')
  {
    changeTheme(selectedThemeIdx + 1);
  }
}

public void mouseClicked()
{
  visitorManager.mouseClicked();
}

public void controlEvent(ControlEvent e)
{  
  Flock selectedFlock = flockManager.flocks.get(selectedFlockIdx);

  if (e.getName() == "flockId")
  {
    selectedFlockIdx = int(e.getValue());
    initializeControlP5();
  }
  else if (e.getName() == "flockColor")
  {
    int r = int(e.getArrayValue(0));
    int g = int(e.getArrayValue(1));
    int b = int(e.getArrayValue(2));
    int a = int(e.getArrayValue(3));
    color c = color(r,g,b,a);
    selectedFlock.setColor(c);
  }
  else if (e.getName() == "vectorField")
  {
    showVectorField = e.getValue() == 0 ? false : true;
  }
  else
  {
    selectedFlock.behaviourSet.getBehaviour(e.getName()).multiplier = e.getValue();
  }
}

void stop()
{
  if (visitorManager != null)
  {
    visitorManager.dispose();
  }
}
