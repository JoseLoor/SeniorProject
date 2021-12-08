LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use work.rgbmatrix.all;

entity ram2ram_tb is
end ram2ram_tb;

architecture tb of ram2ram_tb is

	--tb signals
	signal uP_clk			:  std_logic := '0'; 
	signal uP_ram_sel		:  std_logic_vector(7 downto 0);
	signal	uP_write_data		:  std_logic_vector(10 downto 0);
	signal uP_wr_en			: std_logic;
	signal go_new_frame		:  std_logic; 
	signal 	go_write		:  std_logic;
	signal clk_in 			: std_logic := '0';
	signal rst 			: std_logic;
	signal done_tb 			: std_logic := '0';

	signal ram_q0 : std_logic_vector(23 downto 0) := X"ABCDEF";
	signal ram_q1 : std_logic_vector(23 downto 0) := X"123456";
	signal ram_q2 : std_logic_vector(23 downto 0) := X"121212";
	signal ram_q3 : std_logic_vector(23 downto 0) := X"ABABAB";

	signal mux_q_out : std_logic_vector(23 downto 0);
	signal mux_sel : std_logic_vector(7 downto 0);

    -- Matrix Memory signals
   	 signal m_addr			: std_logic_vector(ADDR_WIDTH-1 downto 0);
    	signal m_data_incoming 		: std_logic_vector(DATA_WIDTH/2-1 downto 0);
    	signal m_data_outgoing 		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal m_ram_wr_en		: std_logic;
	 signal m_wr_addr		: std_logic_vector(9 downto 0);
	 
	 -- Frames Memory Signals
	 signal f_data : std_logic_vector(23 downto 0);
	 signal f_rd_addr  : std_logic_vector(9 downto 0);
	signal f_start_addr : std_logic_vector(9 downto 0);

	signal m_led_addr					: std_logic_vector(9 downto 0);
	signal m_led_wr					: std_logic;
	signal m_led_data					: std_logic_vector(23 downto 0);
	
	signal m_frame_addr				: std_logic_vector(9 downto 0);
	signal m_frame_data				: std_logic_vector(23 downto 0);
	signal m_frame_wr					: std_logic;

 -- Writing to individual LEDs
	 signal fifo_data_valid 		: std_logic;
	 signal fifo_out					: std_logic_vector(10 downto 0);

    -- Reset signals
    signal rst_p : std_logic;
	 
	 signal go_frame_flag : std_logic;
	 signal go_write_flag : std_logic;
	 


begin

	--Controls who is writing to matrix ram
   U_MUX: entity work.mux_write
 
		port map (
			clk		=> clk_in,
			rst		=> rst_p,
			go_new_frame => go_frame_flag,		--register in state machines to hold and clear this value
			go_write	=> go_write_flag,
			led_wr		 => m_led_wr,
			frame_wr	=> m_frame_wr,
			led_addr	=> m_led_addr,
			frame_addr	 => m_frame_addr,
			led_data	=> m_led_data,
			frame_data	 => m_frame_data,

			ram_wr		=> m_ram_wr_en,
			ram_addr	=> m_wr_addr,
			ram_data    => m_data_incoming
  );

