/*
 * adcinit.c
 *
 *  Created on: Oct 28, 2022
 *      Author: Hassan Islam 
 */

#include "adcinit.h"
#include "tm4c123gh6pm.h"

void adcinit(int chan, int adc_module)
{
    if (adc_module == 0) {

        SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOD;
        SYSCTL_RCGCADC_R |= SYSCTL_RCGCADC_R0;

        GPIO_PORTD_AFSEL_R |= chan;
        GPIO_PORTD_DEN_R &= ~chan;
        GPIO_PORTD_AMSEL_R |= chan;

        ADC0_ACTSS_R &= ~ADC_ACTSS_ASEN3; // disable sample sequencer 3

        ADC0_EMUX_R = (ADC0_EMUX_R & ~ADC_EMUX_EM3_M) | ADC_EMUX_EM3_PROCESSOR;  // software trigger
        ADC0_SSCTL3_R = ADC_SSCTL3_IE0 | ADC_SSCTL3_END0;  // set single sample, enable interrupt flag

        ADC0_ACTSS_R |= ADC_ACTSS_ASEN3; // enable sample sequencer 3

    }
    else if (adc_module == 1) {

        SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOD;
        SYSCTL_RCGCADC_R |= SYSCTL_RCGCADC_R1;

        GPIO_PORTD_AFSEL_R |= chan;
        GPIO_PORTD_DEN_R &= ~chan;
        GPIO_PORTD_AMSEL_R |= chan;

        ADC1_ACTSS_R &= ~ADC_ACTSS_ASEN3; // disable sample sequencer 3

        ADC1_EMUX_R = (ADC1_EMUX_R & ~ADC_EMUX_EM3_M) | ADC_EMUX_EM3_PROCESSOR;  // software trigger
        ADC1_SSCTL3_R = ADC_SSCTL3_IE0 | ADC_SSCTL3_END0;  // set single sample, enable interrupt flag

        ADC1_ACTSS_R |= ADC_ACTSS_ASEN3; // enable sample sequencer 3
    }
}
