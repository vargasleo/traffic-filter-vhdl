library IEEE;
use IEEE.std_logic_1164.all;

entity compara_dado is 
  port (
    clock    : in std_logic;
    reset    : in std_logic;
    habilita : in std_logic;
    prog     : in std_logic;
    pattern  : in std_logic_vector(7 downto 0);
    dado     : in std_logic_vector(7 downto 0);
    match    : out std_logic
  );
end compara_dado; 

architecture a1 of compara_dado is
  signal padrao : std_logic_vector(7 downto 0);
  signal igual : std_logic;
begin
  process(clock, reset)
  begin
    if reset = '1' then
      padrao <= (others => '0');
    elsif rising_edge(clock) then
      if prog = '1' then
        padrao <= pattern;
      end if;
    end if;
  end process;

  igual <= '1' when dado = padrao else '0';

  match <= igual and habilita;

end a1;