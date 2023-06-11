--------------------------------------
-- TRABALHO TP3 - MORAES 16/MAIO/23
--------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

--------------------------------------
-- Entidade
--------------------------------------
entity tp3 is 
  port (
    clock   : in std_logic;
    reset   : in std_logic;
    din     : in std_logic;
    dout    : out std_logic;
    padrao  : in std_logic_vector(7 downto 0);
    prog    : in std_logic_vector(2 downto 0);
    numero  : out std_logic_vector(1 downto 0);
    alarme  : out std_logic
  );
end entity; 

--------------------------------------
-- Arquitetura
--------------------------------------
architecture tp3 of tp3 is
  type state is (
    IDL,
    PRG1,
    PRG2,
    PRG3,
    PRG4,
    SRCH,
    BLK,
    RST
  );

  signal EA, next_state : state;
  signal data : std_logic_vector(7 downto 0);
  signal match : std_logic_vector(3 downto 0);
  signal alarme_int : std_logic;
  signal sel : std_logic_vector(3 downto 0);
  signal program: std_logic_vector(3 downto 0);
  signal found: std_logic;

begin  

  -- REGISTRADOR DE DESLOCAMENTO DO FLUXO DE ENTRADA
  process (clock, reset)
  begin
    if reset = '1' then
      data <= (others => '0');
    elsif rising_edge(clock) then
      data <= din & data(7 downto 1);
    end if;
  end process;

  -- 4 COMPARA_DADO
  CD0: entity work.compara_dado
    port map (
      clock    => clock,
      reset    => reset,
      habilita => sel(0),
      prog     => program(0),
      pattern  => padrao,
      dado     => data,
      match    => match(0)
    );


  CD1: entity work.compara_dado
    port map (
      clock    => clock,
      reset    => reset,
      habilita => sel(1),
      prog     => program(1),
      pattern  => padrao,
      dado     => data,
      match    => match(1)
    );

  CD2: entity work.compara_dado
    port map (
      clock    => clock,
      reset    => reset,
      habilita => sel(2),
      prog     => program(2),
      pattern  => padrao,
      dado     => data,
      match    => match(2)
    );

  CD3: entity work.compara_dado
    port map (
      clock    => clock,
      reset    => reset,
      habilita => sel(3),
      prog     => program(3),
      pattern  => padrao,
      dado     => data,
      match    => match(3)
    );


  -- MAQUINA DE ESTADOS
  process (clock, reset)
  begin
    if reset = '1' then
      EA <= IDL;
    elsif rising_edge(clock) then
      EA <= next_state;
    end if;
  end process;

  process (EA, prog, found)
  begin
    case EA is
      when IDL =>
        if prog = "000" then
          next_state <= IDL;
        elsif prog = "101" then
          next_state <= SRCH;
        elsif prog = "001" then
          next_state <= PRG1;
        elsif prog = "010" then
          next_state <= PRG2;
        elsif prog = "011" then
          next_state <= PRG3;
        elsif prog = "100" then
          next_state <= PRG4;
        end if;
      when PRG1 =>
        next_state <= IDL;
      when PRG2 =>
        next_state <= IDL;
      when PRG3 =>
        next_state <= IDL;
      when PRG4 =>
        next_state <= IDL;
      when SRCH =>
        if prog = "111" then
          next_state <= RST;
        elsif found = '1' then
          next_state <= BLK;
        else
          next_state <= SRCH;
        end if;
      when BLK =>
        if prog = "110" then
          next_state <= SRCH;
        elsif prog = "111" then
          next_state <= RST;
        else
          next_state <= BLK;
        end if;
      when RST =>
          next_state <= IDL;
      when others =>
        next_state <= IDL;
    end case;
  end process;

  program(0) <= '1' when EA = PRG1 else '0';
  program(1) <= '1' when EA = PRG2 else '0';
  program(2) <= '1' when EA = PRG3 else '0';
  program(3) <= '1' when EA = PRG4 else '0';

  -- SAIDAS
  dout <= din and not alarme_int;
  found <= match(0) or match(1) or match(2) or match(3);
  alarme <= alarme_int;
  numero <= "00" when match = "0001" else 
            "01" when match = "0010" else
            "10" when match = "0100" else
            "11" when match = "1000";
            
  -- REGISTRADORES PARA AS COMPARACOES;
  process (clock, reset)
  begin
    if reset = '1' then
      sel <= (others => '0');
    elsif rising_edge(clock) then
      if EA = PRG1 then
        sel(0) <= '1';
      elsif EA = PRG2 then
        sel(1) <= '1';
      elsif EA = PRG3 then
        sel(2) <= '1';
      elsif EA = PRG4 then
        sel(3) <= '1';
      elsif EA = RST then
        sel <= (others => '0');
      end if;
    end if;
  end process;

  -- REGISTRADOR PARA ALARME INTERNO
  process (clock, reset)
  begin
    if reset = '1' then
      alarme_int <= '0';
    elsif rising_edge(clock) then
      if EA = SRCH then
        alarme_int <= found;
      elsif EA = BLK then
        alarme_int <= '1';
      else
        alarme_int <= '0';
      end if;
    end if;
  end process;
end architecture;