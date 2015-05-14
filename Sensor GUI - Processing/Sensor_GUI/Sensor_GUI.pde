/*

Sensor GUI
Northwestern University
EECS 395: Tangible Interaction Design and Learning

*/

import processing.serial.*;
import controlP5.*;

Serial arduino;
Sensor sensor;
SignDatabase db;

ControlP5 controlp5;
Textlabel textlabel1;

// ==================
//  GLOBAL CONSTANTS
// ==================
public static final int MAX_DATABASE_SIZE = 50;
public static final float VALIDATION_THRESHOLD = 0.33;

// ================
//  SETUP FUNCTION
// ================
void setup()
{
  // Setup window size and title
  size(400, 200);
  smooth();
  frame.setTitle("Sensor GUI");
  background(0);
  
  // Open Serial to arduino
  try
  {
    arduino = new Serial(this, Serial.list()[0], 38400);
    delay(3000);
    attemptHandshake();
  }
  catch (Exception e)
  {
    exit();
  }
  
  // Initialize sensor
  sensor = new Sensor();
  calibrateSensor();
  
  // Initialize database
  db = new SignDatabase();
  db.initializeDatabase("signdb.db");  
  
  // == Interface initializers ==
  controlp5 = new ControlP5(this);
  // Disable broadcasting to listeners
  controlp5.setBroadcast(false);
  // Title
  textlabel1 = controlp5.addTextlabel("Title")
                        .setText("Sensor GUI")
                        .setPosition(10, 10);
  // Thumb slider
  controlp5.addSlider("Thumb")
           .setRange(0, 1023)
           .setValue(0)
           .setPosition(10, 40)
           .setSize(100, 20);
  // Index slider
  controlp5.addSlider("Index")
           .setRange(0, 1023)
           .setValue(0)
           .setPosition(10, 70)
           .setSize(100, 20);
  // Middle slider
  controlp5.addSlider("Middle")
           .setRange(0, 1023)
           .setValue(0)
           .setPosition(10, 100)
           .setSize(100, 20);
  // Ring slider
  controlp5.addSlider("Ring")
           .setRange(0, 1023)
           .setValue(0)
           .setPosition(10, 130)
           .setSize(100, 20);
  // Pinky slider
  controlp5.addSlider("Pinky")
           .setRange(0, 1023)
           .setValue(0)
           .setPosition(10, 160)
           .setSize(100, 20);
  // Calibrate button
  controlp5.addButton("Calibrate")
           .setValue(10)
           .setPosition(320, 5)
           .setSize(70, 20)
           .setId(1)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Next letter button
  controlp5.addButton("Next")
           .setValue(10)
           .setPosition(320, 75)
           .setSize(70, 20)
           .setId(2)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Previous letter button
  controlp5.addButton("Previous")
           .setValue(10)
           .setPosition(320, 105)
           .setSize(70, 20)
           .setId(3)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Quit button
  controlp5.addButton("Quit")
           .setValue(10)
           .setPosition(320, 175)
           .setSize(70, 20)
           .setId(4)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Re-enable broadcasting to listeners
  controlp5.setBroadcast(true);
}

// ====================
//  CLASS DECLARATIONS
// ====================
public class Sensor
{
  int calMin[];
  int calMax[];
  int valBend[];
  
  // Constructor
  Sensor()
  {
    calMin = new int[5];
    calMax = new int[5];
    valBend = new int[5];
  }
  
  // Inherited
  public String toString()
  {
    String s = "";
    
    s += "Calibration minimum:\n";
    for (int i = 0; i < 5; i++)
    {
      s += i + " " + calMin[i] + "\n";
    }
    s += "Calibration maximum:\n";
    for (int i = 0; i < 5; i++)
    {
      s += i + " " + calMax[i] + "\n";
    }
    
    return s;
  }
  
  // Setters
  public void setCalibrationMin(int min, int finger)
  {
    calMin[finger] = min;
  }
  public void setCalibrationMax(int max, int finger)
  {
    calMax[finger] = max;
  }
  public void setIndividualBendValue(int val, int finger)
  {
    valBend[finger] = val;
  }
  public void setBendValue()
  {
    try
    {
      valBend[0] = Integer.parseInt(arduino.readStringUntil(10).trim());
      valBend[1] = Integer.parseInt(arduino.readStringUntil(10).trim());
      valBend[2] = Integer.parseInt(arduino.readStringUntil(10).trim());
      valBend[3] = Integer.parseInt(arduino.readStringUntil(10).trim());
      valBend[4] = Integer.parseInt(arduino.readStringUntil(10).trim());
    }
    catch (NullPointerException e)
    {
      println("Exception: serial buffer empty");
      return;
    }
  }
  
