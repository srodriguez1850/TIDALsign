/*

Arduino Bend Sensor
Northwestern University
EECS 395: Tangible Interaction Design and Learning

Finger Assignments (Right Hand)
0 - Thumb
1 - Index
2 - Middle
3 - Ring
4 - Pinky
*/

// =====================
//  GLOBAL DECLARATIONS
// =====================
// Status LED declaration
#define LED 13
// Calibration sample amount
#define SAMPLE_AMOUNT 100
// Handshake bytes declarations
bool commActive = false;
byte handshake1;
byte handshake2;
byte handshake3;

// ==================
//  HELPER FUNCTIONS
// ==================
// Clears the serial buffer for new data
void serialFlush()
{
  while (Serial.available() > 0)
  {
    char a = Serial.read();
  }
}

void forceConnection()
{
  // Ensure a communication with the host before initializing the sensor
  while (!commActive)
  {
    // When the host sent a handshake, read bytes in
    if (Serial.available() >= 3)
    {
      handshake1 = Serial.read();
      handshake2 = Serial.read();
      handshake3 = Serial.read();
      
      // Verify bytes are "HI!", if they are, establish connection
      if ((handshake1 == 'H') && (handshake2 == 'I') && (handshake3 == '!'))
      {
        Serial.println("HELLO FROM ARDUINO");
        commActive = true;
      }
      else
      {
        serialFlush();
      }
    }
  }
}

void calibrateSensor()
{
  for (int i = 0; i < 5; i++)
  {
    unsigned long avg = 0;
    for (int j = 0; j < SAMPLE_AMOUNT; j++)
    {
      avg += analogRead(i);
    }
    avg = avg / SAMPLE_AMOUNT;
    Serial.println(avg, DEC);
  }
}

// ================
//  SETUP FUNCTION
// ================
void setup() {
  // LED high for initialization
  digitalWrite(LED, HIGH);
  
  // Set LED
  pinMode(LED, OUTPUT);
  
  // Open serial port at baud 19200
  Serial.begin(19200);
  
  // Initialize pins to read
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  
  // Flush serial to make sure it's empty
  serialFlush();
  
  // Force connection
  forceConnection();
  
  // LED low for initialization complete, won't got low if not connected
  digitalWrite(LED, LOW);
}

byte commBuffer1;
byte commBuffer2;
byte commBuffer3;

// ===============
//  MAIN FUNCTION
// ===============
void loop()
{  
  // Wait for commands
  if (Serial.available() == 3)
  {
    commBuffer1 = Serial.read();
    commBuffer2 = Serial.read();
    commBuffer3 = Serial.read();
    
    // Check what command was received
    switch (commBuffer1) {
      case 'C':
        if (commBuffer2 == 'A' && commBuffer3 == 'L')
        {
          // calibrate hand (Processing will determine position)
          // RUN A NESTED FOR LOOP FOR EVERY FINGER
          // CALIBRATE 100 SAMPLES BY AVERAGING
          digitalWrite(LED, HIGH);
          calibrateSensor();
          digitalWrite(LED, LOW);
          break;
        }
        else break;
      case 'R':
        switch (commBuffer2) {
          case 'A':
            switch (commBuffer3) {
              case 'A':
                Serial.println(analogRead(0), DEC);
                Serial.println(analogRead(1), DEC);
                Serial.println(analogRead(2), DEC);
                Serial.println(analogRead(3), DEC);
                Serial.println(analogRead(4), DEC);
                break;
              default:
                Serial.println(analogRead((int)(commBuffer3 - '0')), DEC);
                break;
            }
        }
      case 'Q':
        if (commBuffer2 == 'A' && commBuffer3 == 'P')
        {
          while (true)
          {
            // Quit command, freeze until hard reset
            digitalWrite(LED, HIGH);
            delay(250);
            digitalWrite(LED, LOW);
            delay(250);
          }
        }
    }
    // Clear buffers
    commBuffer1 = 0;
    commBuffer2 = 0;
    commBuffer3 = 0;
  }
}
