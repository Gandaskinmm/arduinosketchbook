#include <Wire.h>
#include "RTClib.h"
RTC_DS1307 RTC;
void setupRTC()
{
    Wire.begin();
    RTC.begin();

    if(! RTC.isrunning()) 
    {
        Serial.println("RTC is NOT running!");
        // following line sets the RTC to the date & time this sketch was compiled
        RTC.adjust(DateTime(__DATE__, __TIME__));
        delay(100);
    }

}

/* needs testing! done a basic test for 2013 and think it will work for this application.

UK rules:
last Sunday in March Forward by 1 hour at 01:00
last Sunday in October Backwards by 1 hour 01:00 
*/
boolean isBST(int day, int month, int dow)
    {
        //January, february, and december are out.
        if (month < 3 || month > 10) { return false; }
        //April to October are in
        if (month > 3 && month < 10) { return true; }
        int previousSunday = day - dow;
        //In march, we are DST if our previous sunday was after the 24th.
        if (month == 3) { return previousSunday > 24; }
        //In october we must be before the last sunday to be dst.
        //That means the previous sunday must be after the 23rd.
        return previousSunday > 23;
}

void updateTime(int year,int month,int day,int hour,int min,int sec)
{
  Serial.print(year); Serial.print(",");
  Serial.print(month); Serial.print(",");  
  Serial.print(day); Serial.print(",");
  Serial.print(hour); Serial.print(",");
  Serial.print(min); Serial.print(",");   
  Serial.println(sec); 
  RTC.adjust(DateTime(year,month,day,hour,min,sec));
}

struct time getTime()
{
    DateTime now = RTC.now();
    struct time t;
    if( now.hour() == 165)    
    {
        Serial.println("RTC error!");
        t.min = -1;
        t.hour = -1;
        return t;
    }

    t.min = now.minute();
    t.hour = now.hour();

    if( isBST(now.day(),now.month(),now.dayOfWeek()) )
    {
      Serial.print("BST,");
      t.hour += 1;
      if( t.hour >23 )
        t.hour = 0;
    }
    else
    {
       Serial.print("GMT,");
    }

    Serial.print(now.year(), DEC);
    Serial.print('/');
    Serial.print(now.month(), DEC);
    Serial.print('/');
    Serial.print(now.day(), DEC);
    Serial.print(' ');
    Serial.print(t.hour, DEC);
    Serial.print(':');
    Serial.print(now.minute(), DEC);
    Serial.print(':');
    Serial.print(now.second(), DEC);
    Serial.println();
      
    return t;
}
