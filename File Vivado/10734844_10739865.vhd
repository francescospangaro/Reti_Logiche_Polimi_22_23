----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2023 17:09:40
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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

entity project_reti_logiche is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_start : in std_logic;
		i_w : in std_logic;
		o_z0 : out std_logic_vector(7 downto 0);
		o_z1 : out std_logic_vector(7 downto 0);
		o_z2 : out std_logic_vector(7 downto 0);
		o_z3 : out std_logic_vector(7 downto 0);
		o_done : out std_logic;
		o_mem_addr : out std_logic_vector(15 downto 0);
		i_mem_data : in std_logic_vector(7 downto 0);
		o_mem_we : out std_logic;
		o_mem_en : out std_logic
	);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    signal temp_done : std_logic;
    signal temp_channel : std_logic_vector(1 downto 0);
    signal en_reg : std_logic;
    signal en_mux : std_logic;
    signal en_address : std_logic;
    signal delayedIn : std_logic;
    signal temp_out0 : std_logic_vector(7 downto 0);
    signal temp_out1 : std_logic_vector(7 downto 0);
    signal temp_out2 : std_logic_vector(7 downto 0);
    signal temp_out3 : std_logic_vector(7 downto 0);
    signal temp_new0 : std_logic_vector(7 downto 0);
    signal temp_new1 : std_logic_vector(7 downto 0);
    signal temp_new2 : std_logic_vector(7 downto 0);
    signal temp_new3 : std_logic_vector(7 downto 0);
    signal temp_data : std_logic_vector(7 downto 0);
    signal counter : integer := 20;
    component deMuxMux is
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
    end component;
    component registry8bit is
        port(
            i_in1 : in std_logic_vector(7 downto 0);
            i_clk, i_rst : in std_logic;
            --i_out_done : out std_logic_vector;
            i_out1 : out std_logic_vector(7 downto 0)
        );
    end component;
    component controller is 
        port(
            i: in std_logic;
            i_clk: in std_logic;
            i_rst: in std_logic;
            oReg: out std_logic;
            oAddr: out std_logic;
            oMux: out std_logic;
            oDone: out std_logic
        );
        end component;
    component outAddr is 
		port(
			i_rst, i_clk, i_en: in std_logic;
			i_in1: in std_logic;
			i_out1: out std_logic_vector(15 downto 0)
		);
	end component;
	component delayFF is
	   port (
            i_in1 : in std_logic;
            o_out1 : out std_logic;
            i_clk, i_rst: in std_logic
         );
    end component;
	component outReg is
		port(
			i_en, i_rst, i_clk: in std_logic;
			i_w: in std_logic;
			i_out1: out std_logic_vector(1 downto 0)
		);
	end component;
begin
    ctrl : controller
        port map(
            i => i_start,
            i_rst => i_rst,
            i_clk => i_clk,
            oReg => en_reg,
            oAddr => en_address,
            oMux => en_mux,
            oDone => temp_done            
        );
    del : delayFF
        port map(
            i_rst => i_rst,
            i_clk => i_clk,
            i_in1 => i_w,
            o_out1 => delayedIn
        );
    o_r : outReg
        port map(
            i_en => en_reg,
            i_rst => i_rst,
            i_clk => i_clk,
            i_w => delayedIn,
            i_out1 => temp_channel
        );
    o_a : outAddr
        port map(
            i_en => en_address,
            i_rst => i_rst,
            i_clk => i_clk,
            i_in1 => delayedIn,
            i_out1 => o_mem_addr
        );
    r_u : deMuxMux
        port map(
            i_en => en_mux,
            i_mem_data => i_mem_data,
            i_rst => i_rst,
            i_clk => i_clk,
            i_addr => temp_channel,
            oldOut0 => temp_out0,
            oldOut1 => temp_out1,
            oldOut2 => temp_out2,
            oldOut3 => temp_out3,
            i_out0 => temp_new0,
            i_out1 => temp_new1,
            i_out2 => temp_new2,
            i_out3 => temp_new3
        );
    reg_0 : registry8bit
        port map(
            i_rst => i_rst,
            i_clk => i_clk,
            i_in1 => temp_new0,
            i_out1 => temp_out0
        );
    reg_1 : registry8bit
        port map(
            i_rst => i_rst,
            i_clk => i_clk,
            i_in1 => temp_new1,
            i_out1 => temp_out1
       );
    reg_2 : registry8bit
        port map(
            i_rst => i_rst,
            i_clk => i_clk,
            i_in1 => temp_new2,
            i_out1 => temp_out2
        );
    reg_3 : registry8bit
        port map(
            i_rst => i_rst,
            i_clk => i_clk,
            i_in1 => temp_new3,
            i_out1 => temp_out3
        );
    process(i_clk, i_rst)
        begin
--uncomment the lines if you want the memory enabling to be dynamic

            --if(rising_edge(i_clk) and en_address = '1')then
                o_mem_en <= '1';
            --elsif(rising_edge(i_clk) and en_address = '0')then
               --o_mem_en <= '0';
            --end if;
            o_mem_we <= '0';
                if(temp_done = '0' and i_clk = '1' and i_clk'event) then
                    o_z0 <= "00000000";
                    o_z1 <= "00000000";
                    o_z2 <= "00000000";
                    o_z3 <= "00000000";
                    o_done <= '0';
                elsif temp_done = '1' and i_clk = '1' and i_clk'event then
                    o_z0 <= temp_out0;
                    o_z1 <= temp_out1;
                    o_z2 <= temp_out2;
                    o_z3 <= temp_out3;
                    o_done <= '1';
            end if;
    end process;
end Behavioral;
