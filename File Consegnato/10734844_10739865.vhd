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
		i_clk 		: in std_logic;
		i_rst 		: in std_logic;
		i_start 	: in std_logic;
		i_w 		: in std_logic;
		o_z0 		: out std_logic_vector(7 downto 0);
		o_z1 		: out std_logic_vector(7 downto 0);
		o_z2 		: out std_logic_vector(7 downto 0);
		o_z3 		: out std_logic_vector(7 downto 0);
		o_done 		: out std_logic;
		o_mem_addr 	: out std_logic_vector(15 downto 0);
		i_mem_data 	: in std_logic_vector(7 downto 0);
		o_mem_we 	: out std_logic;
		o_mem_en 	: out std_logic := '0'
	);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    signal temp_channel : std_logic_vector(1 downto 0);
    signal stateDefiner : std_logic_vector(2 downto 0);
    signal delayedIn 	: std_logic;
    signal temp_out0 	: std_logic_vector(7 downto 0);
    signal temp_out1 	: std_logic_vector(7 downto 0);
    signal temp_out2 	: std_logic_vector(7 downto 0);
    signal temp_out3 	: std_logic_vector(7 downto 0);
    signal temp_new0 	: std_logic_vector(7 downto 0);
    signal temp_new1 	: std_logic_vector(7 downto 0);
    signal temp_new2 	: std_logic_vector(7 downto 0);
    signal temp_new3 	: std_logic_vector(7 downto 0);
    signal temp_data 	: std_logic_vector(7 downto 0);
    component deMuxMux is
        port(
            i_clk, i_rst: in std_logic;
            i_en 		: in std_logic_vector(2 downto 0);
            i_mem_data	: in std_logic_vector(7 downto 0);
            i_addr		: in std_logic_vector(1 downto 0);
            i_out0		: out std_logic_vector(7 downto 0);
            i_out1		: out std_logic_vector(7 downto 0);
            i_out2		: out std_logic_vector(7 downto 0);
            i_out3		: out std_logic_vector(7 downto 0);
            oldOut0		: in std_logic_vector(7 downto 0);
            oldOut1		: in std_logic_vector(7 downto 0);
            oldOut2		: in std_logic_vector(7 downto 0);
            oldOut3		: in std_logic_vector(7 downto 0)
        );
    end component;
    component registry8bit is
        port(
            i_in1 			: in std_logic_vector(7 downto 0);
            i_clk, i_rst 	: in std_logic;
            i_out1 			: out std_logic_vector(7 downto 0)
        );
    end component;
    component controller is 
        port(
            i			: in std_logic;
            i_clk		: in std_logic;
            i_rst		: in std_logic;
            outState 	: out std_logic_vector(2 downto 0)
        );
        end component;
    component outAddr is 
		port(
			i_rst, i_clk: in std_logic;
			i_en 		: in std_logic_vector(2 downto 0);
			i_in1		: in std_logic;
			i_out1		: out std_logic_vector(15 downto 0)
		);
	end component;
	component delayFF is
	   port (
            i_in1 			: in std_logic;
            o_out1 			: out std_logic;
            i_clk, i_rst 	: in std_logic
         );
    end component;
	component outReg is
		port(
			i_rst, i_clk: in std_logic;
			i_en 		: in std_logic_vector(2 downto 0);
			i_w			: in std_logic;
			i_out1		: out std_logic_vector(1 downto 0)
		);
	end component;
begin
    ctrl : controller
        port map(
            i => 		i_start,
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            outState => stateDefiner         
        );
    del : delayFF
        port map(
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            i_in1 => 	i_w,
            o_out1 => 	delayedIn
        );
    o_r : outReg
        port map(
            i_en => 	stateDefiner,
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            i_w => 		delayedIn,
            i_out1 => 	temp_channel
        );
    o_a : outAddr
        port map(
            i_en => 	stateDefiner,
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            i_in1 => 	delayedIn,
            i_out1 => 	o_mem_addr
        );
    r_u : deMuxMux
        port map(
            i_en => 		stateDefiner,
            i_mem_data => 	i_mem_data,
            i_rst => 		i_rst,
            i_clk => 		i_clk,
            i_addr => 		temp_channel,
            oldOut0 => 		temp_out0,
            oldOut1 => 		temp_out1,
            oldOut2 => 		temp_out2,
            oldOut3 => 		temp_out3,
            i_out0 => 		temp_new0,
            i_out1 => 		temp_new1,
            i_out2 => 		temp_new2,
            i_out3 => 		temp_new3
        );
    reg_0 : registry8bit
        port map(
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            i_in1 => 	temp_new0,
            i_out1 => 	temp_out0
        );
    reg_1 : registry8bit
        port map(
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            i_in1 => 	temp_new1,
            i_out1 => 	temp_out1
       );
    reg_2 : registry8bit
        port map(
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            i_in1 => 	temp_new2,
            i_out1 => 	temp_out2
        );
    reg_3 : registry8bit
        port map(
            i_rst => 	i_rst,
            i_clk => 	i_clk,
            i_in1 => 	temp_new3,
            i_out1 => 	temp_out3
        );
    process(i_clk, i_rst)
        begin
            if rising_edge(i_clk) then
                if(stateDefiner = "010" or stateDefiner = "001")then
                    o_mem_en <= '1';
                else
                    o_mem_en <= '0';
                end if;
            end if;
            o_mem_we <= '0';
            if (i_rst = '1') then 
                o_z0 <= "00000000";
                o_z1 <= "00000000";
                o_z2 <= "00000000";
                o_z3 <= "00000000";
                o_done <= 	'0';
            elsif rising_edge(i_clk) then
                if(stateDefiner = "100") then
                    o_z0 <= 	temp_out0;
                    o_z1 <= 	temp_out1;
                    o_z2 <= 	temp_out2;
                    o_z3 <= 	temp_out3;
                    o_done <= 	'1';
                else
                    o_z0 <= 	"00000000";
                    o_z1 <= 	"00000000";
                    o_z2 <= 	"00000000";
                    o_z3 <= 	"00000000";
                    o_done <= 	'0';
                end if;
            end if;
    end process;
