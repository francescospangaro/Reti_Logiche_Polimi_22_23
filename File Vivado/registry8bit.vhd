----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2023 17:53:20
-- Design Name: 
-- Module Name: registry8bit - Behavioral
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

entity registry8bit is
    port(
        i_in1 			: in std_logic_vector(7 downto 0);
        i_clk, i_rst 	: in std_logic;
        --i_out_done : out std_logic;
        i_out1 			: out std_logic_vector(7 downto 0)
    );
end registry8bit;

architecture Behavioral of registry8bit is
    signal check : std_logic_vector(7 downto 0);
    begin
    process(i_clk, i_rst)
        begin
            if i_rst = '1' then
                i_out1 <= (others => '0');
                check <= (others => '0');
                --i_out_done <= '0';
            end if;
            if (i_clk = '1' and i_clk'event) then
                if check = i_in1 then
                    i_out1 <= i_in1;
                    check <= i_in1;
                    --i_out_done <= '0';
                elsif not (check = i_in1) then
                    i_out1 <= i_in1;
                    check <= i_in1;
                    --i_out_done <= '1';      
                end if;
            end if;
    end process;
end behavioral;
