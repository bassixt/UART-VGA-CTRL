LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FIFO IS
GENERIC (
		CONSTANT N  : positive := 8;   --GRANDEZZA PAROLA
		CONSTANT M	: positive := 8  --NUMERO DI REGISTRI DI FIFO
		);
PORT    ( 
		CLOCK,RESETN,PUSH,POP	: IN  STD_LOGIC;
		DATA_IN	   : IN  STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		DATA_OUT   : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		EMPTY,FULL : OUT STD_LOGIC);
END FIFO;

ARCHITECTURE BEHAV OF FIFO is
 
BEGIN
 

LETTURA_SCRITTURA : process (CLOCK,RESETN)
		TYPE REG IS ARRAY (0 to M-1) OF STD_LOGIC_VECTOR (N-1 downto 0);
		VARIABLE REG_FIFO : REG;
		VARIABLE HEAD : INTEGER;
		VARIABLE TAIL : INTEGER;
		VARIABLE F_EN : boolean;  --SE TRUE ALLORA LA TESTA HA RAGGIUNTO LA CODA
								  --SE FALSE LA CODA HA RAGGIUNTO LA TESTA
		BEGIN
			IF RESETN = '0' then
			   HEAD := 0;
			   TAIL := 0;
			   F_EN := FALSE;
			   FULL  <= '0';
			   EMPTY <= '1';
			ELSE IF CLOCK' EVENT AND CLOCK='1' THEN
			
			--POP LETTURA DALLA FIFO E AGGIORNAMENTO PUNTATORI
				IF (POP = '1') THEN
					IF((F_EN = true) OR (HEAD /= TAIL)) then
						
						DATA_OUT <= REG_FIFO(TAIL);
						
						
						IF (TAIL = M-1) then
							TAIL := 0;
		                    F_EN := false;
						ELSE
							TAIL := TAIL + 1;
						END IF;
						
						
					END IF;
				END IF;
				--PUSH SCRITTURA NELLA FIFO E AGGIORNAMENTO PUNTATORI
				IF (PUSH = '1') THEN
					IF ((F_EN = FALSE) OR (HEAD /= TAIL)) THEN
						
						REG_FIFO(HEAD) := DATA_IN;
						
						IF (HEAD = M-1) THEN
							HEAD := 0;
							
							F_EN := TRUE;
						ELSE
							HEAD := HEAD + 1;
						END IF;
					END IF;
				END IF;
				
				-- GENERAZIONE SEGNALI FULL/EMPTY
				IF (HEAD = TAIL) THEN
					IF F_EN THEN
						FULL <= '1';
					ELSE
						EMPTY <= '1';
					END IF;
				ELSE
					EMPTY	<= '0';
					FULL	<= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
		
end BEHAV;