/* 
 * File:   writeToRam.c
 * Author: Kirsten Olsen
 *
 * Created on November 17, 2021, 3:50 PM
 * 
 * Purpose: Write RGB colors to RAM in FPGA
 */

#include <stdio.h>
#include <stdlib.h>
#include <xc.h>
#include <pic18f47k40.h>
#include <pic18.h>
#include <math.h>
#include <pic18_chip_select.h>
#include <time.h>

#pragma config RSTOSC = HFINTOSC_64MHZ //Set internal oscillator 64 MHz
#pragma config WDTE = OFF //Disable watchdog timer
#pragma config FEXTOSC = OFF
#pragma config LVP = ON //Ensure that it's using low voltage programming
#pragma config CLKOUTEN = ON 

/////////////////////// Definitions /////////////////////////
#define _XTAL_FREQ 64000000

//CLK Output
#define clk_out  PORTCbits.RC0


//Data Lines
#define data_flag LATDbits.LD3
#define out9 LATBbits.LB4
#define out8 LATBbits.LB3
#define out7 LATBbits.LB2
#define out6 LATBbits.LB1
#define out5 LATBbits.LB0
#define out4 LATDbits.LD7
#define out3 LATDbits.LD6
#define out2 LATDbits.LD5
#define out1 LATDbits.LD4
#define out0 LATCbits.LC5

#define wr_en LATCbits.LC4
#define go LATDbits.LD2
#define read_clk PORTCbits.RC1


/////////////////////// Global Variables /////////////////////////


////////////////////Function Declarations////////////////////

void data_lines_init(void);
void output_frame(void);
void output_RGB(void); 

/////////////////////////////Main/////////////////////////////
void main(void) {

    
   data_lines_init();
    
   while(1) { 
       output_frame();   
   }
} //main

void data_lines_init(void) {
    
    //CLK_OUT is at RC0
    CLKRCON = 0b00010010; // Divide source clk by 4 (125,000) 
    CLKRCLK = 0x03; //ref clk is 500kHz
    CLKRCON = 0b10010010; //ref clk module enabled
    PPSLOCK = 0b00000000; //unlock pps
    RC0PPS = 0x14; //Set RC0 to CLKR
        
    //Set Inputs & Outputs
    TRISCbits.TRISC0 = 0; //make sure clk_out is out
    TRISDbits.TRISD3 = 0; //data flag
    TRISBbits.TRISB4 = 0; //data lines
    TRISBbits.TRISB3 = 0;
    TRISBbits.TRISB2 = 0;
    TRISBbits.TRISB1 = 0;
    TRISBbits.TRISB0 = 0;
    TRISDbits.TRISD7 = 0;
    TRISDbits.TRISD6 = 0;
    TRISDbits.TRISD5 = 0;
    TRISDbits.TRISD4 = 0;
    TRISCbits.TRISC5 = 0;
    TRISCbits.TRISC4 = 0; //wr_en
    TRISDbits.TRISD2 = 0; //go signal to start writing
    TRISCbits.TRISC1 = 1; //fifo_ready is input

    //Set to Digital
    ANSELB = 0; 
    ANSELD = 0; 
    ANSELAbits.ANSELA6 = 0;
    ANSELCbits.ANSELC5 = 0; 
    ANSELCbits.ANSELC4 = 0;
    ANSELCbits.ANSELC0 = 0; //clk out
    ANSELCbits.ANSELC1 = 0; //fifo_ready
    
    
    
}
//Edit this function to take in address map and single frame matrix
void output_frame(void) {
    int i = 0;
    
    //Initialize Outputs
    data_flag = 0;
    wr_en = 0;
    out9 = 0;
    out8 = 0;
    out7 = 0;
    out6 = 0;
    out5 = 0;
    out4 = 0;
    out3 = 0;
    out2 = 0;
    out1 = 0;
    out0 = 0;
    go = 0;
    
    go = 1; //Starts ram_write in FPGA
    //for (i = 0; i < 1024; i++) { 
        //Modify this into a nested loop to send out entire frame byte by byte
        output_RGB(); //1024
    //}
    go = 0; //stop writing to RAM after frame is sent (will continuously output frame to leds until written to again)
}

//Edit this function to send out the data flag, 10 data bits, wr_en
//Use output_frame to feed into this function
void output_RGB(void) {
  
//First LED: RED at addr 1
  //Send Address (0x01)

    data_flag = 0;
    out9 = 0;
    out8 = 0;
    out7 = 0;
    out6 = 0;
    out5 = 0;
    out4 = 0;
    out3 = 0;
    out2 = 0;
    out1 = 0;
    out0 = 1; 
    
    while(!(clk_out)); //This doesn't work completely but its the best so far
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;
    

    
  //Send B data (0x00)

    data_flag = 1;
    out9 = 1;
    out8 = 1;
    out7 = 1;
    out6 = 1;
    out5 = 1;
    out4 = 1;
    out3 = 1;
    out2 = 1;
    out1 = 1;
    out0 = 1;


    while(!(clk_out));
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;
    

   //Send G data (0x00)

    out9 = 1;
    out8 = 1;
    out7 = 1;
    out6 = 1;
    out5 = 1;
    out4 = 1;
    out3 = 1;
    out2 = 1;
    out1 = 1;
    out0 = 1;
    
    while(!(clk_out));
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;
    

   //Send R data (0x00)

    out9 = 1;
    out8 = 1;
    out7 = 1;
    out6 = 1;
    out5 = 1;
    out4 = 1;
    out3 = 1;
    out2 = 1;
    out1 = 1;
    out0 = 1;

    while(!(clk_out));
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;
    
//  //Second LED WHITE @ 65
//      //Send Address (65)

    data_flag = 0;
    out9 = 0;
    out8 = 0;
    out7 = 0;
    out6 = 1;
    out5 = 0;
    out4 = 0;
    out3 = 0;
    out2 = 0;
    out1 = 0;
    out0 = 1;
    
    while(!(clk_out));
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;
    

    
  //Send B data (0x00)

    data_flag = 1;
    out9 = 1;
    out8 = 1;
    out7 = 1;
    out6 = 1;
    out5 = 1;
    out4 = 1;
    out3 = 1;
    out2 = 1;
    out1 = 1;
    out0 = 1;

    while(!(clk_out));
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;
    

   //Send G data (0x00)

    out9 = 1;
    out8 = 1;
    out7 = 1;
    out6 = 1;
    out5 = 1;
    out4 = 1;
    out3 = 1;
    out2 = 1;
    out1 = 1;
    out0 = 1;
    
    while(!(clk_out));
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;
    

   //Send R data (0x00)

    out9 = 1;
    out8 = 1;
    out7 = 1;
    out6 = 1;
    out5 = 1;
    out4 = 1;
    out3 = 1;
    out2 = 1;
    out1 = 1;
    out0 = 1;

    while(!(clk_out));
    while(clk_out) {
       wr_en = 1;
    }
    wr_en = 0;

    go = 0;

    __delay_us(10);
    //MAKE SURE OUTPUTS ARE SET TO 0 AFTER USING
}