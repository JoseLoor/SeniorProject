---------------------------------------------------------------------------
--Combinational Logic to send data from frame ram to matrix ram
---------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity mux_write is 
  generic (q_width : positive := 24;
				f_addr_width : positive := 10);   --data width
  port(
	clk	    : in std_logic;
	rst			 : in std_logic;
	go_new_frame : in std_logic;		--register in state machines to hold and clear this value
	go_write		 : in std_logic;
	led_wr		 : in std_logic;
	frame_wr		 : in std_logic;
	led_addr		 : in std_logic_vector(f_addr_width-1 downto 0);
	frame_addr	 : in std_logic_vector(f_addr_width-1 downto 0);
	led_data		 : in std_logic_vector(q_width-1 downto 0);
	frame_data	 : in std_logic_vector(q_width-1 downto 0);

	ram_wr		: out std_logic;
	ram_addr		: out std_logic_vector(f_addr_width-1 downto 0);
	ram_data    : out std_logic_vector(q_width-1 downto 0)
  );
end mux_write;


architecture bhv of mux_write is

begin

	process(clk, rst)
	begin
		
		if (rst = '1') then
			ram_addr <= (others => '0');
			ram_data <= (others => '0');
			ram_wr   <= '0';
			
		elsif (rising_edge(clk)) then
				if (go_new_frame = '1' and go_write = '0') then    
					ram_wr 	<= frame_wr;
					ram_addr <= frame_addr;
					ram_data <= frame_data;
				elsif (go_write = '1' and go_new_frame = '0') then
					ram_wr 	<= led_wr;
					ram_addr <= led_addr;
					ram_data <= led_data;
				elsif (go_new_frame = '1' and go_write = '1') then	---ADDED THESE CASES
					ram_wr 	<= frame_wr;
					ram_addr <= frame_addr;
					ram_data <= frame_data;
				else
					ram_wr 	<= '0';
					ram_addr <= (others => '0');
					ram_data <= X"0000AA";
				end if;
		end if;
		
	end process;

end bhv;
