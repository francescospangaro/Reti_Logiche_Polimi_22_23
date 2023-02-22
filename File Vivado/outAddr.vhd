----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2023 17:32:05
-- Design Name: 
-- Module Name: outAddr - Behavioral
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

entity outAddr is
	port(
		i_rst, i_clk, i_start: in std_logic;
		i_in1: in std_logic;
		i_out1: out std_logic_vector(15 downto 0)
	);
end outAddr;

architecture Behavioral of outAddr is
        signal counter: integer := 18;
		signal tempAddr: std_logic_vector(15 downto 0);
begin
    process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			tempAddr <= (others => '0');
			i_out1 <= (others => '0');
			counter <= 18;
		elsif i_start = '1' then
			if i_clk = '1' and i_clk'event and counter > 16 then
				tempAddr <= (others => '0');
				counter <= counter - 1;
				i_out1 <= (others => '0');
			elsif i_clk = '1' and i_clk'event and counter < 17 then
				tempAddr(16 - counter) <= i_in1;
				counter <= counter - 1;
				i_out1 <= (others => '0');
			end if;
		elsif i_start = '0' then 
			counter <= 18;
			i_out1 <= tempAddr;
		end if;
	end process;
end Behavioral;
