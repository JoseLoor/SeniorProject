/*
 * File:   newmain.c
 * Author: jose_
 *
 * Created on October 29, 2021, 11:17 AM
 */

// PIC18F47K40 Configuration Bit Settings

// 'C' source line config statements

#include <xc.h>
#include <stdio.h>
#include <stdlib.h>
#include <xc.h>
#include <pic18f47k40.h>
#include <pic18.h>
#include <math.h>
#include <pic18_chip_select.h>
#include <time.h>
#include "led_drive.h"

#pragma config RSTOSC = HFINTOSC_64MHZ //Set internal oscillator 64 MHz
#pragma config WDTE = OFF //Disable watchdog timer
#pragma config FEXTOSC = OFF
#pragma config LVP = ON //Ensure that it's using low voltage programming

#define _XTAL_FREQ 64000000

//buttons
#define sel_butt PORTDbits.RD1

void main() //The main function
{
    //Set Inputs & Outputs
    TRISDbits.TRISD1 = 1; //buttons
    
    //Set to Digital
    ANSELDbits.ANSELD1 = 0; //Buttons
    
    TRISB=0X00; //Instruct the MCU that the PORTB pins are used as Output.
    PORTB=0X00; //Make all output of RB3 LOW

    while(1) //Get into the Infinite While loop
    {
        if (sel_butt == 1)
        {
            display_win();
        }
        /*
         RB3=1; //LED ON
        __delay_ms(500); //Wait
        RB3=0; //LED OFF
        __delay_ms(500); //Wait

        //Repeat. 
         */
        
    }

}
