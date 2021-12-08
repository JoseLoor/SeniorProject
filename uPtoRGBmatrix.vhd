-- Adafruit RGB LED Matrix Display Driver
-- Top Level Entity
--
-- Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
-- This software is distributed under the terms of the MIT License shown below.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.rgbmatrix.all; -- Constants & Configuration in config.vhd

entity uPtoRGBmatrix is
	generic(f_addr_width : positive := 10; q_width : positive := 24);
    port (
		--uP Signals
		uP_clk			: in std_logic; 
		uP_ram_sel		: in std_logic_vector(7 downto 0);
		uP_write_data	: in std_logic_vector(10 downto 0);
		uP_wr_en			: in std_logic;
		go_new_frame	: in std_logic; 
		go_write			: in std_logic;

      --matrix signals
        clk_in  : in std_logic;
        rst_n   : in std_logic;
        clk_out : out std_logic;
        r1      : out std_logic;
        r2      : out std_logic;
        b1      : out std_logic;
        b2      : out std_logic;
        g1      : out std_logic;
        g2      : out std_logic;
        a       : out std_logic;
        b       : out std_logic;
        c       : out std_logic;
        d       : out std_logic;
        lat     : out std_logic;
        oe      : out std_logic;
		  
		--debug signals
--			int_sel : out std_logic_vector(7 downto 0);
--			int_go  : out std_logic;
----		  int_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
		  int_data : out std_logic_vector(9 downto 0)
----		  int_roe : out std_logic;
----		  int_ram_write_en : out std_logic
    );
end uPtoRGBmatrix;
		  
architecture str of uPtoRGBmatrix is

    -- Reset signals
    signal rst, rst_p, jtag_rst_out, clk_100 : std_logic;
	 
	 signal go_frame_flag : std_logic;
	 signal go_write_flag : std_logic;
	 
    -- Matrix Memory signals
   signal m_addr						: std_logic_vector(ADDR_WIDTH-1 downto 0);
   signal m_data_incoming 			: std_logic_vector(DATA_WIDTH/2-1 downto 0);
   signal m_data_outgoing 			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal m_ram_wr_en				: std_logic;
	signal m_wr_addr					: std_logic_vector(f_addr_width-1 downto 0);
	
	signal m_led_addr					: std_logic_vector(f_addr_width-1 downto 0);
	signal m_led_wr					: std_logic;
	signal m_led_data					: std_logic_vector(q_width-1 downto 0);
	
	signal m_frame_addr				: std_logic_vector(f_addr_width-1 downto 0);
	signal m_frame_data				: std_logic_vector(q_width-1 downto 0);
	signal m_frame_wr					: std_logic;
	 
	 -- Frames Memory Signals
	 signal f_data 					: std_logic_vector(q_width-1 downto 0);
	 signal f_rd_addr  				: std_logic_vector(f_addr_width-1 downto 0);
	 signal f_start_addr 			: std_logic_vector(f_addr_width-1 downto 0);
	 signal mux_q_out 				: std_logic_vector(q_width-1 downto 0);
	 signal mux_sel 					: std_logic_vector(7 downto 0);
	 signal ram_q0, ram_q1, ram_q2, ram_q3,
				ram_q4, ram_q5, ram_q6, ram_q7, ram_q8, ram_q9, ram_q10, ram_q11,
				ram_q12, ram_q13, ram_q14, ram_q15, ram_q16, ram_q17, ram_q18, ram_q19,
				ram_q20, ram_q21, ram_q22, ram_q23, ram_q24, ram_q25, ram_q26, ram_q27, ram_q28, ram_q29,
				ram_q30, ram_q31, ram_q32, ram_q33, ram_q34, ram_q35, ram_q36, ram_q37, 
				ram_q38, ram_q39, ram_q40, ram_q41, ram_q42, ram_q43, ram_q44, ram_q45, 
				ram_q46, ram_q47, ram_q48, ram_q49, ram_q50, ram_q51, ram_q52, ram_q53, 
				ram_q54, ram_q55 : std_logic_vector(q_width-1 downto 0);
	 
	 -- Writing to individual LEDs
	 signal fifo_data_valid 		: std_logic;
	 signal fifo_out					: std_logic_vector(10 downto 0);
	 


