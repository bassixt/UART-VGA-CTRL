-- ReadWriteN
-- Blocco combinatorio per la macchina a stati denominata "Arbitro" da inserire nel "MemoryController"

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ReadWriteN IS
PORT (In1, In2, In3: IN STD_LOGIC;
	  Output: OUT STD_LOGIC);
END ReadWriteN;

ARCHITECTURE Structure OF ReadWriteN IS

BEGIN

Output <= In3 OR In1 OR NOT(In2);

END Structure;