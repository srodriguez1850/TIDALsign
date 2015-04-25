import processing.serial.*;
import controlP5.*;

Serial arduino;
Sensor sensor;

ControlP5 controlp5;
Textlabel textlabel1;

void setup()
{
  // Setup window size and title
  size(400, 200);
  smooth();
  frame.setTitle("Sensor GUI");
  background(0);
  
  // Open Serial to arduino
  arduino = new Serial(this, Serial.list()[0], 19200);
  delay(3000);
  attemptHandshake();
  
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
class Sensor
{
  int calMax[] = new int[5];
  int calMin[] = new int[5];
  int valBend[] = new int[5];
  
  // Setters
  void setCalibrationMax(int max, int finger)
  {
    calMax[finger] = max;
  }
  void setCalibrationMin(int min, int finger)
  {
    calMin[finger] = min;
  }
  void setBendValue(int val, int finger)
  {
    valBend[finger] = val;
  }
  
  // Getters
  int getCalibrationMax(int finger)
  {
    return calMax[finger];
  }
  int getCalibrationMin(int finger)
  {
    return calMin[finger];
  }
  int getBendValue(int finger)
  {
    return valBend[finger];
  }
}

//=====================
//  HELPER FUNCTIONS
//=====================
void attemptHandshake()
{
  byte shake[] = new byte[3];
  shake[0] = 'H';
  shake[1] = 'I';
  shake[2] = '!';
  arduino.write(shake);
  delay(50);
  
  if (!"HELLO FROM ARDUINO".equals(arduino.readString()))
  {
    // Quit if no Arduino is detected
    println("ERROR: No Arduino detected.");
    exit();
  }
  
  return;
}

void sendCommand(String command)
{
  if (command.length() != 3)
  {
    // Command is not 3 bytes
    println("ERROR: Command is not 3 bytes");
    return;
  }
  
  arduino.write(command.getBytes());
  return;
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
  while (!isCalibrated)
  {
    sendCommand("CIN");
    delay(1000);
    sendCommand("CAX");
    delay(1000);
    isCalibrated = true;
  }
  sendCommand("RA0");
  delay(25);
  // May have to exception handle vvvvv
  controlp5.getController("Thumb").setValue(Integer.parseInt(arduino.readStringUntil(10).trim()));
}

// ==========================
//  CONTROLP5 EVENT HANDLING
// ==========================
public void Calibrate()
{
  isCalibrated = false;
}
