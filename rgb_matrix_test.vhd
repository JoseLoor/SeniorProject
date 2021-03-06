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

entity rgb_matrix_test is
    port (
      --uP signals
--        uP_clk  : in std_logic;
--		  uP_CS	 : in std_logic;
--        uP_wr_en: in std_logic;
--        uP_ale1 : in std_logic;
--        uP_addr : in std_logic_vector(11 downto 0);
--        uP_data : in std_logic_vector(7 downto 0);
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
		  int_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
		  int_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
--		  int_data_valid : out std_logic;
--		  int_clk : out std_logic
    );
end rgb_matrix_test;

------------------------------------------------------
--Pin on DE0   Pin on LED  Name in Code  Pin Location
-------------  ----------  ------------  -------------
-- (internal)  XXXXXXX      clk_in			PIN_G21
--	GPIO_D0		clk		 	 clk_out			PIN_AA20
--	GPIO_D1		oe		  	    oe				PIN_AB20
--	GPIO_D2		lat   	    lat				PIN_AA19
--	GPIO_D3		A				 a					PIN_AB19
--	GPIO_D4		B			    b					PIN_AB18
--	GPIO_D5		C				 c					PIN_AA18
--	GPIO_D6		D		       d					PIN_AA17
--	GPIO_D7		R1			    r1				PIN_AB17
-- GPIO_D8		R2			    r2				PIN_Y17
--	GPIO_D9		G1			    g1				PIN_W17
--	GPIO_D10	   G2			    g2				PIN_U15
--	GPIO_D11 	B1			    b1				PIN_T15
-- GPIO_D12    B2				 b2				PIN_W15
		  

architecture str of rgb_matrix_test is

    -- Reset signals
    signal rst, rst_p, jtag_rst_out, clk_100 : std_logic;

    -- Memory signals
    signal addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal addr_incoming,addr_mem : std_logic_vector(ADDR_WIDTH downto 0);
    signal data_incoming : std_logic_vector(DATA_WIDTH/2-1 downto 0);
    signal data_outgoing : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_incoming_byte : std_logic_vector(7 downto 0);
    signal color_sel	: std_logic_vector(1 downto 0);

    -- Flags
    signal data_valid, word_wr_en : std_logic;
begin

    -- Reset button is an "active low" input, invert it so we can treat is as
    -- "active high", then OR it with the JTAG reset command output signal.
    rst_p <= not rst_n;
    rst <= rst_p or jtag_rst_out;


    -- LED panel controller
    U_LEDCTRL : entity work.ledctrl
        port map (
            rst => rst_p,     ---use this when rst is attached to the button
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
            addr => addr,
            data => data_outgoing-- X"100000000010"--data_outgoing
        );
		  
		  --We don't have this file and idk how to use PLL
--		   U_PLL: entity work.PLL
--				 port map(
--					 inclk0 => clk_in,
--					 c0 => clk_100,
--					 locked => open
--				 );
			
	-- This was commented out already
    -- -- Virtual JTAG interface
    -- U_JTAGIFACE : entity work.jtag_iface
        -- port map (
            -- rst     => rst,
            -- rst_out => open, --jtag_rst_out,
            -- output  => open, --data_incoming,
            -- valid   => open --data_valid
        -- );
	-- This was commented out already
--     U_CNT : entity work.cnt
--         port map (
--             clk     => clk_in,
--             rst     => '0', --rst,
--             output  => data_incoming,
--             valid   => data_valid
--         );
--	-- This was commented out already
--     -- Special memory for the framebuffer
--     U_MEMORY : entity work.memory
--         port map (
--             rst => '0', --rst,
--             -- Writing side
--             clk_wr =>  data_valid,--'0', --open,
--             input  => data_incoming,--std_logic_vector(to_unsigned(85, DATA_WIDTH)), --open, --
--             -- Reading side
--             clk_rd => clk_in,
--             addr   => addr,
--             output => data_outgoing
--         );

		U_RAM: entity work.RAM
			port map(
				rdclock => clk_in,
				rdaddress => addr,
				q => data_outgoing,
				wrclock => clk_in,
				wraddress => (others => '0'), --addr_mem,
				wren => '0', --word_wr_en,
				data => (others => '0') --data_incoming
			);
		-- Comment this out for initial testing to use with MIF file
		-- U_Interface: work.uP_interface
			-- port map(
				-- clk_in => uP_clk,
				-- wr_en => uP_wr_en,
				-- ale1 => uP_ale1,
				-- uP_CS => uP_CS,
				-- rst => '0',
				-- uP_addr => uP_addr,
				-- uP_data => uP_data,
				-- clk_out => clk_in,
				-- matrix_data => data_incoming_byte,
				-- matrix_addr(11 downto 2) => addr_incoming,
				-- matrix_addr(1 downto 0) => color_sel,
				-- rd_data_valid => data_valid
			-- );
		--This is how we write to the RAM using the uP
		-- U_Word_Filler: work.word_filler
			-- port map(
				-- clk => clk_in,
				-- rst => '0',
				-- color_sel => color_sel,
				-- addr_in => addr_incoming,
				-- addr_out => addr_mem,
				-- byte_wr_en => data_valid,
				-- byte_in => data_incoming_byte,
				-- word_out => data_incoming,
				-- word_wr_en => word_wr_en
			-- );
			
	--	DEBUGGING
			--int_addr(11 downto 2) <= addr_incoming;
			--int_addr(1 downto 0)<= color_sel;
			 int_addr <= addr;
			 int_data <= data_outgoing;
			-- int_data_valid <= uP_wr_en;
			-- int_clk <= uP_clk;

end str;