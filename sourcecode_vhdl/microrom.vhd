library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		 


entity microrom is
port(	
		ADDR	: in std_logic_vector(4 downto 0);
		DATA_OUT: out STD_LOGIC_VECTOR(23 downto 0)
);
end  microrom ;



architecture behavior of  microrom  is

    type microrom_data is array (0 to 31) 
	of STD_LOGIC_VECTOR(23 downto 0);

    constant ctrl_data: microrom_data := (
--             NEXT
--		       AAAAA
--             DDDDDAAAAAAAAA        D	
--		       DDDDDRRRRRRRRR AAASS  O
--   0        CRRRRRAAABBBCCCWWWW//SSN
--  addr      C43210210210210E210MA12E      stato    	
	    0 => "100000000000000000000000", -- idle	         5 00101
		1 => "000010000000000100000000", -- c_wi		     6 00110
		2 => "000011000000000100100000", -- c_wr             7 00111
		3 => "000100000000000101000000", -- c_br             8 01000	
		4 => "100111001010000101100000", -- c_bi	         9 01001
		5 => "001001011000100101001101", -- c_ai_1     	    10 01010
		6 => "001000010000000110000000", -- c_ar_0	        11 01011
		7 => "000101010000000110000001", -- c_ar_1       	12 01100	
		8 => "001010011000100101001100", -- c_ai_0    		13 01101
		9 => "001011011001010000001101", -- sum_3_1       	14 01110	
		10 =>"001100011001010000001100", -- sum_3_0		    15 01111
		11 =>"001101000100000000010111", -- sum_2_1	        16 10000
--             NEXT                                         17 10001
--		       AAAAN 										18 10010
--             DDDDDAAAAAAAAA        D						19 10011
--		       DDDDDRRRRRRRRR AAASS  O						20 10100
--            CRRRRRAAABBBCCCWWWW//SSN						21 10101
--    addr    C43210210210210E210MA12E      stato    	
		12 =>"001110000100000000010110", -- sum_2_0  		
		13 =>"001111000010000000011001", -- app_br_1
		14 =>"010000000010000000011000", -- app_br_0
		15 =>"010001000000000000001111", -- app_bi_1
        16 =>"010010000000000000001110", -- app_bi_0
		17 =>"010011000000000000001111", -- app_ar_1
		18 =>"010100000000000000001110", -- app_ar_0
		19 =>"100000000000000000000001", -- app_ai_1
		20 =>"100000000000000000000001", -- app_ai_0
		OTHERS=>"000000000000000000000000"	
		);       

begin
    process(ADDR)
    begin
        Data_out <= ctrl_data(to_integer(unsigned(ADDR)));
    end process;
end behavior;

