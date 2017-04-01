-- Multiplexer a due vie generico di tipo std logic

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Mux2To1 IS
GENERIC (N: POSITIVE :=33);
PORT    (In1,In2: IN STD_LOGIC_VECTOR( N DOWNTO 0);
         Output: OUT STD_LOGIC_VECTOR (N DOWNTO 0);
         Sel: IN STD_LOGIC);
END Mux2To1;

ARCHITECTURE Behavior OF Mux2To1 IS
BEGIN 
MuxProcess: PROCESS(In1, In2, Sel)
BEGIN
IF Sel = '0' THEN
	Output <= In1;
ELSE
	Output <= In2;
END IF;
END PROCESS;
END Behavior;