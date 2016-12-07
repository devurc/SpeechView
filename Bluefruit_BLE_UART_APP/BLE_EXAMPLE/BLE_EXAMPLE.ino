/*********************************************************************
  dang ol getter done
*********************************************************************/

#include <Adafruit_SSD1306.h>

Adafruit_SSD1306 display = Adafruit_SSD1306();

#include "Adafruit_BLE.h"
#include "Adafruit_BluefruitLE_SPI.h"
#include "Adafruit_BluefruitLE_UART.h"
#include "BluefruitConfig.h"

/*=========================================================================
    APPLICATION SETTINGS

      FACTORYRESET_ENABLE       Perform a factory reset when running this sketch

    MODE_LED_BEHAVIOUR        LED activity, valid options are
                              "DISABLE" or "MODE" or "BLEUART" or
                              "HWUART"  or "SPI"  or "MANUAL"
    -----------------------------------------------------------------------*/
#define FACTORYRESET_ENABLE         1
#define MINIMUM_FIRMWARE_VERSION    "0.6.6"
#define MODE_LED_BEHAVIOUR          "BLEUART"
/*=========================================================================*/

/* ...hardware SPI, using SCK/MOSI/MISO hardware SPI pins and then user selected CS/IRQ/RST */
Adafruit_BluefruitLE_SPI ble(BLUEFRUIT_SPI_CS, BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);


void setup(void)
{
  // by default, we'll generate the high voltage from the 3.3v line internally! (neat!)
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);  // initialize with the I2C addr 0x3C (for the 128x32)

  // Clear the buffer.
  display.clearDisplay();
  display.display();
  display.setCursor(0, 0);

  if ( !ble.begin(VERBOSE_MODE) )
  {
    //  error(F("Couldn't find Bluefruit, make sure it's in CoMmanD mode & check wiring?"));
  }

  /* Disable command echo from Bluefruit */
  ble.echo(false);
  /* Print Bluefruit information */
  ble.info();

  ble.verbose(false);  // debug info is a little annoying after this point!

  /* Wait for connection */
  while (! ble.isConnected()) {
    delay(500);
  }

}

//RECIEVE TEXT:

char WordCount = 0;       //for checking if the screen is full
char LineCount = 21;      //line size is 21 characters

void loop(void)
{
  // Check for user input
  char inputs[BUFSIZE + 1];


  // Check for incoming characters from Bluefruit
  ble.println("AT+BLEUARTRX");
  ble.readline();
  
  if (strcmp(ble.buffer, "OK") == 0) {      // no data
    return;
  }
  
  // Some data was found, its in the buffer
  
  display.setTextSize(1);
  display.setTextColor(WHITE);
  
/*************************************************************************
 * INSERT CODE TO BREAK INCOMING MESSAGES INTO PACKETS <21 CHARACTERS LONG
 *************************************************************************/

  //THE FOLLOWING CODE ASSUMES THAT LESS THAN 21 CHARACTERS AT A TIME ARE BEING SENT!!!!!


  if (LineCount < (strlen(ble.buffer)) + 1) {       //there isnt enough room on the line?

    WordCount = WordCount + LineCount + strlen(ble.buffer) + 1;        //update the screens count
    // count  = (prev) + (spaces skipped) + word + space
    LineCount = 21 - strlen(ble.buffer) - 1;                           //re-initialize line count

    if (WordCount >= 84) {                      //test if it fits on the screen
      delay(200);                           //give a little pause to see the last word
      display.clearDisplay();                   //if the screen is full, clearscreen
      display.setCursor(0, 0);
      display.print(ble.buffer);                  //print next word
      display.print(" ");
      WordCount = strlen(ble.buffer) + 1; //update the count
    }
    else {
      display.println(" ");                     //no: starts a new line
      display.print(ble.buffer);                  //print next word
      display.print(" ");                         //prints a space
    }
  }
  else if (LineCount == (strlen(ble.buffer)) + 1) {      //is there exactly enough room?
    display.println(ble.buffer);                  //prints
    WordCount = WordCount + LineCount;        //update the screens count
    LineCount = 21;                           //re-initialize line count
  }
  else if (LineCount > (strlen(ble.buffer)) + 1) {       //there is enough room
    display.print(ble.buffer);                  //print next word
    display.print(" ");                         //prints a space
    LineCount = LineCount - strlen(ble.buffer) - 1;   //update the linecount
    if (LineCount <= 0) {                           //if its the end of the line, reinitialize
      LineCount = 21;
    }
    WordCount = WordCount + strlen(ble.buffer) + 1; //update the count
  }

  display.display(); // actually display all of the above
}