--	U_DMUX: entity work.demux64x1
--  		port map(
--			clk => clk_in,
--		   	in0 => ram_q0, 
--			in1 => ram_q1, 
--			in2 => ram_q2, 
--			in3 => ram_q3,
--			ram_sel => mux_sel,
--			output => mux_q_out
--		);

	--Controller to send frame to matrix ram
	U_RAM2RAM: entity work.ram2ram

		port map (
			clk		=> clk_in,								
			rst   		=> rst_p,
			go		=> go_new_frame,
			uP_sel		=> uP_ram_sel(7 downto 0),
			mux_q_out 	=> ram_q1, 
			go_flag		=> go_frame_flag,
			mux_sel 	=> mux_sel,
			rd_addr 	=> f_rd_addr,
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
		    rst           	=> rst_p,   					--using rst from button on fpga
		    go                  => go_write,
		    fifo_out      	=> fifo_out,
		    fifo_data_valid     => fifo_data_valid,	
		    go_flag		=> go_write_flag,
		    ram_wr_en		=> m_led_wr,    
		    ram_addr      	=> m_led_addr,  					--Address for LED Color Data
		    ram_data      	=> m_led_data  			--Color LED Data for matrix ram
		
	);


	--50 MHz CLK
  	clk_in <= not clk_in after 10 ns when done_tb = '0' else  
         clk_in;
	--500 kHz CLK
  	uP_clk <= not uP_clk after 1 us when done_tb = '0' else  
         uP_clk;

	process
	begin
		done_tb <= '0';
		rst <= '0';
		go_new_frame <= '0';
		go_write <= '0';
		uP_ram_sel		<= (others => '0');
		uP_write_data		<= (others => '0');
		uP_wr_en		<= '0';
		
		

	    	for i in 0 to 20 loop
      			wait until rising_edge(clk_in);
    		end loop;

	--------------------------------------------------------------
	--TEST 1: Send first frame

--EXPERIMENT WITH RAMWRITE

	wait for 10 us;
	


	--Write on frame
	--Address 0x09, write 0x030201
		go_write <= '1';
								--Send Address (0x00)
								--Turn on for one clk cycles
		uP_write_data(10)   <= '0';				--Indicator that it's an address
		uP_write_data(9 downto 0) <= "0000000001";
		wait until falling_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '0';
		uP_wr_en      <= '0';

		uP_write_data(10)   <= '1';				--Send first data byte (0x01)
		uP_write_data(9 downto 0) <= ("0000000001");		
		wait until falling_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '0';
		uP_wr_en      <= '0';
								--Send second data byte (0x02)
		uP_write_data(9 downto 0) <= ("0000000010");			
		wait until falling_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '0';
		uP_wr_en      <= '0';
			
								--Send third data byte (0x03)
		uP_write_data(9 downto 0) <= ("0000000011");			
		wait until falling_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '0';
		uP_wr_en      <= '0';

		wait for 2 us;
		go_write <= '0';
		wait for 100 us;

--------------------------------------------------------------
	--TEST 2: Write on Frame multiple times

	wait for 50 us;

	--Write on frame
	--Address 0x08, write 0xABCDEF
		go_write <= '1';
								--Send Address (0x00)
								--Turn on for one clk cycles
		uP_write_data(10)   <= '0';				--Indicator that it's an address
		uP_write_data(9 downto 0) <= "0000001000";
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';

		uP_write_data(10)   <= '1';				--Send first data byte (0x01)
		uP_write_data(7 downto 0) <= (X"EF");		
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';
								--Send second data byte (0x02)
		uP_write_data(7 downto 0) <= (X"CD");				
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';
			
								--Send third data byte (0x03)
		uP_write_data(7 downto 0) <= (X"AB");				
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';

		wait for 2 us;

		go_write <= '0';

		wait for 50 us;

	--Write on frame
	--Address 0x05, write 0xFF0000
		go_write <= '1';
								--Send Address (0x00)
								--Turn on for one clk cycles
		uP_write_data(10)   <= '0';				--Indicator that it's an address
		uP_write_data(9 downto 0) <= "0000000101";
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';

		uP_write_data(10)   <= '1';				--Send first data byte (0x01)
		uP_write_data(9 downto 0) <= ("0000000000");		
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';
								--Send second data byte (0x02)
		uP_write_data(9 downto 0) <= ("0000000000");			
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';
			
								--Send third data byte (0x03)
		uP_write_data(9 downto 0) <= ("1111111111");			
		wait until rising_edge(uP_clk);
		uP_wr_en      <= '1';
		wait until uP_clk'event and uP_clk = '1';
		uP_wr_en      <= '0';

		wait for 2 us;
		go_write <= '0';
		wait for 100 us;

-------------------------------------------------
--END TB
------------------------------------------------------------
		for i in 0 to 40 loop
      			wait until clk_in'event and clk_in = '1';
    		end loop;
		report "DONE";
		done_tb <= '1';
		wait;

	end process;

end tb;
