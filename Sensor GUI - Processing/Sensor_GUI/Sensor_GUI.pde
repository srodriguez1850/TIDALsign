/*

Sensor GUI
Northwestern University
EECS 395: Tangible Interaction Design and Learning

*/

import processing.serial.*;
import ddf.minim.*;
import controlP5.*;

Serial arduino;
Sensor sensor;
SignDatabase db;

AudioPlayer player;
Minim minim;

ControlP5 controlp5;
Textlabel textlabel1;
Textlabel textlabel2;

// ==================
//  GLOBAL CONSTANTS
// ==================
public static final int MAX_DATABASE_SIZE = 50;
public static final int CALIBRATION_PERIOD = 3000;
public static final int VALIDATION_M_THRESHOLD = 67;
public static final int VALIDATION_H_THRESHOLD = 33;
public static final int VALIDATION_GPERIOD = 3000;

// ================
//  SETUP FUNCTION
// ================
void setup()
{
  // Setup window size and title
  size(400, 200);
  smooth();
  frame.setTitle("TidalSign");
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
  
  // Initialize sound engine
  minim = new Minim(this);
  player = minim.loadFile("ring.mp3", 2048);
  
  // Initialize sensor
  sensor = new Sensor();
  //calibrateSensor();
  
  // Initialize database
  db = new SignDatabase();
  db.initializeDatabase("signdb.db");  
  
  // == Interface initializers ==
  controlp5 = new ControlP5(this);
  // Disable broadcasting to listeners
  controlp5.setBroadcast(false);
  // Title
  textlabel1 = controlp5.addTextlabel("Title")
                        .setText("TidalSign GUI")
                        .setPosition(10, 10);
  textlabel2 = controlp5.addTextlabel("CurrentLetter")
                        .setText("A")
                        .setPosition(338, 98);
  // Thumb slider
  controlp5.addSlider("Thumb")
           .setRange(0, 100)
           .setValue(0)
           .setPosition(30, 50)
           .setSize(20, 100);
  // Index slider
  controlp5.addSlider("Index")
           .setRange(0, 100)
           .setValue(0)
           .setPosition(80, 50)
           .setSize(20, 100);
  // Middle slider
  controlp5.addSlider("Middle")
           .setRange(0, 100)
           .setValue(0)
           .setPosition(130, 50)
           .setSize(20, 100);
  // Ring slider
  controlp5.addSlider("Ring")
           .setRange(0, 100)
           .setValue(0)
           .setPosition(180, 50)
           .setSize(20, 100);
  // Pinky slider
  controlp5.addSlider("Pinky")
           .setRange(0, 100)
           .setValue(0)
           .setPosition(230, 50)
           .setSize(20, 100);
  // Calibrate button
  controlp5.addButton("MinCalibrate")
           .setValue(10)
           .setPosition(240, 5)
           .setSize(70, 20)
           .setId(5)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  controlp5.addButton("MaxCalibrate")
           .setValue(10)
           .setPosition(320, 5)
           .setSize(70, 20)
           .setId(1)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Next letter button
  controlp5.addButton("Next")
           .setValue(10)
           .setPosition(310, 115)
           .setSize(70, 20)
           .setId(2)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Previous letter button
  controlp5.addButton("Previous")
           .setValue(10)
           .setPosition(310, 70)
           .setSize(70, 20)
           .setId(3)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Stop button
  controlp5.addButton("StartStop")
           .setValue(10)
           .setPosition(240, 175)
           .setSize(70, 20)
           .setId(4)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  // Quit button
  controlp5.addButton("Quit")
           .setValue(10)
           .setPosition(320, 175)
           .setSize(70, 20)
           .setId(4)
           .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  disableButton("Previous");
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
  public int valMapped[];
  
  // Constructor
  Sensor()
  {
    calMin = new int[5];
    calMax = new int[5];
    valBend = new int[5];
    valMapped = new int[5];
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
    for (int i = 0; i < 5; i++)
    {
      try
      {
        valBend[i] = Integer.parseInt(arduino.readStringUntil(10).trim());
      }
      catch (NullPointerException e)
      {
        delay(25);
        valBend[i] = Integer.parseInt(arduino.readStringUntil(10).trim());
      }
    }
  }
  public void setMappedValue()
  {
    valMapped[0] = (int)map(getIndividualBendValue(0), getCalibrationMin(0), getCalibrationMax(0), 100, 0);
    valMapped[1] = (int)map(getIndividualBendValue(1), getCalibrationMin(1), getCalibrationMax(1), 100, 0);
    valMapped[2] = (int)map(getIndividualBendValue(2), getCalibrationMin(2), getCalibrationMax(2), 100, 0);
    valMapped[3] = (int)map(getIndividualBendValue(3), getCalibrationMin(3), getCalibrationMax(3), 100, 0);
    valMapped[4] = (int)map(getIndividualBendValue(4), getCalibrationMin(4), getCalibrationMax(4), 100, 0);
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
  public String signName[];
  public String signData[];
  public int index;
  
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
  delay(250);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 0);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 1);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 2);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 3);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 4);
  
  delay(CALIBRATION_PERIOD);
  
  sendCommand("CAL");
  delay(250);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 0);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 1);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 2);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 3);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 4);
}

