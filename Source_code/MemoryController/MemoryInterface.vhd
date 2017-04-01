-- "MemoryInterface" 
-- Macchina a stati da inserire nel "Memory Interface"
-- Leggendo nomi stati: Re = Read, Wr = Write, Di = Dispari, Pa = Pari, S = Si (Riferito allo start), N = No.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; 

ENTITY MemoryInterface IS
PORT (-- Input
	  Clock, ResetN: IN STD_LOGIC;
	  Start: IN STD_LOGIC;
	  Data_UART_Reg: IN STD_LOGIC_VECTOR(29 DOWNTO 0);
	  X: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	  Y: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
	  R_Wn: IN STD_LOGIC;
	  Ack_VGA_Reg: IN STD_LOGIC;
	  Ack_UART_Reg: IN STD_LOGIC;
	  -- Output
	  RGB: OUT STD_LOGIC_VECTOR(29 DOWNTO 0); 
	  Data_Mem: INOUT STD_LOGIC_VECTOR(0 TO 15);
	  Add: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
	  OEn: OUT STD_LOGIC;
	  CEn: OUT STD_LOGIC;
	  WEn: BUFFER STD_LOGIC;
	  UBn: OUT STD_LOGIC;
	  LBn: OUT STD_LOGIC;
	  Ack_VGA: OUT STD_LOGIC;
	  Ack_UART: OUT STD_LOGIC;
	  Data_UART_Out: OUT STD_LOGIC_VECTOR(29 DOWNTO 0)); 
END MemoryInterface;

ARCHITECTURE Structure OF MemoryInterface IS

COMPONENT Registro_NBit IS
GENERIC (N: POSITIVE := 29);
PORT    (Input: IN STD_LOGIC_VECTOR (N DOWNTO 0);
		 Load, ResetN, Clock: IN STD_LOGIC;
		 Output: OUT STD_LOGIC_VECTOR (N DOWNTO 0));
END COMPONENT;

COMPONENT Mux2To1 IS
GENERIC (N: POSITIVE :=33);
PORT    (In1,In2: IN STD_LOGIC_VECTOR( N DOWNTO 0);
         Output: OUT STD_LOGIC_VECTOR (N DOWNTO 0);
         Sel: IN STD_LOGIC);
END COMPONENT;

COMPONENT Registro IS
PORT    (Input, Load, ResetN, Clock: IN STD_LOGIC;
		 Output: OUT STD_LOGIC);
END COMPONENT;

TYPE StateType IS (Idle, Pre, ReVGAS1, ReVGAS2, ReVGAN1, ReVGAN2, ReUARTDiN, ReUARTDiS, ReUARTPaS, ReUARTPaN, WrDiS, WrDiN, WrPaS, WrPaN);
SIGNAL State: StateType;
SIGNAL Data_MEM_Reg: STD_LOGIC_VECTOR(0 TO 7);
SIGNAL Add_Reg: STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL Data_Mem_IN: STD_LOGIC_VECTOR(0 TO 15); 
SIGNAL Data_Mem_OUT, Data_Mem_In_Reg, OutMux1, OutMux2: STD_LOGIC_VECTOR(0 TO 7);
SIGNAL S1, S2: STD_LOGIC;

BEGIN 

Data_MEM_Reg(0) <= Data_UART_Reg(29);
Data_MEM_Reg(1) <= Data_UART_Reg(28);
Data_MEM_Reg(2) <= Data_UART_Reg(27);
Data_MEM_Reg(3) <= Data_UART_Reg(19);
Data_MEM_Reg(4) <= Data_UART_Reg(18);
Data_MEM_Reg(5) <= Data_UART_Reg(17);
Data_MEM_Reg(6) <= Data_UART_Reg(9);
Data_MEM_Reg(7) <= Data_UART_Reg(8);

Add_Reg(8 DOWNTO 0) <= X(9 DOWNTO 1);
Add_Reg(17 DOWNTO 9) <= Y;