  // Getters
  public int getCalibrationMin(int finger)
  {
    return calMin[finger];
  }
  public int getCalibrationMax(int finger)
  {
    return calMax[finger];
  }
  public int getIndividualBendValue(int finger)
  {
    return valBend[finger];
  }
}

class SignDatabase
{
  String signName[];
  String signData[];
  int index;
  
  // Constructor
  SignDatabase()
  {
    signName = new String[MAX_DATABASE_SIZE];
    signData = new String[MAX_DATABASE_SIZE];
    index = 0;
  }
  
  // Inherited
  public String toString()
  {
    String s = "";
    
    for (int i = 0; i < index; i++)
    {
      s += signName[i] + " " + signData[i] + "\n";
    }
    
    return s;
  }
  
  // Specific
  void initializeDatabase(String address)
  {
    BufferedReader parser;
    String p_name;
    String p_data;
    
    parser = createReader(address);
    
    do
    {
      try
      {
        p_name = parser.readLine();
        p_data = parser.readLine();
      }
      catch (IOException e)
      {
        p_name = null;
        p_data = null;
      }
      if (p_name != null && p_data != null)
      {
        db.addEntry(p_name, p_data);
      }
    } while (p_name != null && p_data != null);
  }
  
  void addEntry(String name, String data)
  {
    signName[index] = name;
    signData[index] = data;
    index++;
  }
}

//=====================
//  HELPER FUNCTIONS
//=====================
void attemptHandshake()
{
  sendCommand("HI!");
  delay(50);
  
  if (!"HELLO FROM ARDUINO".equals(arduino.readStringUntil(10).trim()))
  {
    // Quit if no Arduino is detected
    println("ERROR: No Arduino detected.");
    exit();
  }
}

void sendCommand(String s)
{
  command = s.getBytes();
  arduino.write(command);
}

void calibrateSensor()
{
  arduino.clear();
  
  sendCommand("CAL");
  delay(500);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 0);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 1);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 2);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 3);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 4);
  println("Minimum calibration assigned");
  
  sendCommand("CAL");
  delay(500);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 0);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 1);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 2);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 3);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 4);
  println("Maximum calibration assigned");
}

void updateGUISliders()
{
  controlp5.getController("Thumb").setValue(sensor.getIndividualBendValue(0));
  controlp5.getController("Index").setValue(sensor.getIndividualBendValue(1));
  controlp5.getController("Middle").setValue(sensor.getIndividualBendValue(2));
  controlp5.getController("Ring").setValue(sensor.getIndividualBendValue(3));
  controlp5.getController("Pinky").setValue(sensor.getIndividualBendValue(4));
}

void sensorMapping()
{
  thumbMap = (int)map(sensor.getIndividualBendValue(0), sensor.getCalibrationMin(0), sensor.getCalibrationMax(0), 0, 100);
  indexMap = (int)map(sensor.getIndividualBendValue(1), sensor.getCalibrationMin(1), sensor.getCalibrationMax(1), 0, 100);
  middleMap = (int)map(sensor.getIndividualBendValue(2), sensor.getCalibrationMin(2), sensor.getCalibrationMax(2), 0, 100);
  ringMap = (int)map(sensor.getIndividualBendValue(3), sensor.getCalibrationMin(3), sensor.getCalibrationMax(3), 0, 100);
  pinkyMap = (int)map(sensor.getIndividualBendValue(4), sensor.getCalibrationMin(4), sensor.getCalibrationMax(4), 0, 100);
}

// ===================
//  GLOBAL VARIABLES
// ===================
byte command[] = new byte[3];
int initialGrace;    // will overflow after 18 hours
boolean activeGrace = false;

// WE USE THESE TO CHECK THE DATABASE
int thumbMap;
int indexMap;
int middleMap;
int ringMap;
int pinkyMap;

// ===============
//  MAIN FUNCTION
// ===============
void draw()
{
  // Update GUI routine
  sendCommand("RAA");
  delay(25);
  sensor.setBendValue();
  sensorMapping();
  updateGUISliders();
  
  // Check user input routine
  if (activeGrace)
  {
    if (millis() - initialGrace > 3000)
    {
      // check user's fingers against the database here, give feedback as needed
      // if user is correct, set activegrace to false to exit
      println("CHECK USER INPUT");
      /*
      check every finger against thresholds of current letter of the database
        if every finger is correct, exit
        else take fingers that are wrong, change the slider color, send command to arduino to
        buzz fingers, and retake the initial grace
        continue this until all fingers are correct
        
        vibration motor command: V
      */
      initialGrace = millis();
    }
  }
}

// ==========================
//  CONTROLP5 EVENT HANDLING
// ==========================
public void Calibrate()
{
  calibrateSensor();
}

public void Next()
{
  initialGrace = millis();
  activeGrace = true;
}

public void Previous()
{
  initialGrace = millis();
  activeGrace = true;
}

public void Quit()
{
  sendCommand("QAP");
  exit();
}
