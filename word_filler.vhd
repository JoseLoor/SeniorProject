library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity word_filler is
  port(
    clk             : in  std_logic;
    rst             : in  std_logic;
    byte_wr_en      : in  std_logic;
	 color_sel		  : in  std_logic_vector(1 downto 0);
	 addr_in			  : in  std_logic_vector(9 downto 0);
    byte_in         : in  std_logic_vector(7 downto 0);
	 addr_out		  : out std_logic_vector(9 downto 0);
    word_out        : out std_logic_vector(23 downto 0);
    word_wr_en      : out std_logic
  );
end word_filler;



architecture BHV of word_filler is

  begin

  process(clk,rst)
    variable byte_count : natural;
  begin

    if(rst = '1') then
		word_wr_en <= '0';
		word_out <= (others => '0');
		byte_count := 0;

    elsif(rising_edge(clk))then
      word_wr_en <= '0';
		--word_out <= word_out;
		--addr_out <= (others => '0');
		
--      if((byte_wr_en = '1')) then
--        word_out((23-(8*byte_count)) downto (8*(2-byte_count))) <= byte_in; --((to_unsigned(23, 4)-(to_unsigned(8,4)*byte_count)) downto (to_unsigned(8,4)*(to_unsigned(2,4)-byte_count)))
--        byte_count := byte_count +1;
--		  addr_out <= addr_in;
--      end if;
			
			if(byte_wr_en = '1') then
				if(color_sel = "00") then
					word_out(23 downto 16) <= byte_in;
				elsif(color_sel = "01") then
					word_out(15 downto 8) <= byte_in;
				elsif(color_sel = "10") then
					word_out(7 downto 0) <= byte_in;
					word_wr_en <= '1';
				end if;
			end if;
			
			addr_out <= addr_in;


--
--      if(byte_count = 4) then
--        byte_count := 0;
--        word_wr_en <= '1';
--      end if;

    end if;

  end process;

--	process(byte_wr_en,color_sel,byte_in)
--	begin
--		if(byte_wr_en = '1') then
--				if(color_sel = "01") then
--					word_out(23 downto 16) <= byte_in;
--				elsif(color_sel = "10") then
--					word_out(15 downto 8) <= byte_in;
--				elsif(color_sel = "11") then
--					word_out(7 downto 0) <= byte_in;
--					addr_out <= addr_in;
--					word_wr_en <= '1';
--				end if;
--			end if;
--	
--	end process;

end BHV;
