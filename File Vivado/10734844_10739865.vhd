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
    --signal
    --signal
    component registryUpdater is
        port(
            i_clk, i_rst: in std_logic;
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
    component regz is
        port(
            i_in1 : in std_logic_vector(7 downto 0);
            i_clk, i_rst : in std_logic;
            i_out1 : out std_logic_vector(7 downto 0)
        );
    end component;
    component outAddr is 
		port(
			i_rst, i_clk, i_start: in std_logic;
			i_in1: in std_logic;
			i_out1: out std_logic_vector(15 downto 0)
		);
	end component;
	component outReg is
		port(
			i_start: in std_logic;
			i_rst, i_clk: in std_logic;
			i_w: in std_logic;
			i_out1: out std_logic_vector(1 downto 0)
		);
	end component;
begin


end Behavioral;