begin


	---Debugging
	-- int_sel <= uP_input(7 downto 0);
	-- int_go <= go_new_frame;
	----	int_ram_write_en <= ram_wr_en;
	int_data(7) <= go_frame_flag;
	int_data(6) <= go_write_flag;
	int_data(5 downto 0) <= m_led_data(5 downto 0);
	
	----	int_roe <= overrun_err;	




    -- Reset button is an "active low" input, invert it so we can treat is as
    -- "active high", then OR it with the JTAG reset command output signal.
    rst_p <= not rst_n;
    rst <= rst_p or jtag_rst_out;


    -- LED panel controller
    U_LEDCTRL : entity work.ledctrl
        port map (
            rst => '0',     
            clk_in => clk_in,
            -- Connection to LED panel
            clk_out => clk_out,
            rgb1(2) => r1,
            rgb1(1) => g1,
            rgb1(0) => b1,
            rgb2(2) => r2,
            rgb2(1) => g2,
            rgb2(0) => b2,
            led_addr(3) => d,
            led_addr(2) => c,
            led_addr(1) => b,
            led_addr(0) => a,
            lat => lat,
            oe  => oe,
            -- Connection with RAM
            addr => m_addr,
            data => m_data_outgoing-- X"100000000010"--data_outgoing
        );
		  

	--RAM that writes to Matrix
	U_RAM_MATRIX: entity work.RAM
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => m_addr,
			q => m_data_outgoing,
			wrclock => clk_in,
			wraddress => m_wr_addr,
			wren => m_ram_wr_en,
			data => m_data_incoming
		);
		
	--Controls who is writing to matrix ram
   U_MUX: entity work.mux_write
	  generic map (q_width => q_width,
						f_addr_width => f_addr_width)  
		port map (
			clk          => clk_in,
			rst			 => '0',
			go_new_frame => go_frame_flag,		--register in state machines to hold and clear this value
			go_write		 => go_write_flag,
			led_wr		 => m_led_wr,
			frame_wr		 => m_frame_wr,
			led_addr		 => m_led_addr,
			frame_addr	 => m_frame_addr,
			led_data		 => m_led_data,
			frame_data	 => m_frame_data,

			ram_wr		=> m_ram_wr_en,
			ram_addr		=> m_wr_addr,
			ram_data    => m_data_incoming
  );
	
	--Controller to send frame to matrix ram
	U_RAM2RAM: entity work.ram2ram
		generic map(q_width => q_width)
		port map (
			clk			=> clk_in,								
			rst   		=> rst_p,
			go				=> go_new_frame,
			uP_sel		=> uP_ram_sel(7 downto 0),
			mux_q_out 	=> mux_q_out, 
			go_flag		=> go_frame_flag,
			mux_sel 		=> mux_sel,
			rd_addr 		=> f_rd_addr,
			led_addr 	=> m_frame_addr,
			led_data 	=> m_frame_data,
			led_wr_en 	=> m_frame_wr
	);

