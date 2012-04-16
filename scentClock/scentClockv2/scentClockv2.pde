
/* 
 todo:
 */
#include <EEPROM.h>
//#include <Time.h>  
//#include <Wire.h>  
//#include <DS1307RTC.h>  // a basic DS1307 library that returns time as a time_t


#define HEATER1 3
#define HEATER2 5
#define HEATER3 6
#define STATUS_LED 8
#define FAN 9
#define SWITCH 2

#define MAXHEATVAL 30
#define MAXHEATTIME 7200

int heatVal;
int heatTime;
int ventOpenDelay;
int ventOpenTime;
int fanVal;
int switchInterval;

void setup()
{
  pinMode(STATUS_LED, OUTPUT );
  
  flashLED(); 
  flashLED();
  
  pinMode(SWITCH, INPUT );
  digitalWrite( SWITCH, HIGH ); 

  analogWrite( HEATER1, 0 );
  analogWrite( HEATER2, 0 );
  analogWrite( HEATER3, 0 );

  analogWrite( FAN, 0 );

  Serial.begin(9600);
  Serial.println( "scent clock" );

  Serial.println( "loading vals from eeprom...");
  readFromEeprom();

}

void flashLED()
{
  digitalWrite( STATUS_LED, HIGH);
  delay(100);
  digitalWrite( STATUS_LED, LOW );
}
void readParams()
{
  char command = Serial.read();
  if( command == 'A' )
  {
    delay(100);

    //all these are ints
    heatVal = serReadInt();
    //some safety
    if( heatVal > MAXHEATVAL )
      heatVal = MAXHEATVAL;
      
    heatTime = serReadInt();
    //some safety
    if( heatTime > MAXHEATTIME )
      heatTime = MAXHEATTIME;
      
    ventOpenDelay = serReadInt();
    ventOpenTime = serReadInt();
    fanVal = serReadInt();
    switchInterval = serReadInt();
    //write them all to eeprom
    writeToEeprom();

    flashLED();    

  }
  else if( command == 'B' )
  {
    printVals();
    flashLED();

  }
  else if( command == 'C' )
  {
    delay(100);
    int releaseNum = serReadInt();
    flashLED();
    releaseScent(releaseNum);

  }
  else
  {
    //flush serial port
    while( Serial.available() )
    {
      Serial.read();
    }
  }
}
void loop()
{
  if( digitalRead( SWITCH ) == LOW )
  {
    Serial.println( "switch pressed" );
    for( int i = 1; i <= 3; i ++ )
    {
      releaseScent(i);
      delay( switchInterval * 1000 );
    }
  }
  if( Serial.available() )
  {
    readParams();
  }
}

void releaseScent(int scent)
{
  Serial.print( "releasing scent: " );
  Serial.println( scent, DEC );
  Serial.print( "turning on heater: " );
  Serial.println( heatVal );
  int HEATER;
  if( scent == 1 )
    HEATER = HEATER1;
  if( scent == 2 )
    HEATER = HEATER2;
  if( scent == 3 )
    HEATER = HEATER3;

  analogWrite( HEATER, heatVal );
  int time = 0;
  boolean heatOn = true;
  boolean ventOpen = false;
  while( heatOn || ventOpen)
  {
    if( time == heatTime )
    {
      Serial.println( "turning off heater" );
      analogWrite( HEATER, 0 );
      heatOn = false;
    }
    if( time == ventOpenDelay )
    {
      if( fanVal != 0 )
      {
        Serial.print( "turning on fan: " );
        Serial.println( fanVal );
        analogWrite( FAN, convertFanVal(fanVal) );
        ventOpen = true;
      }
    }
    if( time == ventOpenDelay + ventOpenTime )
    {    
      Serial.println( "turning off fan" );
      analogWrite( FAN, 0 ); 
      ventOpen = false;
    }
    delay(1000);
    Serial.print( "t=" );
    time ++;
    Serial.println( time, DEC );

  }
  Serial.println( "finished" );
}

int convertFanVal( int fan )
{
  return fan += 155;
}

