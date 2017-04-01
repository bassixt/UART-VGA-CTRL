-- Registro per dati di un solo bit campionato sul fronte di salita con segnali di "Load" e "Reset"
-- Il segnale di Reset è attivo basso

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Registro IS
PORT    (Input, Load, ResetN, Clock: IN STD_LOGIC;
		 Output: OUT STD_LOGIC);
END Registro;

ARCHITECTURE Behavior OF Registro IS

BEGIN

Reg: PROCESS(Clock, ResetN)
BEGIN
IF ResetN = '0' THEN
	Output <= '0';
ELSIF Clock 'EVENT AND Clock = '1' THEN
	IF Load = '1' THEN
		Output <= Input;
	END IF;
END IF;
END PROCESS;

END Behavior;