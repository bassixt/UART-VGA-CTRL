LIBRARY ieee ;
USE ieee.std_logic_1164.all ;


ENTITY voter IS
PORT ( c1,c2,c3,c4,c5 : IN STD_LOGIC ;
       v : OUT STD_LOGIC ) ;
END voter; 
ARCHITECTURE behav OF voter IS
BEGIN
 v <=(  NOT c5 AND ((c4 AND c3 AND c2 ) OR ( c1 AND c3 AND c4 ) OR (c3 AND c1 AND c2 ) OR ( c4 AND  c1 AND c2)))OR
      ( c5 AND ((c4 AND c3 ) OR ( c1 AND c2 ) OR (c3 AND c1 ) OR ( c4 AND  c1) OR ( c3 AND c2 ) OR ( c4 AND c2)));
END behav ; 