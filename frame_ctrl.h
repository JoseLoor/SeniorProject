/* 
 * File:   frame_ctrl.h
 * Author: Thinkpad Owner
 *
 * Created on December 1, 2021, 11:37 PM
 */

#ifndef FRAME_CTRL_H
#define	FRAME_CTRL_H

void frame_init(void);
void write_led_init(void);

void select_frame(unsigned char sel);
void output_RGB(uint16_t addr);

void write0(void);
void write1(void);
void write2(void);
void write3(void);
void write4(void);
void write5(void);
void write6(void);

#endif	/* FRAME_CTRL_H */

