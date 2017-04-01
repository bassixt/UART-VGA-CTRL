library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		 


entity microrom is
port(	
		X: in std_logic_vector(9 downto 0);
		Y: in std_logic_vector(8 downto 0);
		CLOCK,REQ,RESETN: in STD_LOGIC;
		ACK: OUT STD_LOGIC;
		DATA_OUT: out STD_LOGIC_VECTOR(29 downto 0)
		
);
end  microrom ;



architecture behavior of  microrom  is

    type microrom_data is array (0 to 256*2**10) 
	of STD_LOGIC_VECTOR(15 downto 0);

    constant ctrl_data: microrom_data := (
	
	        0 => "0000000000000001",
			1 => "0000001000000011", 
			2 => "0000010000000101", 
			3 => "0000011000000111", 	
			4 => "0000100000001001", 
			5 => "0000101000001011", 
			6 => "0000110000001101", 
			7 => "0000111000011111", 
			8 => "0001000000010001", 
			9 => "0001001000010011", 	
			10 =>"0001010000010101", 	    
			11 =>"0000000000000000",         
			12 =>"0000000000000000",  		
			13 =>"0000000000000000", 
			14 =>"0000000000000000", 
			15 =>"0000000000000000", 
        	16 =>"0000000000000000", 
			17 =>"0000000000000000", 
			18 =>"0000000000000000", 
			19 =>"0000000000000000",
			OTHERS=>"0000000000000000"	
		);       
	

	SIGNAL ADDR :STD_LOGIC_VECTOR(17 DOWNTO 0);
begin
	

    process(CLOCK,RESETN)
	VARIABLE CONT:INTEGER;
	VARIABLE data_appoggio:std_logic_vector(7 downto 0);
	VARIABLE DATA_OUT_S:STD_LOGIC;
	VARIABLE MEM_TO_OUT:STD_LOGIC_VECTOR(15 DOWNTO 0);
    begin		
	
	ADDR(8 DOWNTO 0)<=X(9 DOWNTO 1);
	ADDR(17 DOWNTO 9)<=Y(8 DOWNTO 0);

	IF RESETN='0' THEN
		ACK<='0';
		CONT:=0;
	ELSE
    	IF CLOCK' EVENT AND CLOCK='1' THEN
		IF REQ='0' THEN
			CONT:=0;
			ACK<='0';
		ELSE
			CONT:=CONT+1;
			IF CONT>=1 THEN
				ACK<='1';
				MEM_TO_OUT:= ctrl_data(to_integer(unsigned(ADDR)));
				IF X(0)='1' THEN
				--	MEM_TO_OUT<= ctrl_data(to_integer(unsigned(ADDR)));
					data_appoggio:=MEM_TO_OUT(7 DOWNTO 0);
					DATA_OUT_S:=MEM_TO_OUT(7);
				ELSE
					
					data_appoggio:=MEM_TO_OUT(15 DOWNTO 8);
					DATA_OUT_S:=MEM_TO_OUT(15);
				END IF;

			END IF;
		END IF;
	END IF;
	END IF;
					DATA_OUT(7 DOWNTO 0)<=data_appoggio;
    				DATA_OUT(8)<=DATA_OUT_S;
					DATA_OUT(9)<=DATA_OUT_S;
					DATA_OUT(10)<=DATA_OUT_S;
					DATA_OUT(11)<=DATA_OUT_S;
					DATA_OUT(12)<=DATA_OUT_S;
					DATA_OUT(13)<=DATA_OUT_S;
					DATA_OUT(14)<=DATA_OUT_S;
					DATA_OUT(15)<=DATA_OUT_S;
					DATA_OUT(16)<=DATA_OUT_S;
					DATA_OUT(17)<=DATA_OUT_S;
					DATA_OUT(18)<=DATA_OUT_S;
					DATA_OUT(19)<=DATA_OUT_S;
					DATA_OUT(20)<=DATA_OUT_S;
					DATA_OUT(21)<=DATA_OUT_S;
					DATA_OUT(22)<=DATA_OUT_S;
					DATA_OUT(23)<=DATA_OUT_S;
					DATA_OUT(24)<=DATA_OUT_S;
					DATA_OUT(25)<=DATA_OUT_S;
					DATA_OUT(26)<=DATA_OUT_S;
					DATA_OUT(27)<=DATA_OUT_S;
					DATA_OUT(28)<=DATA_OUT_S;
					DATA_OUT(29)<=DATA_OUT_S;
    end process;	

end behavior;