end Behavioral;


--ENTITY E ARCHITECTURE DELLA FSM
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
	type state_type is (S0, S1, S2, S3, S5, S6, S7, S9, S10);
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
						next_state <= S9;
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
                        next_state <= S9;
                    else
                        next_state <= S10;
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
	

--ENTITY E ARCHITECTURE DelayFF
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity delayFF is
    Port (
        i_in1 	: in std_logic;
        o_out1 	: out std_logic;
        i_clk 	: in std_logic; 
        i_rst 	: in std_logic
     );
end delayFF;

architecture Behavioral of delayFF is
begin
	process(i_clk, i_rst)
	begin
	    if(i_rst = '1') then
	       o_out1 <= '0';
	    end if;
        if(i_clk = '1' and i_clk'event) then
            o_out1 <= i_in1;
        end if;
    end process;
end Behavioral;


--ENTITY E ARCHITECTURE OutReg
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
 
 
 --ENTITY E ARCHITECTURE OutAddr
 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.NUMERIC_STD.ALL;

 entity outAddr is
     port(
         i_rst, i_clk: in std_logic;
         i_en         : in std_logic_vector(2 downto 0);
         i_in1        : in std_logic;
         i_out1        : out std_logic_vector(15 downto 0)
     );
 end outAddr;
 
 architecture Behavioral of outAddr is
         signal tempAddr: std_logic_vector(15 downto 0);
 begin
     process(i_clk, i_rst)
     begin
         if i_rst = '1' then
             tempAddr <= (others => '0');
             i_out1 <= (others => '0');
         end if;
         if i_clk = '1' and i_clk'event then
            if not (i_en = "010") then
                 tempAddr <= (others => '0');
                 i_out1 <= (others => '0');
           elsif i_en = "010" then
                 tempAddr <= std_logic_vector(shift_left(unsigned(tempAddr),1));
                 tempAddr(0) <= i_in1;
                 i_out1 <= tempAddr;
           end if;
         end if;
     end process;
 end Behavioral;
 
 
 --ENTITY E ARCHITECTURE deMuxMux
 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.NUMERIC_STD.ALL;
 
 entity deMuxMux is
     port(
         i_clk, i_rst    : in std_logic;
         i_en             : in std_logic_vector(2 downto 0);
         i_mem_data        : in std_logic_vector(7 downto 0);
         i_addr            : in std_logic_vector(1 downto 0);
         i_out0            : out std_logic_vector(7 downto 0);
         i_out1            : out std_logic_vector(7 downto 0);
         i_out2            : out std_logic_vector(7 downto 0);
         i_out3            : out std_logic_vector(7 downto 0);
         
         oldOut0            : in std_logic_vector(7 downto 0);
         oldOut1            : in std_logic_vector(7 downto 0);
         oldOut2            : in std_logic_vector(7 downto 0);
         oldOut3            : in std_logic_vector(7 downto 0)
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
         end if;
         if(i_clk = '1' and i_clk'event)then
            if i_en = "011" then
               if(i_addr = "00")then
                  i_out0 <= i_mem_data;
                  i_out1 <= oldOut1;
                  i_out2 <= oldOut2;
                  i_out3 <= oldOut3;
               elsif(i_addr = "01")then
                  i_out1 <= i_mem_data;
                  i_out0 <= oldOut0;
                  i_out2 <= oldOut2;
                  i_out3 <= oldOut3;
               elsif(i_addr = "10")then
                  i_out2 <= i_mem_data;
                  i_out0 <= oldOut0;
                  i_out1 <= oldOut1;
                  i_out3 <= oldOut3;
               elsif(i_addr = "11")then
                  i_out3 <= i_mem_data;
                  i_out0 <= oldOut0;
                  i_out1 <= oldOut1;
                  i_out2 <= oldOut2;
               end if;
           elsif not i_en = "011" then
               i_out0 <= oldOut0;
               i_out1 <= oldOut1;
               i_out2 <= oldOut2;
               i_out3 <= oldOut3;
           end if;
         end if;
     end process;
 end Behavioral;
 
 
 --ENTITY E ARCHITECTURE Registry8Bit
 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.NUMERIC_STD.ALL;
 
 entity registry8bit is
     port(
         i_in1             : in std_logic_vector(7 downto 0);
         i_clk, i_rst     : in std_logic;
         i_out1             : out std_logic_vector(7 downto 0)
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
             end if;
             if (i_clk = '1' and i_clk'event) then
                 if check = i_in1 then
                     i_out1 <= i_in1;
                     check <= i_in1;
                 elsif not (check = i_in1) then
                     i_out1 <= i_in1;
                     check <= i_in1;    
                 end if;
             end if;
     end process;
 end behavioral;