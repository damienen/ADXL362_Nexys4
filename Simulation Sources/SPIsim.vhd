library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPIsim is
end SPIsim;

architecture Behavioral of SPIsim is

component SPIMaster is
 Generic ( 
           CLOCKS_PER_HALF_BIT:integer:=16;
           BYTES_TO_SEND:integer:=3
          );
 Port ( CLOCK:in std_logic;--SOLVED
        RESET:in std_logic;--SOLVED
        
        BYTE_GOT:out std_logic_vector(7 downto 0);
        BYTE_RECEIVED:out std_logic;
        
        SCLK:out std_logic;--SOLVED
        MOSI:out std_logic;--SOLVED
        MISO:in std_logic;--SOLVED
        SS:out std_logic
 
 );
end component SPIMaster;

signal r_reset:std_logic:='1';
signal r_clock:std_logic:='0';
signal r_bytegot:std_logic_vector(7 downto 0):=X"00";
signal r_bytereceived:std_logic:='0';
signal r_sclk:std_logic:='0';
signal r_mosi:std_logic:='0';
signal r_ss:std_logic:='1';
begin

UUT:SPIMaster GENERIC MAP(CLOCKS_PER_HALF_BIT=>16,BYTES_TO_SEND=>3)
                 PORT MAP(
                          CLOCK=>r_clock,
                          RESET=>r_reset,
                          BYTE_GOT=>r_bytegot,
                          BYTE_RECEIVED=>r_bytereceived,
                          SCLK=>r_sclk,
                          MOSI=>r_mosi,
                          MISO=>r_mosi,
                          ss=>r_ss
                          );
                          
ResetProcess:process
begin
wait for 200ns;
r_reset<='0';
wait for 200ns;
r_reset<='1';
wait for 200ns;
r_reset<='0';
wait for 5000ns;
end process;

r_clock<=not r_clock after 2ns;

end Behavioral;
