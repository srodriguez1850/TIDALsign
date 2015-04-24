import processing.serial.*;
import controlP5.*;

Serial arduino;
ControlP5 controlp5;

Textlabel textlabel1;

void setup()
{
  // Setup window size and title
  size(640, 480);
  smooth();
  frame.setTitle("Sensor GUI");
  background(0);
  
  // Open Serial to arduino
  arduino = new Serial(this, Serial.list()[0], 19200);
  delay(3000);
  attemptHandshake();
  
  // Interface initializers
  controlp5 = new ControlP5(this);
  controlp5.addSlider("Thumb")
           .setRange(0, 1023)
           .setValue(500)
           .setPosition(100, 150)
           .setSize(100, 20);
  controlp5.addSlider("Index")
           .setRange(0, 1023)
           .setValue(500)
           .setPosition(100, 180)
           .setSize(100, 20);
  controlp5.addSlider("Middle")
           .setRange(0, 1023)
           .setValue(500)
           .setPosition(100, 210)
           .setSize(100, 20);
  controlp5.addSlider("Ring")
           .setRange(0, 1023)
           .setValue(500)
           .setPosition(100, 240)
           .setSize(100, 20);
  controlp5.addSlider("Pinky")
           .setRange(0, 1023)
           .setValue(500)
           .setPosition(100, 270)
           .setSize(100, 20);
  textlabel1 = controlp5.addTextlabel("Title")
                        .setText("Sensor GUI")
                        .setPosition(100, 100);
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
}

void draw()
{
  byte command[] = new byte[3];
  command[0] = 'R';
  command[1] = 'A';
  command[2] = '0';
  arduino.write(command);
  delay(25);
  // May have to exception handle vvvvv
  controlp5.getController("Thumb").setValue(Integer.parseInt(arduino.readStringUntil(10)));
}
