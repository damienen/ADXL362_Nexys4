library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shiftRegister is
  Port ( CLK:in std_logic;
         ENB:in std_logic;
         LOAD:in std_logic;
         LOADREG:in std_logic_vector(7 downto 0);
         DATAVALID:out std_logic;
         
         BITIN:in std_logic;
         MSB:out std_logic
        );
end shiftRegister;

architecture Behavioral of shiftRegister is

signal r_memory:std_logic_vector(7 downto 0):=X"00";
signal counter:integer range 0 to 7:=0;

begin

process (CLK)
begin
   if falling_edge(CLK) then
      if LOAD = '1' then
         r_memory <= LOADREG;
         counter<=0;
         DATAVALID<='0';
      elsif ENB = '1' then
         r_memory <= r_memory(6 downto 0) & BITIN;
         if counter=6 then
            DATAVALID<='1';
            counter<=counter+1;
            
         elsif counter=7 then    
            counter<=0; 
        else
            counter<=counter+1;
            DATAVALID<='0';
         end if;
      end if;
   end if;
end process;

MSB <= r_memory(7);

end Behavioral;
