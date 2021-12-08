----------------------------------------------
-- Controller to send frame to RGB Matrix RAM
----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ram2ram is
	generic(f_addr_width : positive := 10;
		q_width : positive := 24);
	port(
		clk			: in std_logic;
		rst   		: in std_logic;
		go				: in std_logic;
		uP_sel		: in std_logic_vector(7 downto 0);
		
		mux_q_out 	: in std_logic_vector(q_width-1 downto 0); --data from frame
		mux_sel		: out std_logic_vector(7 downto 0);		--select lines for mux
		rd_addr 		: out std_logic_vector(f_addr_width-1 downto 0);--address for ramX
		go_flag		: out std_logic;

		--Matrix RAM
		led_data 	: out std_logic_vector(q_width-1 downto 0);
		led_addr 	: out std_logic_vector(f_addr_width-1 downto 0);
		led_wr_en 	: out std_logic
	);
end ram2ram;

architecture stm of ram2ram is 

	signal ram_sel_reg : std_logic_vector(7 downto 0);
	signal frame_data  : std_logic_vector(q_width-1 downto 0);

	constant addrH	   : positive := 1025;

	type STATE_TYPE is (INIT, WAITFORGO, RAMNUM, LOOPS, READFRAME, WRITEFRAME, BUFF);
	signal next_state: STATE_TYPE;
begin

	process(clk, rst)
		variable addr_cnt : unsigned(f_addr_width downto 0) := (others => '0');
		variable waiting_cnt : unsigned(7 downto 0) := (others => '0');
	begin
		if (rst = '1') then
			next_state <= INIT;
			go_flag <= '0';
			mux_sel <= (others => '0');
			rd_addr <= (others => '0');
			led_data <= (others => '0');
			led_addr <= (others => '0');
			led_wr_en <= '0';
			
		elsif (rising_edge(clk)) then
			case next_state is
			
				when INIT =>
					mux_sel <= (others => '0');
					rd_addr <= (others => '0');
					led_data <= (others => '0');
					led_addr <= (others => '0');
					led_wr_en <= '0';
					go_flag <= '0';
					ram_sel_reg <= (others => '0');
					frame_data <= (others => '0');
					next_state <= WAITFORGO;
					
				when WAITFORGO =>
					if (go = '1') then
						go_flag <= '1';
						ram_sel_reg <= uP_sel; --capture select so it stays the same throughout the loops
						next_state <= RAMNUM;
					else
						mux_sel <= (others => '0');    --NEW
						rd_addr <= (others => '0');
						led_data <= (others => '0');
						led_addr <= (others => '0');
						led_wr_en <= '0';
						go_flag <= '0';
						next_state <= WAITFORGO;
					end if;
					
				when RAMNUM =>
					addr_cnt := (others => '0');
					waiting_cnt := (others => '0');
					mux_sel <= ram_sel_reg;		--send select to mux (1clk)
					next_state <= LOOPS;
					
				when LOOPS => 
					led_wr_en <= '0';
					addr_cnt := addr_cnt+1; --
					if (addr_cnt < addrH) then 
						rd_addr <= std_logic_vector(addr_cnt(f_addr_width-1 downto 0)-1); -- --send read address to ramX (1clk to get)
						next_state <= READFRAME;
					else 
						next_state <= INIT;
					end if;
					
				when READFRAME =>	
					led_data <= mux_q_out; --takes 2 clk cycles i think
					next_state <= WRITEFRAME;
					
				when WRITEFRAME =>
					if (waiting_cnt > X"02") then
						led_addr <= std_logic_vector(addr_cnt(f_addr_width-1 downto 0)-1); --
						led_wr_en <= '1';
						next_state <= BUFF;
					else
						waiting_cnt := waiting_cnt+1;
						next_state <= WRITEFRAME;
					end if;
				when BUFF =>
						next_state <= LOOPS;
			
				when others =>						--ADDED THIS
						next_state <= INIT;

			end case;
		end if;
	end process;

end stm;