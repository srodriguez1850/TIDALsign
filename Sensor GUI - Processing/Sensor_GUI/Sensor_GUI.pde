import processing.serial.*;
import controlP5.*;

Serial arduino;
Sensor sensor;

ControlP5 controlp5;
Textlabel textlabel1;

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
    arduino = new Serial(this, Serial.list()[0], 19200);
    delay(3000);
    attemptHandshake();
  }
  catch (Exception e)
  {
    exit();
  }
  
  // Initialize Sensor class
  sensor = new Sensor();
  
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
    valBend[0] = Integer.parseInt(arduino.readStringUntil(10).trim());
    valBend[1] = Integer.parseInt(arduino.readStringUntil(10).trim());
    valBend[2] = Integer.parseInt(arduino.readStringUntil(10).trim());
    valBend[3] = Integer.parseInt(arduino.readStringUntil(10).trim());
    valBend[4] = Integer.parseInt(arduino.readStringUntil(10).trim());
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
  
  isCalibrated = true;
}

void updateGUISliders()
{
  controlp5.getController("Thumb").setValue(sensor.getIndividualBendValue(0));
  controlp5.getController("Index").setValue(sensor.getIndividualBendValue(1));
  controlp5.getController("Middle").setValue(sensor.getIndividualBendValue(2));
  controlp5.getController("Ring").setValue(sensor.getIndividualBendValue(3));
  controlp5.getController("Pinky").setValue(sensor.getIndividualBendValue(4));
}

// ===================
//  GLOBAL VARIABLES
// ===================
boolean isCalibrated = false;
byte command[] = new byte[3];

// ===============
//  MAIN FUNCTION
// ===============
void draw()
{
  if (!isCalibrated)
  {
    calibrateSensor();
  }
  
  sendCommand("RAA");
  delay(25);
  sensor.setBendValue();
  updateGUISliders();
}

// ==========================
//  CONTROLP5 EVENT HANDLING
// ==========================
public void Calibrate()
{
  isCalibrated = false;
}