-- Writing to individual LEDs
	U_UP: entity work.uP_interface
		port map(
		    clk_in          => uP_clk,			       	--CLK from uP
		    rst             => '0',
		    uP_data         => uP_write_data,			  			--11 bits that come from uP to give info for LEDs
		    uP_wr_en        => uP_wr_en,		       		--Comes from uP when new data available
		    clk_out         => clk_in,		       			--CLK for output of FIFO: from internal 50 MHz clk
		    fifo_out        => fifo_out,						--11 bits from FIFO
		    fifo_data_valid => fifo_data_valid		      --Flag for data ready on FIFO output
		);

	U_WRITE: entity work.ram_write
  		port map(
		    clk           	=> clk_in,  						--CLK from internal 50 MHz clk
		    rst           	=> rst_p,  					--using rst from button on fpga
		    go               => go_write,
		    fifo_out      	=> fifo_out,
		    fifo_data_valid  => fifo_data_valid,	
			 go_flag				=> go_write_flag,
		    ram_wr_en			=> m_led_wr,    
		    ram_addr      	=> m_led_addr,  					--Address for LED Color Data
		    ram_data      	=> m_led_data  			--Color LED Data for matrix ram
		);
		
		
		
			--Chooses which frame to send
	U_DMUX: entity work.demux64x1
		generic map(q_width => q_width)
  		port map(
			clk => clk_in,
		   in0 => ram_q0, 
			in1 => ram_q1, 
			in2 => ram_q2, 
			in3 => ram_q3,
			in4 => ram_q4,
			in5 => ram_q5,
			in6 => ram_q6,
			in7 => ram_q7,
			in8 => ram_q8,
			in9 => ram_q9,
			in10 => ram_q10,
			in11 => ram_q11,
			in12 => ram_q12,
			in13 => ram_q13,
			in14 => ram_q14,
			in15 => ram_q15,
			in16 => ram_q16,
			in17 => ram_q17,
			in18 => ram_q18,
			in19 => ram_q19,
			in20 => ram_q20,
			in21 => ram_q21,
			in22 => ram_q22,
			in23 => ram_q23,
			in24 => ram_q24,
			in25 => ram_q25,
			in26 => ram_q26,
			in27 => ram_q27,
			in28 => ram_q28,
			in29 => ram_q29,
			in30 => ram_q30,
			in31 => ram_q31,
			in32 => ram_q32,
			in33 => ram_q33,
			in34 => ram_q34,
			in35 => ram_q35,
			in36 => ram_q36,
			in37 => ram_q37,
			in38 => ram_q38,
			in39 => ram_q39,
			in40 => ram_q40,
			in41 => ram_q41,
			in42 => ram_q42,
			in43 => ram_q43,
			in44 => ram_q44,
			in45 => ram_q45,
			in46 => ram_q46,
			in47 => ram_q47,
			in48 => ram_q48,
			in49 => ram_q49,
			in50 => ram_q50,
			in51 => ram_q51,
			in52 => ram_q52,
			in53 => ram_q53,
			in54 => ram_q54,
			in55 => ram_q55,
			ram_sel => mux_sel,
			output => mux_q_out
		);
		
		
		
		
		
	--RAMS to store frames to write to RAM_MATRIX
	
	U_RAM_FRAME_OFF: entity work.ram_frame0
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q0, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);


	U_RAM_FRAME1: entity work.ram_frame1
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q1, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
		
	U_RAM_FRAME2: entity work.ram_frame2
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q2, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);

	U_RAM_FRAME3: entity work.ram_frame3
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q3, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME4: entity work.ram_frame4
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q4, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME5: entity work.ram_frame5
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q5, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME6: entity work.ram_frame6
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q6, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME7: entity work.ram_frame7
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q7, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME8: entity work.ram_frame8
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q8, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME9: entity work.ram_frame9
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q9, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME10: entity work.ram_frame10
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q10, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME11: entity work.ram_frame11
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q11, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME12: entity work.ram_frame12
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q12, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME13: entity work.ram_frame13
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q13, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME14: entity work.ram_frame14
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q14, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME15: entity work.ram_frame15
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q15, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME16: entity work.ram_frame16
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q16, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME17: entity work.ram_frame17
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q17, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME18: entity work.ram_frame18
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q18, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME19: entity work.ram_frame19
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q19, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME20: entity work.ram_frame20
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q20, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME21: entity work.ram_frame21
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q21, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME22: entity work.ram_frame22
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q22, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME23: entity work.ram_frame23
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q23, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME24: entity work.ram_frame24
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q24, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME25: entity work.ram_frame25
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q25, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME26: entity work.ram_frame26
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q26, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME27: entity work.ram_frame27
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q27, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME28: entity work.ram_frame28
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q28, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME29: entity work.ram_frame29
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q29, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME30: entity work.ram_frame30
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q30, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME31: entity work.ram_frame31
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q31, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME32: entity work.ram_frame32
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q32, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME33: entity work.ram_frame33
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q33, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME34: entity work.ram_frame34
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q34, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME35: entity work.ram_frame35
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q35, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME36: entity work.ram_frame36
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q36, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME37: entity work.ram_frame37
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q37, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME38: entity work.ram_frame38
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q38, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME39: entity work.ram_frame39
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q39, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME40: entity work.ram_frame40
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q40, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME41: entity work.ram_frame41
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q41, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);

	U_RAM_FRAME42: entity work.ram_frame42
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q42, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME43: entity work.ram_frame43
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q43, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME44: entity work.ram_frame44
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q44, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME45: entity work.ram_frame45
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q45, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME46: entity work.ram_frame46
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q46, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME47: entity work.ram_frame47
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q47, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME48: entity work.ram_frame48
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q48, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME49: entity work.ram_frame49
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q49, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME50: entity work.ram_frame50
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q50, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME51: entity work.ram_frame51
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q51, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME52: entity work.ram_frame52
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q52, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME53: entity work.ram_frame53
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q53, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME54: entity work.ram_frame54
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q54, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
	U_RAM_FRAME55: entity work.ram_frame55
		port map(
			rdclock => clk_in,				--50MHz internal
			rdaddress => f_rd_addr,
			q => ram_q55, 
			wrclock => clk_in,
			wraddress => (others => '0'), --don't need to write to this one
			wren => '0', 
			data => (others => '0')
		);
			
			


end str;