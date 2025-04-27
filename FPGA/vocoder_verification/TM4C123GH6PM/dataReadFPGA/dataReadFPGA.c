/*
    Name:       dataRead_FPGA.ino
    Created:	2024-03-06 5:19:12 PM
    Author:     Hassan Islam
    descp: Samples N bytes of data streamed from FPGA. 
           Used as a testbench. Data is printed via serial communication
           on COMM port. Data is then read over COMM port via MATLAB 
*/

//#define DEBUG

#ifndef DEBUG

#include <tm4c123gh6pm.h>
#include "adcSample.h"
#include "adcinit.h"


#define LIVE_SAMPLE
/*
    Enabling this allows for sampled binary data to be streamed directly to the serial monitor. (live tracking)
    but due to limitations of the serial port speed, data transfer speeds must be reduced.
    If disabled, data transfer is only limited by the ADC sampling and clock speed of the microcontroller,
    but will only display the specified amount of samples when a push button is pressed.
*/

/* pin assignments */
constexpr uint8_t  _CLKCHAN = 0, // ADC channel for clock signal
                   _DATACHAN = 1, // ADC channel for data signal
                   _DATACAPTURE = 2, // ADC channel for data capture signal
                   _ADCMODULE0 = 0, // ADC module 0 
                   _ADCMODULE1 = 1, // ADC module 1
                   _DATAVALID = 4; // ADC channel for data valid signal

uint16_t const _SAMPLE_SIZE = 16,  // bit size of sampled data
              _NUM_OF_SAMPLES = 1024, // number of samples to be recorded
              _PERIOD_MS = 1; // ms delay between serial prints

bool databuff,    // buffer stores value before loading into data array
     data[_NUM_OF_SAMPLES * _SAMPLE_SIZE],  // stores data values from FPGA
     data_valid;

// clk signal 
typedef struct clk {
    bool last, // stores last value of clk 
         now, // stores current value of clk
         positiveEdge;
};

#ifndef LIVE_SAMPLE

typedef struct button {
    bool last = 1,
        now,
        positiveEdge;
};

button button1;

#endif 
     
clk clkin; // FPGA clock signal 
uint16_t i = 0; // iterator 

void setup() {
    Serial.begin(1000000);

    adcinit(_CLKCHAN, _ADCMODULE0); // initialize channel for clock signal PE3
    adcinit(_DATACHAN, _ADCMODULE1); // initialize channel for data signal  PE2
    adcinit(_DATACAPTURE, _ADCMODULE0); // initialize channel for data capture control signal PE1
    adcinit(_DATAVALID, _ADCMODULE1);  // initialize channel for data valid control signal PD3
 
    clkin.last = adcSample(_CLKCHAN,_ADCMODULE0); // store previous value of clock for positive edge detection

    delay(100);
}

void loop() {

    /* 
        Usage notes
        1.  Data must be sent on a negative edge. 
            This alows for data to be stable at the recieving end where it is read at the positive edge. 
        2.  Allow for atleast 1 clock cycle to be recieved before enabling data transfer. 
            This prevents data read errors on initialization at the recieving end. 
    */

    i = 0;
   
    while (i < _NUM_OF_SAMPLES*_SAMPLE_SIZE) {

        clkin.now = adcSample(_CLKCHAN, _ADCMODULE0); // high frequency and therefore must be sampled using adcSample()

        clkin.positiveEdge = clkin.now && !clkin.last; // data is read on the positive edge of clock in 

        data_valid = adcSample(_DATAVALID, _ADCMODULE1);

        databuff = adcSample(_DATACHAN, _ADCMODULE1); // value is read and stored in data buffer

        if (clkin.positiveEdge && data_valid ) { //load data at positive edge of clock

# ifdef LIVE_SAMPLE

              Serial.print(databuff, BIN);//Serial.print(digitalRead(_PIN5), BIN);
              i++;
              // space delimit each word
                  if ((!(i % _SAMPLE_SIZE))) {
                      Serial.print(" "); i = 0;
                  }
              

# else
                data[i] = databuff;
                i++;
# endif 

        }
        clkin.last = clkin.now;

    }

    for (int i = 0; i < _NUM_OF_SAMPLES * _SAMPLE_SIZE; i++) {

        // space delimit each word
        if ((!(i % _SAMPLE_SIZE))) {
            Serial.print(" ");
        }

        // stream to serial COMM port
        Serial.print(data[i], BIN);

        delay(_PERIOD_MS);

    }

    Serial.print("\n\nSAMPLES CAPTURED\n\n");


#ifndef LIVE_SAMPLE

    // sampling control signal. When pressed, a sample is captured

    button1.now = adcSample(_DATACAPTURE,0);

    button1.positiveEdge = button1.now && !button1.last;

    while (!button1.positiveEdge) {

        button1.now = adcSample(_DATACAPTURE,0);

        button1.positiveEdge = button1.now && !button1.last;

        button1.last = button1.now;

    }
    button1.last = button1.now;

#endif 


}

#endif


///////////////////////////////////////////////////////////////////////////////////////Debugging


#ifdef DEBUG

#include <tm4c123gh6pm.h>
#include "adcSample.h"
#include "adcinit.h"
#include "adcSample.c"
#include "adcinit.c"

constexpr auto SAMPLE_CHAN = 1; 

/* pin assignments */
constexpr uint8_t __PIN5 = 5, // pin for data output from FPGA
__PIN6 = 6, // pin for clk signal from FPGA
__PIN8 = 8, // control signal from FPGA
__PUSH = PUSH1;

int ADC_result;

typedef struct button {
    bool last = 1,
        now,
        negativeEdge;
};

button button1;


void setup() {
    Serial.begin(921600);
    adcinit(1,0); // brown cable
   //adcinit(0); // purple cable

}


void loop() {
    
   ADC_result = adcSample(1,0); // brown cable
   Serial.println(ADC_result);
}

#endif
