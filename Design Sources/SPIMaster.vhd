library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPIMaster is
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
end SPIMaster;

architecture Behavioral of SPIMaster is

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

type states is (IDLE,LOADIN,SHIFT,LOADOUT);
signal state:states;

signal r_risingedge:std_logic:='0';
signal r_fallingedge:std_logic:='0';
signal r_load:std_logic:='0';
signal r_loadreg:std_logic_vector(7 downto 0):=X"00";
signal r_datavalid:std_logic:='0';
signal r_enb:std_logic:='0';
signal r_bytetoreceive:std_logic_vector(7 downto 0):=X"00";
signal r_clockcounter:integer range 0 to CLOCKS_PER_HALF_BIT+CLOCKS_PER_HALF_BIT-1;
signal r_bitcounter:integer range 0 to 7;
signal r_commandcounter:integer range 0 to BYTES_TO_SEND;
signal r_sclk:std_logic:='0';
signal r_ss:std_logic:='1';
signal r_sclk_en:std_logic:='0';

type COMMAND is array (0 to 2) of std_logic_vector(7 downto 0);
signal r_loadcontent:COMMAND:=(
                             0=>X"0B",
                             1=>X"00",
                             2=>X"AD"
                             );

begin

TheBrain:shiftRegister PORT MAP(
                                CLK=>CLOCK,
                                ENB=>r_enb,
                                LOAD=>r_load,
                                LOADREG=>r_loadreg,
                                DATAVALID=>r_datavalid,
                                BITIN=>MISO,
                                MSB=>MOSI
                                );

TheDivider:process(CLOCK,RESET)
begin
    if RESET='1' then
        r_sclk<='0';
        r_clockcounter<=0;
        r_risingedge<='0';
        r_fallingedge<='0';
    elsif rising_edge(CLOCK) then
        r_risingedge<='0';
        r_fallingedge<='0';
        if r_clockcounter=CLOCKS_PER_HALF_BIT-1 then
            r_sclk<='1';
            r_risingedge<='1';
            r_clockcounter<=r_clockcounter+1;
        elsif r_clockcounter=CLOCKS_PER_HALF_BIT+CLOCKS_PER_HALF_BIT-2 then
            r_sclk<='0';
            r_fallingedge<='1';
            r_clockcounter<=r_clockcounter+1;
        elsif r_clockcounter=CLOCKS_PER_HALF_BIT+CLOCKS_PER_HALF_BIT-1 then
            r_clockcounter<=0;
        else
            r_clockcounter<=r_clockcounter+1;
        end if;
    end if;
end process;

TheMachine:process(CLOCK,RESET)
begin
    if RESET='1' then
        state<=IDLE;
        r_load<='0';
        r_loadreg<=X"00";
        r_enb<='0';
        r_commandcounter<=0;
        r_ss<='1';
        r_sclk_en<='0';
        r_bitcounter<=0;
    elsif rising_edge(CLOCK) then
        case state is
            when IDLE=>
                --if r_risingedge='1' then
                    r_ss<='0';
                    r_load<='1';
                    r_loadreg<=r_loadcontent(r_commandcounter);
                    state<=LOADIN;
                --end if;
            when LOADIN=>
                --if r_risingedge='1' then
                    r_sclk_en<='1';
                    r_enb<='0';
                    r_load<='0';
                    state<=SHIFT;
                    if r_commandcounter<BYTES_TO_SEND then
                        r_commandcounter<=r_commandcounter+1;
                    else
                        r_commandcounter<=0;
                    end if;
                --end if;
            when SHIFT=>
                if r_fallingedge='1' then
                    r_enb<='1';
                    if r_datavalid='1' then--if the byte has been sent
                        if r_commandcounter<BYTES_TO_SEND then--if this is not the final byte
                            r_sclk_en<='0';
                            r_load<='1';
                            r_loadreg<=r_loadcontent(r_commandcounter);
                            state<=LOADIN;
                        else
                            r_ss<='1';
                            r_sclk_en<='0';
                            state<=LOADOUT;
                        end if;
                    end if;
                else
                    r_enb<='0';
                    if r_risingedge='1' then
                        r_bytetoreceive<=r_bytetoreceive(6 downto 0) & MISO;
                        if r_bitcounter=7 then
                            r_bitcounter<=0;
                        else
                            r_bitcounter<=r_bitcounter+1;
                        end if;
                    end if;
                end if;
            when LOADOUT=>
                --if r_fallingedge='1' then
                    BYTE_RECEIVED<='1';
                    BYTE_GOT<=r_bytetoreceive;
                --end if;
            when others=>
        end case;
    end if;
end process;

SS<=r_ss;
SCLK<=r_sclk when r_sclk_en='1' else '0';

end Behavioral;
