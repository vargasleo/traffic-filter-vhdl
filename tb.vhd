-------------------------------------
-- Biblioteca
--------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

--------------------------------------
-- Entidade
--------------------------------------
entity tb is
end entity;

--------------------------------------
-- Arquitetura
--------------------------------------
architecture tb of tb is

  type test_record is record
    t      : integer;
    prog   : std_logic_vector(2 downto 0);
    padrao : std_logic_vector(7 downto 0);
  end record;

  type padroes is array(natural range <>) of test_record;
   constant padrao_de_teste : padroes := (
    (t =>   4, prog => "001", padrao => x"ED"),   
    (t =>  10, prog => "010", padrao => x"70"),
    (t =>  15, prog => "011", padrao => x"44"),
    (t =>  20, prog => "100", padrao => x"9D"),    
    (t =>  35, prog => "101", padrao => x"FF"),    -- ATIVA A COMPARA��O (5)
    (t =>  40, prog => "110", padrao => x"FF"),    -- reinicia a compara��o (6)
    (t =>  46, prog => "110", padrao => x"FF"),    -- reinicia a compara��o (6)
    (t =>  57, prog => "110", padrao => x"FF"),    -- reinicia a compara��o (6)
    (t => 65, prog => "111", padrao => x"FF"),     -- reinicializa (7)
    (t =>  72, prog => "011", padrao => x"3B"),    -- Programa��o de um novo padr�o
    (t =>  75, prog => "101", padrao => x"FF"),    -- ATIVA A COMPARA��O (5)
    (t =>  83, prog => "110", padrao => x"FF"),    -- reinicia a compara��o (6)
    (t => 85, prog => "111", padrao => x"FF")     -- reinicializa (7)    
  );


  -- LFSR: ----------------------------------------------- x^19+x^18+x^17+x^14+x?9+1
  constant GP : integer := 19 ;
  constant polinomio : std_logic_vector(GP-1 downto 0) := "1110010000100000000";
  --constant seed : std_logic_vector(GP-1 downto 0)      := "1101101110110110010";
  constant seed : std_logic_vector(GP-1 downto 0)      := "1101101110110001010";
  signal lfsr, w_mask: std_logic_vector(GP-1 downto 0);
  ----------------------------------------------------------------------------

  signal clock : std_logic := '0'; 
  signal reset, din, dout, alarme : std_logic := '0';
   
  signal prog: std_logic_vector(2 downto 0) := "000";
  signal numero: std_logic_vector(1 downto 0) := "00";

  signal conta_tempo : integer := 0;
  signal padrao : std_logic_vector(7 downto 0);
begin

  reset <= '1', '0' after 2 ns;
  clock <= not clock after 5 ns;

  DUT: entity work.tp3  
       port map(clock=>clock, reset=>reset,  din=>din, prog=>prog, padrao=>padrao, 
                dout=>dout, alarme=>alarme, numero=>numero );

  -- injeta a programa��o e o padr�es 
  process(clock, reset)
  begin
    if reset = '1' then
      conta_tempo <= 0;
    elsif rising_edge(clock) then
      conta_tempo <= conta_tempo + 1;

      for i in 0 to padrao_de_teste'high loop    
        if padrao_de_teste(i).t = conta_tempo then
          prog <= padrao_de_teste(i).prog, "000" after 10 ns;
          padrao <= padrao_de_teste(i).padrao;
        end if;
      end loop;

    end if;
  end process;


  -- lfsr -------------------------------------- gera DIN de forma pseudo-aleatoria 
  g_mask : for k in GP-1 downto 0 generate
    w_mask(k) <= polinomio(k) and lfsr(0);
  end generate;

  process (clock, reset) begin
    if reset = '1' then
      lfsr <= seed;
    elsif rising_edge(clock) then
      lfsr <=  ('0' & lfsr(GP-1 downto 1))  xor w_mask ;
    end if;
  end process;

  din <= lfsr(0);
  -- end lfsr -----------------------------------------------------------------------


end architecture;