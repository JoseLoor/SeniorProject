---------------------------------------------------------------------------
--Combinational Logic to send data from frame ram to matrix ram
---------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity demux64x1 is 
  generic (q_width : positive := 24);   --data width
  port(
	clk	: in std_logic;
  	in0, in1, in2, in3,
	in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, 
	in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31, in32, in33, in34, in35, in36, 
	in37, in38, in39, in40, in41, in42, in43, in44, in45, in46, in47, in48, in49, in50, in51, in52, 
	in53, in54, in55 
		: in std_logic_vector(q_width-1 downto 0);
	ram_sel : in std_logic_vector(7 downto 0);         --don't need to use all 8 as long as pin is set to gnd
	output : out std_logic_vector(q_width-1 downto 0)
  );
end demux64x1;


architecture bhv of demux64x1 is

begin

	process(clk, ram_sel, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, 
	in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31, in32, in33, in34, in35, in36, 
	in37, in38, in39, in40, in41, in42, in43, in44, in45, in46, in47, in48, in49, in50, in51, in52, 
	in53, in54, in55)
	begin
    
    		case ram_sel is
				when x"00"    =>
						output <= in0;
				when x"01" =>
						output <= in1;
				when x"02" =>
					output <= in2;
				when X"03" =>
					output <= in3;
				when X"04" =>
					output <= in4;
				when X"05" =>
					output <= in5;
				when X"06" =>
					output <= in6;
				when X"07" =>
					output <= in7;
				when X"08" =>
					output <= in8;
				when X"09" =>
					output <= in9;
				when X"0A" =>
					output <= in10;
				when X"0B" =>
					output <= in11;
				when X"0C" =>
					output <= in12;
				when X"0D" =>
					output <= in13;
				when X"0E" =>
					output <= in14;
				when X"0F" =>
					output <= in15;
				when X"10" =>
					output <= in16;
				when X"11" =>
					output <= in17;
				when X"12" =>
					output <= in18;
				when X"13" =>
					output <= in19;
				when X"14" =>
					output <= in20;
				when X"15" =>
					output <= in21;
				when X"16" =>
					output <= in22;
				when X"17" =>
					output <= in23;
				when X"18" =>
					output <= in24;
				when X"19" =>
					output <= in25;
				when X"1A" =>
					output <= in26;
				when X"1B" =>
					output <= in27;
				when X"1C" =>
					output <= in28;
				when X"1D" =>
					output <= in29;	
				when X"1E" =>
					output <= in30;
				when X"1F" =>
					output <= in31;
				when X"20" =>
					output <= in32;
				when X"21" =>
					output <= in33;
				when X"22" =>
					output <= in34;
				when X"23" =>
					output <= in35;
				when X"24" =>
					output <= in36;
				when X"25" =>
					output <= in37;
				when X"26" =>
					output <= in38;
				when X"27" =>
					output <= in39;
				when X"28" =>
					output <= in40;
				when X"29" =>
					output <= in41;
				when X"2A" =>
					output <= in42;
				when X"2B" =>
					output <= in43;
				when X"2C" =>
					output <= in44;
				when X"2D" =>
					output <= in45;
				when X"2E" =>
					output <= in46;
				when X"2F" =>
					output <= in47;
				when X"30" =>
					output <= in48;
				when X"31" =>
					output <= in49;
				when X"32" =>
					output <= in50;
				when X"33" =>
					output <= in51;
				when X"34" =>
					output <= in52;
				when X"35" =>
					output <= in53;
				when X"36" =>
					output <= in54;
				when X"37" =>
					output <= in55;
				
			--Add the rest for more frames & rams

			when others =>
				output <= in0; ---All LEDs off

    		end case;
	end process;

end bhv;
