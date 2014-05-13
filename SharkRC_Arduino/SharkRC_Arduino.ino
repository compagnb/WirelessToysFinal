/*
Barbara Compagnoni
Wireless Toys Final Sound RC SHARK PT1
Spring 2014
*/

//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>
#include <Servo.h> 
 
#define DIGITAL_OUT_PIN    4
#define DIGITAL_IN_PIN     2//5
#define PWM_PIN            6
#define SERVO_PIN          7
#define ANALOG_IN_PIN      A5

Servo rtWheel;
Servo lftWheel;
Servo tail;
Servo bite;
int pos = 0;    // variable to store the servo position


void setup()
{
  // Default pins set to 9 and 8 for REQN and RDYN
  // Set your REQN and RDYN here before ble_begin() if you need
  //ble_set_pins(3, 2);
  
  // Init. and start BLE library.
  ble_begin();
  
  // Enable serial debug
  Serial.begin(57600);
  
  pinMode(DIGITAL_OUT_PIN, OUTPUT);
  pinMode(DIGITAL_IN_PIN, INPUT);
  
  // Default to internally pull high, change it if you need
  digitalWrite(DIGITAL_IN_PIN, HIGH);
  //digitalWrite(DIGITAL_IN_PIN, LOW);
  
  rtWheel.attach(7);
  lftWheel.attach(6);
  //tail.attach(5);
  //bite.attach(3);
   
}

void loop()
{
  static boolean analog_enabled = false;
  static byte old_state = LOW;
  
  
  // If data is ready
  while(ble_available())
  {
    //tailWave();
    // read out command and data
    byte data0 = ble_read();
    byte data1 = ble_read();
    byte data2 = ble_read();
    
    if (data0 == 0x01)  // Command is to control digital out pin
    {
      if (data1 == 0x01)
        digitalWrite(DIGITAL_OUT_PIN, HIGH);
      else
        digitalWrite(DIGITAL_OUT_PIN, LOW);
    }
    else if (data0 == 0xA0) // Command is to enable analog in reading
    {
      if (data1 == 0x01)
        analog_enabled = true;
      else
        analog_enabled = false;
    }
    else if (data0 == 0x02) // Command is to control PWM pin
    {
      lftWheel.write(data1);
    }
    else if (data0 == 0x03)  // Command is to control Servo pin
    {
      rtWheel.write(data1);
    } 
      else if (data0 == 0x04)  // Command is to control bite 
    {
      analog_enabled = false;
      rtWheel.write(0);
      lftWheel.write(0);
      bite.write(0);
      analogWrite(PWM_PIN, 0);
      digitalWrite(DIGITAL_OUT_PIN, LOW);
    }
  }
  
  if (analog_enabled)  // if analog reading enabled
  {
    // Read and send out
    uint16_t value = analogRead(ANALOG_IN_PIN); 
    ble_write(0x0B);
    ble_write(value >> 8);
    ble_write(value);
  }
  
  // If digital in changes, report the state
  if (digitalRead(DIGITAL_IN_PIN) != old_state)
  {
    old_state = digitalRead(DIGITAL_IN_PIN);
    
    if (digitalRead(DIGITAL_IN_PIN) == HIGH)
    {
      ble_write(0x0A);
      ble_write(0x01);
      ble_write(0x00);    
    }
    else
    {
      ble_write(0x0A);
      ble_write(0x00);
      ble_write(0x00);
    }
  }
  
  if (!ble_connected())
  {
    analog_enabled = false;
    digitalWrite(DIGITAL_OUT_PIN, LOW);
  }
  
  // Allow BLE Shield to send/receive data
  ble_do_events();  
}

//void tailWave(){
//    //tailWave
//  for(pos = 90; pos <= 180; pos += 1) // goes from 0 degrees to 180 degrees 
//  {                                  // in steps of 1 degree 
//    tail.write(pos);              // tell servo to go to position in variable 'pos' 
//    delay(15);                       // waits 15ms for the servo to reach the position 
//  } 
//  for(pos = 180; pos>=90; pos-=1)     // goes from 180 degrees to 0 degrees 
//  {                                
//    tail.write(pos);              // tell servo to go to position in variable 'pos' 
//    delay(15);                       // waits 15ms for the servo to reach the position 
//  } 
//}



