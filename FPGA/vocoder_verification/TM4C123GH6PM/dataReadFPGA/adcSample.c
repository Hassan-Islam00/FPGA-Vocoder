/*
 * adcSample.c
 *
 *  Created on: Oct 28, 2022
 *      Author: Hassan Islam
 */

#include "adcSample.h"
#include "tm4c123gh6pm.h"

int adcSample(int chan, int adc_module)
{
    if (adc_module == 0) {

        ADC0_SSMUX3_R = chan;  // select channel to be sampled by sequencer 3

        volatile int result;

        ADC0_PSSI_R = ADC_PSSI_SS3;

        while ((ADC0_RIS_R & ADC_RIS_INR3) == 0) {}  // wait for conversion to complete (poll interrupt flag)

        ADC0_ISC_R = ADC_ISC_IN3;  // clear the sequencer 3 interrupt flag

        result = ADC0_SSFIFO3_R; // retrieve conversion result from sequencer 3 FIFO

        if (result > 4096 / 2)
            return 1;
        else
            return 0;
    }
    else if (adc_module == 1) {

        ADC1_SSMUX3_R = chan;  // select channel to be sampled by sequencer 3

        volatile int result;

        ADC1_PSSI_R = ADC_PSSI_SS3;

        while ((ADC1_RIS_R & ADC_RIS_INR3) == 0) {}  // wait for conversion to complete (poll interrupt flag)

        ADC1_ISC_R = ADC_ISC_IN3;  // clear the sequencer 3 interrupt flag

        result = ADC1_SSFIFO3_R; // retrieve conversion result from sequencer 3 FIFO

        if (result > 4096 / 2)
            return 1;
        else
            return 0;
    }

    else return 0; 

}