void calibrateSensorMin()
{
  arduino.clear();
  
  sendCommand("CAL");
  delay(250);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 0);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 1);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 2);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 3);
  sensor.setCalibrationMin(Integer.parseInt(arduino.readStringUntil(10).trim()), 4);
}

void calibrateSensorMax()
{
  arduino.clear();
  
  sendCommand("CAL");
  delay(250);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 0);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 1);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 2);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 3);
  sensor.setCalibrationMax(Integer.parseInt(arduino.readStringUntil(10).trim()), 4);
}

void updateGUISliders()
{
  //////////////////////////////////////////////////////////
  // Grabbing data from db places a null object in index 0
  String[] bufferVal = db.signData[currentDBIndex].split("");
  String[] values = new String[5];
  for (int i = 0; i < 5; i++)
  {
    values[i] = bufferVal[i + 1];
  }
  //////////////////////////////////////////////////////////
  String s[] = {"Thumb", "Index", "Middle", "Ring", "Pinky"};
  
  for (int i = 0; i < 5; i++)
  {
    controlp5.getController(s[i]).setValue(sensor.valMapped[i]);
    
    if (!activeGrace)
    {
      enableButton(s[i]);
    }
    else
    {
      if (values[i].equals("L"))
      {
        if (sensor.valMapped[i] >= VALIDATION_M_THRESHOLD)
        {
          controlp5.controller(s[i]).setColorBackground(color(0, 102, 0));
          controlp5.controller(s[i]).setColorForeground(color(0, 170, 0));
          controlp5.controller(s[i]).setColorActive(color(0, 255, 0));
        }
        else
        {
          int BGmap = (int)map(sensor.valMapped[i], 0, 100, 0, 102);
          int FGmap = (int)map(sensor.valMapped[i], 0, 100, 0, 170);
          int CAmap = (int)map(sensor.valMapped[i], 0, 100, 0, 255);
          controlp5.controller(s[i]).setColorBackground(color(102 - BGmap, BGmap, 0));
          controlp5.controller(s[i]).setColorForeground(color(170 - FGmap, FGmap, 0));
          controlp5.controller(s[i]).setColorActive(color(255 - CAmap, CAmap, 0));
        }
      }
      else if (values[i].equals("M"))
      {
        if (VALIDATION_M_THRESHOLD > sensor.valMapped[i] && sensor.valMapped[i] >= VALIDATION_H_THRESHOLD)
        {
          controlp5.controller(s[i]).setColorBackground(color(0, 102, 0));
          controlp5.controller(s[i]).setColorForeground(color(0, 170, 0));
          controlp5.controller(s[i]).setColorActive(color(0, 255, 0));
        }
        else
        {
          int BGmapH = (int)map(sensor.valMapped[i], 0, 50, 102, 0);
          int FGmapH = (int)map(sensor.valMapped[i], 0, 50, 170, 0);
          int CAmapH = (int)map(sensor.valMapped[i], 0, 50, 255, 0);
          int BGmapL = (int)map(sensor.valMapped[i], 50, 100, 102, 0);
          int FGmapL = (int)map(sensor.valMapped[i], 50, 100, 170, 0);
          int CAmapL = (int)map(sensor.valMapped[i], 50, 100, 255, 0);
          
          if (sensor.valMapped[i] < 51)
          {
            controlp5.controller(s[i]).setColorBackground(color(BGmapH, 102 - BGmapH, 0));
            controlp5.controller(s[i]).setColorForeground(color(FGmapH, 170 - FGmapH, 0));
            controlp5.controller(s[i]).setColorActive(color(CAmapH, 255 - CAmapH, 0));
          }
          else
          {
            controlp5.controller(s[i]).setColorBackground(color(102 - BGmapL, BGmapL, 0));
            controlp5.controller(s[i]).setColorForeground(color(170 - FGmapL, FGmapL, 0));
            controlp5.controller(s[i]).setColorActive(color(255 - CAmapL, CAmapL, 0));
          }
        }
      }
      else if (values[i].equals("H"))
      {
        if (VALIDATION_H_THRESHOLD > sensor.valMapped[i])
        {
          controlp5.controller(s[i]).setColorBackground(color(0, 102, 0));
          controlp5.controller(s[i]).setColorForeground(color(0, 170, 0));
          controlp5.controller(s[i]).setColorActive(color(0, 255, 0));
        }
        else
        {
          int BGmap = (int)map(sensor.valMapped[i], 0, 100, 0, 102);
          int FGmap = (int)map(sensor.valMapped[i], 0, 100, 0, 170);
          int CAmap = (int)map(sensor.valMapped[i], 0, 100, 0, 255);
          controlp5.controller(s[i]).setColorBackground(color(BGmap, 102 - BGmap, 0));
          controlp5.controller(s[i]).setColorForeground(color(FGmap, 170 - FGmap, 0));
          controlp5.controller(s[i]).setColorActive(color(CAmap, 255 - CAmap, 0));
        }
      }
      else break;
    }
  }
}

