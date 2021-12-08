/* 
 * File:   frame_ctrl.c
 * Author: Kirsten Olsen
 *
 * Created on November 17, 2021, 3:50 PM
 * 
 * Purpose: Tell FPGA which frames to display 
 *          and write to individual LEDs
 */

#include <stdio.h>
#include <stdlib.h>
#include <xc.h>
#include <pic18f47k40.h>
#include <pic18.h>
#include <math.h>
#include <pic18_chip_select.h>
#include <time.h>

#include "frame_ctrl.h"

#pragma config RSTOSC = HFINTOSC_64MHZ //Set internal oscillator 64 MHz
#pragma config WDTE = OFF //Disable watchdog timer
#pragma config FEXTOSC = OFF
#pragma config LVP = ON //Ensure that it's using low voltage programming
#pragma config CLKOUTEN = ON 

/////////////////////// Definitions /////////////////////////
#define _XTAL_FREQ 64000000

    //Frame Data Lines
    #define sel7 LATBbits.LB4
    #define sel6 LATBbits.LB3
    #define sel5 LATBbits.LB2
    #define sel4 LATBbits.LB1
    #define sel3 LATBbits.LB0
    #define sel2 LATDbits.LD7
    #define sel1 LATDbits.LD6
    #define sel0 LATDbits.LD5
    #define go_frame LATCbits.LC5

    //Write LED Data Lines
    #define data_flag LATDbits.LD2
    #define out9 LATAbits.LA5
    #define out8 LATEbits.LE0
    #define out7 LATEbits.LE1
    #define out6 LATEbits.LE2
    #define out5 LATCbits.LC0
    #define out4 LATCbits.LC1
    #define out3 LATCbits.LC2
    #define out2 LATCbits.LC3
    #define out1 LATDbits.LD0
    #define out0 LATDbits.LD1

    #define wr_en LATDbits.LD3
    #define go_write LATCbits.LC4
    #define clk PORTBbits.RB5

/////////////////////// Global Variables /////////////////////////


/////////////////////////////Main////////////////////////////////
void main(void) {

    uint16_t address;
    uint16_t i;
    uint16_t j;
    uint8_t  k;
    
    
    frame_init();
    write_led_init();
    
    __delay_ms(3000);


//    for (i = 0; i < 10; i++) {
//         address = i;
//        output_RGB(address);
//        __delay_ms(500);
//        }
//
    select_frame(0); //all off
    __delay_ms(500);

    select_frame(1); //title
    __delay_ms(3000);
    select_frame(3);
    __delay_ms(1000);
    select_frame(2);
    __delay_ms(1000);
    select_frame(4);
    __delay_ms(2000);
    select_frame(5);
    __delay_ms(3000);
    select_frame(6);
    __delay_ms(1000);
    select_frame(7);
    __delay_ms(400);
    select_frame(8);
    __delay_ms(400);
    select_frame(9);  //go
    __delay_ms(500);
    select_frame(10);
    __delay_ms(400);


    for(k=11; k <34; k++) { //snek
        select_frame(k);
        __delay_ms(150);
    }
    
    for(k=0; k <3; k++) { //neutral
        select_frame(11);
        __delay_ms(150);
    }
    
    for(k=34; k <50; k++) { //bird
        select_frame(k);
        __delay_ms(150);
    }
    
    for(k=0; k <3; k++) { //neutral
        select_frame(11);
        __delay_ms(150);
    }
    
    for(k=34; k <50; k++) { //bird
        select_frame(k);
        __delay_ms(150);
    }
    
    for(k=11; k <34; k++) { //snek
        select_frame(k);
        __delay_ms(150);
    }
//    

        select_frame(10);   //scoring
    __delay_ms(700); 
    select_frame(50);
    
    write0();
    




} //main
/////////////////////////////////////////////////////////////////


////////////////////// Function Definitions /////////////////////

void write0(void) {
    uint16_t led[10] = {278, 280, 346, 410, 474, 536, 534, 468, 404, 340};
    uint8_t j;

    for (j = 0; j < 10; j++) {
        output_RGB(led[j]);
        __delay_ms(100);
    }
}

void write1(void) {
    uint16_t led[8] = {278, 340, 342, 406, 470, 532, 534, 536};
    uint8_t j;

    for (j = 0; j < 8; j++) {
        output_RGB(led[j]);
        __delay_ms(100);
    }
}
void write2(void) {
    
    //writes a two for the score
    
    uint16_t led[10] = {278, 280, 340, 346, 408,470, 532, 534, 536, 538};
    uint8_t j;

    for (j = 0; j < 10; j++) {
        output_RGB(led[j]);
        __delay_ms(100);
    }
}

void write3(void) {
    uint16_t led[9] = {340, 278, 280, 346, 408, 474, 536, 534, 468};
    uint8_t j;

    for (j = 0; j < 9; j++) {
        output_RGB(led[j]);
        __delay_ms(100);
    }
}

void write4(void) {
    uint16_t led[10] = {536, 472, 408, 344, 280, 342, 404, 468, 470, 474};
    uint8_t j;

    for (j = 0; j < 10; j++) {
        output_RGB(led[j]);
        __delay_ms(100);
    }
}

void write5(void) {
    uint16_t led[12] = {282, 278, 280, 282, 340, 404, 406, 408, 474, 536, 534, 532};
    uint8_t j;

    for (j = 0; j < 12; j++) {
        output_RGB(led[j]);
        __delay_ms(100);
    }
}

void write6(void) {
    uint16_t led[10] = {280, 278, 340, 404, 468, 534, 536, 474, 408, 406};
    uint8_t j;

    for (j = 0; j < 10; j++) {
        output_RGB(led[j]);
        __delay_ms(100);
    }
}