Transition: PROCESS(Clock, ResetN) 
BEGIN
IF ResetN = '0' THEN  State <= Idle;
ELSIF (CLOCK 'EVENT AND CLOCK = '1') THEN 
	CASE State IS
	WHEN Idle => IF Start = '1' THEN State <= Pre; ELSE State <= Idle; END IF;
	WHEN Pre => IF R_Wn = '1' THEN IF Ack_VGA_Reg = '0' THEN IF X(0) = '1' THEN IF START = '1' THEN State <= ReUARTDiS; ELSE State <= ReUARTDiN; END IF; ELSE IF Start = '1' THEN State <= ReUARTPaS; ELSE State <= ReUARTPaN; END IF; END IF; ELSE IF Start = '1' THEN State <= ReVGAS1; ELSE State <= ReVGAN1; END IF; END IF; ELSE IF X(0) = '1' THEN IF Start = '1' THEN State <= WrDiS; ELSE State <= WrDiN; END IF; ELSE IF Start = '1' THEN State <= WrPaS; ELSE State <= WrPaN; END IF; END IF; END IF;
	WHEN ReVGAS1 => State <= ReVGAS2;
	WHEN ReVGAS2 => IF R_Wn = '1' THEN IF Ack_VGA_Reg = '0' THEN IF X(0) = '1' THEN IF START = '1' THEN State <= ReUARTDiS; ELSE State <= ReUARTDiN; END IF; ELSE IF Start = '1' THEN State <= ReUARTPaS; ELSE State <= ReUARTPaN; END IF; END IF; ELSE IF Start = '1' THEN State <= ReVGAS1; ELSE State <= ReVGAN1; END IF; END IF; ELSE IF X(0) = '1' THEN IF Start = '1' THEN State <= WrDiS; ELSE State <= WrDiN; END IF; ELSE IF Start = '1' THEN State <= WrPaS; ELSE State <= WrPaN; END IF; END IF; END IF;
	WHEN ReVGAN1 => State <= ReVGAN2;
	WHEN ReVGAN2 => IF Start = '1' THEN State <= Pre; ELSE State <= Idle; END IF;
	WHEN ReUARTDiS => IF R_Wn = '1' THEN IF Ack_VGA_Reg = '0' THEN IF X(0) = '1' THEN IF START = '1' THEN State <= ReUARTDiS; ELSE State <= ReUARTDiN; END IF; ELSE IF Start = '1' THEN State <= ReUARTPaS; ELSE State <= ReUARTPaN; END IF; END IF; ELSE IF Start = '1' THEN State <= ReVGAS1; ELSE State <= ReVGAN1; END IF; END IF; ELSE IF X(0) = '1' THEN IF Start = '1' THEN State <= WrDiS; ELSE State <= WrDiN; END IF; ELSE IF Start = '1' THEN State <= WrPaS; ELSE State <= WrPaN; END IF; END IF; END IF;
	WHEN ReUARTDiN => IF Start = '1' THEN State <= Pre; ELSE State <= Idle; END IF;
	WHEN ReUARTPaS => IF R_Wn = '1' THEN IF Ack_VGA_Reg = '0' THEN IF X(0) = '1' THEN IF START = '1' THEN State <= ReUARTDiS; ELSE State <= ReUARTDiN; END IF; ELSE IF Start = '1' THEN State <= ReUARTPaS; ELSE State <= ReUARTPaN; END IF; END IF; ELSE IF Start = '1' THEN State <= ReVGAS1; ELSE State <= ReVGAN1; END IF; END IF; ELSE IF X(0) = '1' THEN IF Start = '1' THEN State <= WrDiS; ELSE State <= WrDiN; END IF; ELSE IF Start = '1' THEN State <= WrPaS; ELSE State <= WrPaN; END IF; END IF; END IF;
	WHEN ReUARTPaN => IF Start = '1' THEN State <= Pre; ELSE State <= Idle; END IF;
	WHEN WrDiS => IF R_Wn = '1' THEN IF Ack_VGA_Reg = '0' THEN IF X(0) = '1' THEN IF START = '1' THEN State <= ReUARTDiS; ELSE State <= ReUARTDiN; END IF; ELSE IF Start = '1' THEN State <= ReUARTPaS; ELSE State <= ReUARTPaN; END IF; END IF; ELSE IF Start = '1' THEN State <= ReVGAS1; ELSE State <= ReVGAN1; END IF; END IF; ELSE IF X(0) = '1' THEN IF Start = '1' THEN State <= WrDiS; ELSE State <= WrDiN; END IF; ELSE IF Start = '1' THEN State <= WrPaS; ELSE State <= WrPaN; END IF; END IF; END IF;
	WHEN WrDiN => IF Start = '1' THEN State <= Pre; ELSE State <= Idle; END IF;
	WHEN WrPaS => IF R_Wn = '1' THEN IF Ack_VGA_Reg = '0' THEN IF X(0) = '1' THEN IF START = '1' THEN State <= ReUARTDiS; ELSE State <= ReUARTDiN; END IF; ELSE IF Start = '1' THEN State <= ReUARTPaS; ELSE State <= ReUARTPaN; END IF; END IF; ELSE IF Start = '1' THEN State <= ReVGAS1; ELSE State <= ReVGAN1; END IF; END IF; ELSE IF X(0) = '1' THEN IF Start = '1' THEN State <= WrDiS; ELSE State <= WrDiN; END IF; ELSE IF Start = '1' THEN State <= WrPaS; ELSE State <= WrPaN; END IF; END IF; END IF;
	WHEN WrPaN => IF Start = '1' THEN State <= Pre; ELSE State <= Idle; END IF;
	END CASE;
END IF;
END PROCESS;

ASM_Output: PROCESS(State)
BEGIN
CEn <= '0';
OEn <= '0';
UBn <= '1';
LBn <= '1';
WEn <= '0';
S1 <= '0';
S2 <= '0';
CASE State IS
WHEN Idle => CEn <= '1';
			 OEn <= '1';
WHEN Pre =>  WEn <= '1';
			 UBn <= '0';
			 LBn <= '0';
WHEN ReVGAS1 => WEn <= '1';
                UBn <= '0';
			    LBn <= '0';
WHEN ReVGAS2 => WEn <= '1';
                UBn <= '1';
			    LBn <= '1';
			    S1 <= '1';
WHEN ReVGAN1 => WEn <= '1';
                UBn <= '0';
			    LBn <= '0';
WHEN ReVGAN2 => WEn <= '1';
                UBn <= '1';
			    LBn <= '1';
			    S1 <= '1';
WHEN ReUARTDiS => WEn <= '1';
                  UBn <= '0';
			      LBn <= '1';
			      S2 <= '1';
WHEN ReUARTDiN => WEn <= '1';
                  UBn <= '0';
			      LBn <= '1';
			      S2 <= '1';
WHEN ReUARTPaS => WEn <= '1';
                  UBn <= '1';
			      LBn <= '0';
WHEN ReUARTPaN => WEn <= '1';
                  UBn <= '1';
			      LBn <= '0';  
WHEN WrDiS => WEn <= '0';
              UBn <= '0';
			  LBn <= '1';
WHEN WrDiN => WEn <= '0';
              UBn <= '0';
			  LBn <= '1';
WHEN WrPaS => WEn <= '0';
              UBn <= '1';
			  LBn <= '0';
WHEN WrPaN => WEn <= '0';
              UBn <= '1';
			  LBn <= '0';
END CASE;
END PROCESS;

Reg1: Registro_NBit GENERIC MAP (N => 7)
               PORT MAP (Input => Data_MEM_Reg, Output => Data_MEM_OUT, Load => '1', Clock => Clock, ResetN => ResetN);
Reg2: Registro_NBit GENERIC MAP (N => 17)
               PORT MAP (Input => Add_Reg, Output => Add, Load => '1', Clock => Clock, ResetN => ResetN);
Reg3: Registro_NBit GENERIC MAP (N => 7)
               PORT MAP (Input => Data_MEM_In(8 TO 15), Output => Data_MEM_In_Reg, Load => '1', Clock => Clock, ResetN => ResetN);
Reg4: Registro PORT MAP (Input => Ack_UART_Reg, Output => Ack_UART, Load => '1', Clock => Clock, ResetN => ResetN);
Reg5: Registro PORT MAP (Input => Ack_VGA_Reg, Output => Ack_VGA, Load => '1', Clock => Clock, ResetN => ResetN);
Mux1: Mux2To1 GENERIC MAP (N => 7)
			  PORT MAP (In1 => Data_MEM_In(0 TO 7), In2 => Data_MEM_In_Reg, Sel => S1, Output => OutMux1);
Mux2: Mux2To1 GENERIC MAP (N => 7)
			  PORT MAP (In1 => Data_MEM_In(0 TO 7), In2 => Data_MEM_In(8 TO 15), Sel => S2, Output => OutMux2);

MEM_OUT_P: PROCESS(WEn, Data_MEM_OUT, Data_MEM)
BEGIN
IF (WEn = '0') THEN
	Data_MEM(0 TO 7) <= Data_MEM_OUT;
	Data_MEM(8 TO 15) <= Data_MEM_OUT;
ELSE
	Data_MEM <= (OTHERS => 'Z');
END IF;
Data_MEM_IN <= Data_MEM;
END PROCESS;

Data_UART_Out(29) <= OutMux2(0);
Data_UART_Out(28) <= OutMux2(1);
Data_UART_Out(27) <= OutMux2(2);
Data_UART_Out(19) <= OutMux2(3);
Data_UART_Out(18) <= OutMux2(4);
Data_UART_Out(17) <= OutMux2(5);
Data_UART_Out(9) <= OutMux2(6);
Data_UART_Out(8) <= OutMux2(7);
Data_UART_Out(26 DOWNTO 20) <= (OTHERS => '0');
Data_UART_Out(16 DOWNTO 10) <= (OTHERS => '0');
Data_UART_Out(7 DOWNTO 0) <= (OTHERS => '0');

RGB(29) <= OutMux1(0);
RGB(28) <= OutMux1(1);
RGB(27) <= OutMux1(2);
RGB(19) <= OutMux1(3);
RGB(18) <= OutMux1(4);
RGB(17) <= OutMux1(5);
RGB(9) <= OutMux1(6);
RGB(8) <= OutMux1(7);
RGB(26 DOWNTO 20) <= (OTHERS => '0');
RGB(16 DOWNTO 10) <= (OTHERS => '0');
RGB(7 DOWNTO 0) <= (OTHERS => '0');

END Structure;