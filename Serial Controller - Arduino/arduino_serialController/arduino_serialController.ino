/*

SENSOR GUI
EECS 395: Tangible Interaction Design and Learning

*/

/*
*  HELPER FUNCTIONS
*/
// Clears the serial buffer for new data
void serialFlush()
{
  while (Serial.available() > 0)
  {
    char a = Serial.read();
  }
}

// Status LED declaration
int LED = 13;

void setup() {
  // LED high for initialization
  digitalWrite(LED, HIGH);
  
  // Set LED
  pinMode(LED, OUTPUT);
  
  // Open serial port at baud 19200
  Serial.begin(19200);
  
  // Initialize pins to read
  pinMode(A0, INPUT);
  
  // Flush serial to make sure it's empty
  serialFlush();
  
  // LED low for initialization complete
  digitalWrite(LED, LOW);
}

// Handshake bytes declarations
bool commActive = false;
byte handshake1;
byte handshake2;
byte handshake3;

byte commBuffer1;
byte commBuffer2;
byte commBuffer3;

void loop() {
  // Ensure a communication with the host before initializing the sensor
  while (!commActive)
  {
    // When the host sent a handshake, read bytes in
    if (Serial.available() == 3)
    {
      handshake1 = Serial.read(); delay(5);
      handshake2 = Serial.read(); delay(5);
      handshake3 = Serial.read(); delay(5);
      
      // Verify bytes are "HI!", if they are, establish connection
      if ((handshake1 == 'H') && (handshake2 == 'I') && (handshake3 == '!'))
      {
        Serial.print("HELLO FROM ARDUINO");
        commActive = true;
      }
    }
    // Flush any useless serial data
    //serialFlush();
  }
  
  // Wait for commands
  if (Serial.available() == 3)
  {
    commBuffer1 = Serial.read(); delay(1);
    commBuffer2 = Serial.read(); delay(1);
    commBuffer3 = Serial.read(); delay(1);
    
    // Check what command was received
    // NOT WORKING, WILL HAVE TO WAIT
    /*switch (commBuffer1) {
      case 'R':
        switch (commBuffer2) {
          case 'A':
            switch (commBuffer3) {
              case '0':
                Serial.print(analogRead(A0));
                break;
            }
        }
    }
    */
    if ((commBuffer1 == 'R') && (commBuffer2 == 'A') && (commBuffer3 == '0'))
    {
      Serial.print(analogRead(A0), DEC);
    }
  }
}