void select_frame(unsigned char sel) {
    
//Convert int sel into binary array and put each number at appropriate output
    
    
   
    unsigned char sel_array[8] = {0,0,0,0,0,0,0,0};
    unsigned char n = sel;
    unsigned char i = 0;
    
    while (n > 0) {
        sel_array[i] = n % 2;
        n = n / 2;
        i++;
    }

    sel7 = sel_array[7];
    sel6 = sel_array[6];
    sel5 = sel_array[5];
    sel4 = sel_array[4];
    sel3 = sel_array[3];
    sel2 = sel_array[2];
    sel1 = sel_array[1];
    sel0 = sel_array[0];
    
    __delay_us(1);
    
    go_frame = 1;
    __delay_us(2);
    go_frame = 0;
}



void output_RGB(uint16_t addr) {

    //Writes to selected address in blue
    unsigned char addr_array[10] = {0,0,0,0,0,0,0,0,0,0};
    long n = addr;
    uint16_t i = 0;
    
    while (n > 0) {
        addr_array[i] = n % 2;
        n = (n / 2);
        i++;
    }
    
    go_write = 1;
    
  //Send Address 
    data_flag = 0;
    out9 = addr_array[9];
    out8 = addr_array[8];
    out7 = addr_array[7];
    out6 = addr_array[6];
    out5 = addr_array[5];
    out4 = addr_array[4];
    out3 = addr_array[3];
    out2 = addr_array[2];
    out1 = addr_array[1];
    out0 = addr_array[0];
    __delay_us(5);
    
    while(clk == 1);
    wr_en = 1;
    //Wait clk cycle
    __delay_us(128);
    wr_en = 0;
    
  //Send B data (0x00)
    data_flag = 1;
    out9 = 0;
    out8 = 0;
    out7 = 0;
    out6 = 0;
    out5 = 1;
    out4 = 1;
    out3 = 1;
    out2 = 0;
    out1 = 1;
    out0 = 0;

    __delay_us(5);
    
    while(clk == 1);
    wr_en = 1;
    //Wait clk cycle
    __delay_us(128);
    wr_en = 0;


   //Send G data (0x02)
    data_flag = 1;
    out9 = 0;
    out8 = 0;
    out7 = 0;
    out6 = 0;
    out5 = 1;
    out4 = 0;
    out3 = 1;
    out2 = 1;
    out1 = 1;
    out0 = 0;
    __delay_us(5);
    
    while(clk == 1);
    wr_en = 1;
    //Wait clk cycle
    __delay_us(128);
    wr_en = 0;
    
    
   //Send R data (0x03)
    data_flag = 1;
    out9 = 0;
    out8 = 0;
    out7 = 0;
    out6 = 0;
    out5 = 0;
    out4 = 1;
    out3 = 0;
    out2 = 1;
    out1 = 1;
    out0 = 0;
    
    __delay_us(5);
    
    while(clk == 1);
    wr_en = 1;
    //Wait clk cycle
    __delay_us(128);
    wr_en = 0;
    
    __delay_us(128);
    go_write = 0;
    
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
    out0 = 0;
    //MAKE SURE OUTPUTS ARE SET TO 0 AFTER USING
    
    //Wait clk cycle
    __delay_us(128);
}

void write_led_init(void) {
    
    go_write = 0;  
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
    
    //CLK_OUT is at Rb5
    CLKRCON = 0b00010110; //CLK_OUT is 250kHz
    CLKRCLK = 0x03; //ref clk is 500kHz
    CLKRCON = 0b10010110; //ref clk module enabled
    PPSLOCK = 0b00000000; //unlock pps
    RB5PPS = 0x14; //Set RB5 to CLKR
       
        //Set to Digital
    ANSELB = 0; 
    ANSELD = 0; 
    ANSELC = 0; 
    
    //Set Inputs & Outputs
    TRISBbits.TRISB5 = 0; //make sure clk_out is out
    
    TRISDbits.TRISD2 = 0; //data flag
    TRISAbits.TRISA5 = 0; //data lines
    TRISEbits.TRISE0 = 0;
    TRISEbits.TRISE1 = 0;
    TRISEbits.TRISE2 = 0;
    TRISCbits.TRISC0 = 0;
    TRISCbits.TRISC1 = 0;
    TRISCbits.TRISC2 = 0;
    TRISCbits.TRISC3 = 0;
    TRISDbits.TRISD0 = 0;
    TRISDbits.TRISD1 = 0;
    TRISDbits.TRISD3 = 0; //wr_en
    TRISCbits.TRISC4 = 0; //go signal to start writing


    

}

void frame_init(void) {
    
    go_frame = 0;
    sel7 = 0;
    sel6 = 0;
    sel5 = 0;
    sel4 = 0;
    sel3 = 0;
    sel2 = 0;
    sel1 = 0;
    sel0 = 0;
    
    //Set to Digital
    ANSELB = 0; 
    ANSELD = 0; 
    ANSELCbits.ANSELC5 = 0;
    
    TRISBbits.TRISB5 = 0; 
    TRISBbits.TRISB4 = 0; 
    TRISBbits.TRISB3 = 0;
    TRISBbits.TRISB2 = 0;
    TRISBbits.TRISB1 = 0;
    TRISBbits.TRISB0 = 0;
    TRISDbits.TRISD7 = 0;
    TRISDbits.TRISD6 = 0;
    TRISDbits.TRISD5 = 0;
    TRISDbits.TRISD4 = 0;
    TRISCbits.TRISC5 = 0; 



    

}