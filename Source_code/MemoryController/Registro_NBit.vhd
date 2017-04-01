-- Registro per dati di N bit campionato sul fronte di salita con segnali di "Load" e "Reset"
-- Il segnale di Reset è attivo basso

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Registro_NBit IS
GENERIC (N: POSITIVE := 29);
PORT    (Input: IN STD_LOGIC_VECTOR (N DOWNTO 0);
		 Load, ResetN, Clock: IN STD_LOGIC;
		 Output: OUT STD_LOGIC_VECTOR (N DOWNTO 0));
END Registro_NBit;

ARCHITECTURE Behavior OF Registro_NBit IS

BEGIN

Reg: PROCESS(Clock, ResetN)
BEGIN
IF ResetN = '0' THEN
	Output <= (OTHERS => '0');
ELSIF Clock 'EVENT AND Clock = '1' THEN
	IF Load = '1' THEN
		Output <= Input;
	END IF;
END IF;
END PROCESS;

END Behavior;