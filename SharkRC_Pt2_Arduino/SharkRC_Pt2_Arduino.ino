
/*
Barbara Compagnoni
Wireless Toys Final Sound RC SHARK PT2
Spring 2014
 */


#include <SPI.h>

//Add the SdFat Libraries
#include <SdFat.h>
#include <SdFatUtil.h>

//and the MP3 Shield Library
#include <SFEMP3Shield.h>

//Instancing the SD Card
SdFat sd;

//Instance the SFEMP3Shield
SFEMP3Shield MP3player;


void setup(){
  
  if(!sd.begin(SD_SEL, SPI_HALF_SPEED)) sd.initErrorHalt(); // newly required in 1.01.00 and higher
  if(MP3player.begin() != 0) {
    Serial.print(F("ERROR"));
  }

  Serial.begin(9600);
  
  //Initialize the MP3 Player Shield 
  MP3player.begin();
}

void loop() {
  
  //make sure mp3 player is available
  MP3player.available();
  
  //set volume to max
  MP3player.setVolume(254);
  
   // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  
  // print out the value you read:
  Serial.println(sensorValue);
  delay(1);
  
  if(sensorValue > 100){
    //tell the MP3 Shield to play a track
    MP3player.playTrack(3);
  }
 
}

