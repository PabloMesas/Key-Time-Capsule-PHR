ENTITY exponenciacion IS
PORT (	t: IN std_logic_vector(10000 DOWNTO 0); 
	N: IN std_logic_vector(1023 DOWNTO 0); 
	s: Out std_logic_vector (1023 DOWNTO 0)
);
END exponenciacion;

 exponFun OF  exponenciacion IS
 VARIABLE i, x: IN INTEGER;
 BEGIN 
	i=0;
	FOR (i; i< 10000; i++){
		IF ...	
	} 