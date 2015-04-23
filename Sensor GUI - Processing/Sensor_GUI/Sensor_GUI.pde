import processing.serial.*;

Serial myPort;

void setup()
{
  size(200, 200);
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 19200);
}

boolean flag = false;

void draw()
{
  if (mousePressed == true)
  {
    if (!flag)
    {
      myPort.write('H');
      myPort.write('I');
      myPort.write('!');
      println("Sent HI!");
      delay(200);
      println(myPort.readString());
      flag = true;
    }
    else
    {
      myPort.write('R');
      myPort.write('A');
      myPort.write('0');
      delay(200);
      print("Data: ");
      println(myPort.readString());
    }
  }
}
