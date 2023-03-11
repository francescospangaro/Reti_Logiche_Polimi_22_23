----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.02.2023 19:05:40
-- Design Name: 
-- Module Name: delayFF - Behavioral
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

entity delayFF is
    Port (
        i_in1 : in std_logic;
        o_out1 : out std_logic;
        i_clk : in std_logic; 
        i_rst : in std_logic
     );
end delayFF;

architecture Behavioral of delayFF is
    signal tempSignal : std_logic;
begin
	process(i_clk,i_rst)
	begin
	    if(i_rst = '1') then
	       o_out1 <= '0';
	    end if;
        if(i_clk = '1' and i_clk'event) then
            o_out1 <= i_in1;
        end if;
    end process;
end Behavioral;
