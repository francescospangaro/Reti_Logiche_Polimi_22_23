----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2023 18:26:08
-- Design Name: 
-- Module Name: deMuxMux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity deMuxMux is
	port(
	    i_clk, i_rst, i_en: in std_logic;
		i_mem_data: in std_logic_vector(7 downto 0);
		i_addr: in std_logic_vector(1 downto 0);
		i_out0: out std_logic_vector(7 downto 0);
		i_out1: out std_logic_vector(7 downto 0);
		i_out2: out std_logic_vector(7 downto 0);
		i_out3: out std_logic_vector(7 downto 0);
		
		oldOut0: in std_logic_vector(7 downto 0);
		oldOut1: in std_logic_vector(7 downto 0);
		oldOut2: in std_logic_vector(7 downto 0);
		oldOut3: in std_logic_vector(7 downto 0)
	);
 end deMuxMux;
 
 architecture Behavioral of deMuxMux is
 begin
	process(i_clk, i_rst)
	begin
		if(i_rst = '1')then
			i_out0 <= (others => '0');
			i_out1 <= (others => '0');
			i_out2 <= (others => '0');
			i_out3 <= (others => '0');
	    elsif i_en = '1' then
		  if(i_clk = '1' and i_clk'event and i_addr = "00")then
			 i_out0 <= i_mem_data;
			 i_out1 <= oldOut1;
			 i_out2 <= oldOut2;
			 i_out3 <= oldOut3;
		  elsif(i_clk = '1' and i_clk'event and i_addr = "01")then
			 i_out1 <= i_mem_data;
			 i_out0 <= oldOut0;
			 i_out2 <= oldOut2;
			 i_out3 <= oldOut3;
		  elsif(i_clk = '1' and i_clk'event and i_addr = "10")then
			 i_out2 <= i_mem_data;
			 i_out0 <= oldOut0;
			 i_out1 <= oldOut1;
			 i_out3 <= oldOut3;
		  elsif(i_clk = '1' and i_clk'event and i_addr = "11")then
			 i_out3 <= i_mem_data;
			 i_out0 <= oldOut0;
			 i_out1 <= oldOut1;
			 i_out2 <= oldOut2;
		  end if;
		elsif i_en = '0' then
		     i_out0 <= oldOut0;
             i_out1 <= oldOut1;
             i_out2 <= oldOut2;
             i_out3 <= oldOut3;
		end if;
	end process;
end Behavioral;