void enableButton(String s)  // only aesthetic
{
  controlp5.controller(s).setColorBackground(color(2, 52, 77));
  controlp5.controller(s).setColorForeground(color(1, 108, 158));
  controlp5.controller(s).setColorActive(color(0, 180, 234));
}

void disableButton(String s)  // only aesthetic
{
  controlp5.controller(s).setColorBackground(color(102, 0, 0));
  controlp5.controller(s).setColorForeground(color(170, 0, 0));
  controlp5.controller(s).setColorActive(color(255, 0, 0));
}

void validationRoutine()
{
  if (millis() - initialGrace > VALIDATION_GPERIOD)
    {
      // check user's fingers against the database here, give feedback as needed
      // if user is correct, set activegrace to false to exit
      print("Checking user input for "); println(db.signName[currentDBIndex]);
      /*
      check every finger against thresholds of current letter of the database
        if every finger is correct, exit
        else take fingers that are wrong, change the slider color, send command to arduino to
        buzz fingers, and retake the initial grace
        continue this until all fingers are correct
        
        vibration motor command: VD
        staggered motor command: VS
      */
      
      boolean correctFingers[] = new boolean[5];
      
      //////////////////////////////////////////////////////////
      // Grabbing data from db places a null object in index 0
      String[] bufferVal = db.signData[currentDBIndex].split("");
      String[] values = new String[5];
      for (int i = 0; i < 5; i++)
      {
        values[i] = bufferVal[i + 1];
      }
      //////////////////////////////////////////////////////////
      
      for (int i = 0; i < 5; i++) //<>//
      {
        if (values[i].equals("L"))
        {
          if (sensor.valMapped[i] >= VALIDATION_M_THRESHOLD)
          {
            print("Finger "); print(i); println(" is correct in L");
            correctFingers[i] = true;
          }
          else
          {
            print("Finger "); print(i); println(" is incorrect in L");
            correctFingers[i] = false;
          }
        }
        else if (values[i].equals("M"))
        {
          if (VALIDATION_M_THRESHOLD > sensor.valMapped[i] && sensor.valMapped[i] >= VALIDATION_H_THRESHOLD)
          {
            print("Finger "); print(i); println(" is correct in M");
            correctFingers[i] = true;
          }
          else
          {
            print("Finger "); print(i); println(" is incorrect in M");
            correctFingers[i] = false;
          }
        }
        else if (values[i].equals("H"))
        {
          if (VALIDATION_H_THRESHOLD > sensor.valMapped[i])
          {
            print("Finger "); print(i); println(" is correct in H");
            correctFingers[i] = true;
          }
          else
          {
            print("Finger "); print(i); println(" is incorrect in H");
            correctFingers[i] = false;
          }
        }
        else break;
      }
      
      if (trueVerification(correctFingers))
      {
        activeGrace = false;
        sendCommand("VTO");
        player.play();
        println("All fingers correct");
      }
      else
      {
        // concatenate fingers to array
        int n = 0; //<>//
        for (int i = 0; i < correctFingers.length; ++i) {
          n = (n << 1) + (correctFingers[i] ? 1 : 0);
        }
        n += 32;
        char c = ((char)n);
        // regular command - sendCommand("VD" + c);
        sendCommand("VS" + c);
        // receive command from buffer to continue operation
        delay(1500);
      }
      
      initialGrace = millis();
    }
}

