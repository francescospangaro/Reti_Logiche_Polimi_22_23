----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.02.2023 15:38:44
-- Design Name: 
-- Module Name: controllore - Behavioral
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

entity controller is
	port(
		i		: in std_logic;
		i_clk	: in std_logic;
		i_rst	: in std_logic;
		outState: out std_logic_vector(2 downto 0)
	);
end controller;

architecture FSM of controller is
	--type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10);
	type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S9, S10);
	signal next_state, current_state: state_type;

	begin
		state_reg: process(i_clk, i_rst)
		begin
			if(i_rst = '1') then
				current_state <= S0;
			elsif i_clk = '1' and i_clk'event then
				current_state <= next_state;
			end if;
		end process;
		
		lambda: process(current_state, i)
		begin
			case current_state is
				when S0 =>
					if(i = '0') then
						next_state <= S0;
					else
						next_state <= S1;
					end if;
				when S1 =>
					if(i = '0') then
						next_state <= S1;
					else
						next_state <= S2;
					end if;
				when S2 =>
					if(i = '0') then
						next_state <= S4;
					else
						next_state <= S3;
					end if;
				when S3 =>
					if(i = '0') then
						next_state <= S10;
					else
						next_state <= S3;
					end if;
				when S10 =>
                    if(i = '0') then
                        next_state <= S4;
                    else
                        next_state <= S10;
                    end if;
				when S4 =>
					if(i = '0') then
						next_state <= S9;
					else
						next_state <= S9;
					end if;
				when S9 =>
                    if(i = '0') then
                        next_state <= S5;
                    else
                        next_state <= S5;
                    end if;
				when S5 =>
					if(i = '0') then
						next_state <= S6;
					else
						next_state <= S6;
					end if;
				when S6 =>
					if(i = '0') then
						next_state <= S7;
					else
						next_state <= S7;
					end if;
				when S7 =>
					if(i = '0') then
						next_state <= S0;
					else
						next_state <= S1;
					end if;
			end case;
		end process;
		
		delta: process(current_state)
		begin
			case current_state is
				when S0 =>
				    outState <= "000";
				when S1 =>
				    outState <= "001";
				when S2 =>
					outState <= "001";
				when S3 =>
					outState <= "010";
				when S4 =>
					outState <= "000";
				when S5 =>
					outState <= "011";           
				when S6 =>
					outState <= "000";
				when S7 =>
				    outState <= "100";
                 when S9 =>
                    outState <= "011";
                when S10 =>
                    outState <= "010"; 
			end case;
		end process;
	end FSM; 