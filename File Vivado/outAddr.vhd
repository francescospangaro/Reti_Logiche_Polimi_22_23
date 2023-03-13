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
		i_rst, i_clk: in std_logic;
		i_en 		: in std_logic_vector(2 downto 0);
		i_in1		: in std_logic;
		i_out1		: out std_logic_vector(15 downto 0)
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
	    end if;
		if i_clk = '1' and i_clk'event then
	       if not (i_en = "010") then
                tempAddr <= (others => '0');
                i_out1 <= (others => '0');
		  elsif i_en = "010" then
			    tempAddr <= std_logic_vector(shift_left(unsigned(tempAddr),1));
                --report integer'image(to_integer(unsigned(tempAddr))) severity failure;
			    tempAddr(0) <= i_in1;
			    --report integer'image(to_integer(unsigned(tempAddr))) severity failure;
			    i_out1 <= tempAddr;
		  end if;
		end if;
	end process;
end Behavioral;