boolean trueVerification(boolean[] a)
{
    for(boolean b : a) if(!b) return false;
    return true;
}

// ===================
//  GLOBAL VARIABLES
// ===================
byte command[] = new byte[3];

int initialGrace;    // will overflow after 18 hours (shouldn't be a problem)
boolean activeGrace = false;

int currentDBIndex = 0;

// ===============
//  MAIN FUNCTION
// ===============
void draw()
{
  background(0);
  
  // Update GUI routine
  sendCommand("RAA");
  delay(50);
  sensor.setBendValue();
  sensor.setMappedValue();
  
  // Check user input routine
  if (activeGrace)
  {
    validationRoutine();
  }
  
  // Rewind ping sound
  if (!player.isPlaying())
  {
    player.rewind();
  }
  
  updateGUISliders();
}

// ==========================
//  CONTROLP5 EVENT HANDLING
// ==========================
public void MinCalibrate()
{
  calibrateSensorMin();
}

public void MaxCalibrate()
{
  calibrateSensorMax();
}

public void Next()
{
  if (currentDBIndex < 25)
  {
    currentDBIndex++;
    initialGrace = millis();
    activeGrace = true;
    sendCommand("VTO");
    textlabel2.setValue(db.signName[currentDBIndex]);
    if (currentDBIndex == 25)
    {
      disableButton("Next");
    }
    if (currentDBIndex != 0)
    {
      enableButton("Previous");
    }
  }
}

public void Previous()
{
  if (currentDBIndex > 0)
  {
    currentDBIndex--;
    initialGrace = millis();
    activeGrace = true;
    sendCommand("VTO");
    textlabel2.setValue(db.signName[currentDBIndex]);
    if (currentDBIndex == 0)
    {
      disableButton("Previous");
    }
    if (currentDBIndex != 25)
    {
      enableButton("Next");
    }
  }
}

public void StartStop()
{
  if (activeGrace)
  {
    activeGrace = false;
  }
  else
  {
    activeGrace = true;
    initialGrace = millis();
  }
}

public void Quit()
{
  sendCommand("QAP");
  exit();
}
