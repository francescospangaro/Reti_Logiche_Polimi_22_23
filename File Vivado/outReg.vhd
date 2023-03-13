----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2023 17:10:56
-- Design Name: 
-- Module Name: outReg - Behavioral
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

entity outReg is 
	port(
	    i_en		: in std_logic_vector(2 downto 0);
		i_rst, i_clk: in std_logic;
		i_w			: in std_logic;
		i_out1		: out std_logic_vector(1 downto 0)
	);
 end outReg;

 architecture Behavioral of outReg is
     signal  ctr        : integer := 1;
     signal  tempOut    : std_logic_vector(1 downto 0);
 begin
	process(i_clk, i_rst)
	begin
	   
		if (i_rst = '1') then
			i_out1 <= (others => '0');
			ctr <= 1;
			tempOut <= (others => '0');
		end if;
		if (i_clk = '1' and i_clk'event) then
		  if not(i_en = "001") then
		        i_out1 <= tempOut;
	       elsif (i_en = "001" and ctr = 1) then
                tempOut(ctr) <= i_w;
                ctr <= ctr - 1;
                i_out1 <= (others => '0');
            elsif (i_en = "001" and ctr = 0) then
                tempOut(ctr) <= i_w;
                i_out1 <= tempOut;
                ctr <= 1;
        end if;
      end if;
	end process;
 end Behavioral;
