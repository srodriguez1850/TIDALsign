/*

Arduino Bend Sensor
Northwestern University
EECS 395: Tangible Interaction Design and Learning

Bend Sensor Pin Assignments
A0 - Thumb
A1 - Index
A2 - Middle
A3 - Ring
A4 - Pinky

Vibration Motor Pin Assignments
2 - Thumb
3 - Index
4 - Middle
5 - Ring
6 - Pinky

*/

// =====================
//  GLOBAL DECLARATIONS
// =====================
// Status LED declaration
#define LED 13
// Calibration sample amount
#define SAMPLE_AMOUNT 100
// Vibration length
#define VIBRATION_PERIOD 500
// Handshake byte declarations
bool commActive = false;
byte handshake1;
byte handshake2;
byte handshake3;
// Command byte declarations
byte commBuffer1;
byte commBuffer2;
byte commBuffer3;
// Vibration flag
bool vibrActive = false;
// Vibration start time
unsigned long vibrTime = 0;

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

void checkVibration()
{
  if (vibrActive)
  {
    if (millis() - vibrTime > VIBRATION_PERIOD)
    {
      for (int i = 0; i < 5; i++)
      {
        digitalWrite(i + 2, LOW);
      }
      vibrActive = false;
    }
  }
}

// ================
//  SETUP FUNCTION
// ================
void setup() {
  // Set LED
  pinMode(LED, OUTPUT);
  
  // LED high for initialization
  digitalWrite(LED, HIGH);
  
  // Open serial port at baud 38400
  Serial.begin(38400);
  
  // Initialize pins to read
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  
  // Initialize pins to vibrate
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  
  // Initialize vibration pins low
  for (int i = 0; i < 5; i++)
  {
    digitalWrite(i + 2, LOW);
  }
  
  // Flush serial to make sure it's empty
  serialFlush();
  
  // Force connection
  forceConnection();
  
  // LED low for initialization complete, won't got low if not connected
  digitalWrite(LED, LOW);
}

// ===============
//  MAIN FUNCTION
// ===============
void loop()
{
  // Check if vibration is running
  checkVibration();
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
      case 'V':
        if (commBuffer2 == 'T' && commBuffer3 == 'O')
        {
          for (int i = 0; i < 5; i++)
          {
            digitalWrite(i + 2, LOW);
          }
          vibrActive = false;
          vibrTime = 0;
          break;
        }
        switch (commBuffer2) {
          case 'D':
          {
            // grab char in buffer, turn into binary, and read bits 0 to 4
            String motors = String(commBuffer3, BIN).substring(1);
            for (int i = 0; i < 5; i++)
            {
              if (motors[i] == '0')
              {
                digitalWrite(i + 2, HIGH);
              }
              else
              {
                digitalWrite(i + 2, LOW);
              }
            }
            vibrActive = true;
            vibrTime = millis();
            break;
          }
          case 'S':
          {
            // case stagerred, quarter of a second per finger
            String motors = String(commBuffer3, BIN).substring(1);
            for (int i = 0; i < 5; i++)
            {
              if (motors[i] == '0')
              {
                digitalWrite(i + 2, HIGH);
                delay(250);
                digitalWrite(i + 2, LOW);
              }
              else
              {
                digitalWrite(i + 2, LOW);
              }
            }
            // send command through buffer to continue operation
            break;
          }
          case 'A':
            // analog vibration, use pwm pins but find a way to encode
            break;
          default:
            break;
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
