-- Arbitro Versione 2 (USARE QUESTA)
-- Macchina a stati da inserire nel progetto "MemoryController"

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; 

ENTITY Arbitro IS 
PORT (-- Ingressi
	  Clock, ResetN: IN STD_LOGIC;
	  Data_UART_In: IN STD_LOGIC_VECTOR(29 DOWNTO 0);
	  X_UART: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	  Y_UART: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
	  RD, WR: IN STD_LOGIC;
	  X_VGA: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	  Y_VGA: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
	  Req_VGA: IN STD_LOGIC;
	  -- Uscite
	  Data_UART_Reg: OUT STD_LOGIC_VECTOR(29 DOWNTO 0);
	  X: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	  Y: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
	  R_Wn: BUFFER STD_LOGIC;
	  Ack_UART_Reg: OUT STD_LOGIC;
	  Ack_VGA_Reg: OUT STD_LOGIC;
	  Start: OUT STD_LOGIC);
END Arbitro;

ARCHITECTURE Structure OF Arbitro IS

COMPONENT Registro IS
PORT    (Input, Load, ResetN, Clock: IN STD_LOGIC;
		 Output: OUT STD_LOGIC);
END COMPONENT;

COMPONENT ReadWriteN IS
PORT (In1, In2, In3: IN STD_LOGIC;
	  Output: OUT STD_LOGIC);
END COMPONENT;

COMPONENT Mux2To1 IS
GENERIC (N: POSITIVE :=33);
PORT    (In1,In2: IN STD_LOGIC_VECTOR( N DOWNTO 0);
         Output: OUT STD_LOGIC_VECTOR (N DOWNTO 0);
         Sel: IN STD_LOGIC);
END COMPONENT;

COMPONENT Registro_NBit IS
GENERIC (N: POSITIVE := 29);
PORT    (Input: IN STD_LOGIC_VECTOR (N DOWNTO 0);
		 Load, ResetN, Clock: IN STD_LOGIC;
		 Output: OUT STD_LOGIC_VECTOR (N DOWNTO 0));
END COMPONENT;

TYPE StateType IS (Idle, UART, VGA);
SIGNAL State: StateType;
SIGNAL Req_UART, Sel, RD_Reg, WR_Reg, R_Wn_Reg, S, Req_VGA_Reg, Start_In: STD_LOGIC;
SIGNAL X_UART_Reg, X_VGA_Reg: STD_LOGIC_VECTOR (9 DOWNTO 0);
SIGNAL Y_UART_Reg, Y_VGA_Reg: STD_LOGIC_VECTOR (8 DOWNTO 0);
 

BEGIN 

Transition: PROCESS(Clock, ResetN) 
BEGIN
IF ResetN = '0' THEN  State <= Idle;
ELSIF (CLOCK 'EVENT AND CLOCK = '1') THEN 
	CASE State IS
	WHEN Idle => IF Start_In = '1' THEN IF Sel = '1' THEN State <= VGA; ELSE State <= UART; END IF; ELSE State <= Idle; END IF;
	WHEN UART => IF Start_In = '1' THEN IF Sel = '1' THEN State <= VGA; ELSE State <= UART; END IF; ELSE State <= Idle; END IF;
	WHEN VGA => IF Start_In = '1' THEN IF Sel = '1' THEN State <= VGA; ELSE State <= UART; END IF; ELSE State <= Idle; END IF;
	END CASE;
END IF;
END PROCESS;

ASM_Output: PROCESS(State)
BEGIN
S <= '0';
Ack_UART_Reg <= '0';
Ack_VGA_Reg <= '0';
CASE State IS
WHEN Idle => 
WHEN UART => Ack_UART_Reg <= '1';
WHEN VGA => Ack_VGA_Reg <= '1';
			S <= '1';
END CASE;
END PROCESS;

Req_UART <= RD_Reg OR WR_Reg;
Sel <= Req_VGA_Reg;
Start_In <= Req_UART OR Req_VGA_Reg;
Start <= Start_In;


Reg1: Registro_NBit GENERIC MAP (N => 29)
					PORT MAP (Input => Data_UART_In, Output => Data_UART_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg2: Registro_NBit GENERIC MAP (N => 8)
					PORT MAP (Input => Y_UART, Output => Y_UART_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg3: Registro_NBit GENERIC MAP (N => 9)
					PORT MAP (Input => X_UART, Output => X_UART_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg4: Registro PORT MAP (Input => RD, Output => RD_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg5: Registro PORT MAP (Input => WR, Output => WR_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg7: Registro_NBit GENERIC MAP (N => 8)
					PORT MAP (Input => Y_VGA, Output => Y_VGA_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg8: Registro_NBit GENERIC MAP (N => 9)
					PORT MAP (Input => X_VGA, Output => X_VGA_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg9: Registro PORT MAP (Input => Req_VGA, Output => Req_VGA_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg10: Registro PORT MAP (Input => R_Wn_Reg, Output => R_Wn, Load => '1', Clock => Clock, ResetN => ResetN);

Mux2: Mux2To1 GENERIC MAP (N => 8)
		      PORT MAP (In1 => Y_UART_Reg, In2 => Y_VGA_Reg, Sel => S, Output => Y);
Mux3: Mux2To1 GENERIC MAP (N => 9)
		      PORT MAP (In1 => X_UART_Reg, In2 => X_VGA_Reg, Sel => S, Output => X);
		      
Gener_RWn: ReadWriteN PORT MAp (In1 => RD_Reg, In2 => WR_Reg, In3 => Sel, Output => R_Wn_Reg);

END Structure;