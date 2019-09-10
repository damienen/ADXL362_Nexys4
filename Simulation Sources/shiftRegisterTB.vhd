library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shiftRegisterTB is
end shiftRegisterTB;

architecture Behavioral of shiftRegisterTB is

component shiftRegister is
  Port ( CLK:in std_logic;
         ENB:in std_logic;
         LOAD:in std_logic;
         LOADREG:in std_logic_vector(7 downto 0);
         DATAVALID:out std_logic;
         
         BITIN:in std_logic;
         MSB:out std_logic
        );
end component shiftRegister;

signal r_clk:std_logic:='0';
signal r_enb:std_logic:='0';
signal r_load:std_logic:='0';
signal r_loadreg:std_logic_vector(7 downto 0):=X"AD";
signal r_datavalid:std_logic:='0';
signal r_bitin:std_logic:='1';
signal r_msb:std_logic:='0';

begin

r_clk<=not r_clk after 2ns;
r_bitin<=not r_bitin after 2ns;

UUT:shiftRegister PORT MAP( CLK=>r_clk,
                            ENB=>r_enb,
                            LOAD=>r_load,
                            LOADREG=>r_loadreg,
                            DATAVALID=>r_datavalid,
                            BITIN=>r_bitin,
                            MSB=>r_MSB
                           );

process
begin
    r_enb<='0';
    wait for 20ns;
    r_enb<='1';
    wait for 200ns;
end process;

process
begin
    r_load<='0';
    wait for 10ns;
    r_load<='1';
    wait for 20ns;
    r_load<='0';
    wait for 190ns;
end process;

end Behavioral;
