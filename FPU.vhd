library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity FPU is
	port(
		input1 : in  std_logic_vector(31 downto 0);
		input2 : in  std_logic_vector(31 downto 0);
		output : out std_logic_vector(31 downto 0)
	);
end FPU;

architecture Behavioral of FPU is
begin	
	
	process(input1, input2)
	variable Exponent : std_logic_vector(8 downto 0) := "000000000";
	variable Exponent1 : std_logic_vector(8 downto 0) := "000000000";
	variable Exponent2 : std_logic_vector(8 downto 0) := "000000000";
	variable Exponent2p : std_logic_vector(8 downto 0) := "000000000";
	variable Fraction1 : std_logic_vector(28 downto 0);
	variable Fraction2 : std_logic_vector(28 downto 0);
	variable sign1 : std_logic;
	variable sign2 : std_logic;
	variable sign : std_logic;
	variable leftF, rightF : std_logic_vector(28 downto 0) := (others => '0');
	variable leftFp, rightFp : std_logic_vector(28 downto 0) := (others => '0');
	variable shiftValueV : std_logic_vector(8 downto 0);
	variable shiftValueI : natural ;
	variable sumBigALU : std_logic_vector(28 downto 0);
	variable FracRes : std_logic_vector(28 downto 0) := (others => '0');
	variable co9 : std_logic;
	variable FracResp : std_logic_vector(28 downto 0);
	variable S,s1,s2,s3 : std_logic;
	variable shifted : std_logic_vector(28 downto 0) ;
	variable normShiftValue : integer := 0;
	variable resFrac : std_logic_vector(28 downto 0) := (others => '0');
	variable ExpNorm1 : std_logic_vector(8 downto 0);
	variable roundFrac1, roundFrac2 : std_logic_vector(28 downto 0) := (others => '0');
	variable xorvector0 : std_logic_vector(28 downto 0) := (others => '0');
	variable xorvector1 : std_logic_vector(28 downto 0) := (others => '1');
	variable xor1 : std_logic_vector(28 downto 0) := (0=>'1', others => '0');
	variable ExpRes : std_logic_vector(8 downto 0);
	begin
		-- initialization the signals
		-- determine sign of inputs
		sign1 := input1(31);
		sign2 := input2(31);
		
		-- unpack Exponent and Fraction for input1
		if Exponent1 = "000000000" then
			Exponent1(8 downto 0) := "111111111";
			Fraction1(28 downto 26) := "000";
			Fraction1(25 downto 3) := input1(22 downto 0);
			Fraction1(2 downto 0) := "000";
		else
			Exponent1(8) := '0';
			Exponent1(7 downto 0) := input1(30 downto 23);
			Fraction1(28 downto 26) := "001";
			Fraction1(25 downto 3) := input1(22 downto 0);
			Fraction1(2 downto 0) := "000";
		end if;
		
		-- unpack Exponent and Fraction for input2
		if Exponent1 = "000000000" then
			Exponent2(8 downto 0) := "111111111";
			Fraction2(28 downto 26) := "000";
			Fraction2(25 downto 3) := input2(22 downto 0);
			Fraction2(2 downto 0) := "000";
		else
			Exponent2(8) := '0';
			Exponent2(7 downto 0) := input2(30 downto 23);
			Fraction2(28 downto 26) := "001";
			Fraction2(25 downto 3) := input2(22 downto 0);
			Fraction2(2 downto 0) := "000";
		end if;
		
		-- compare Exponent
		Exponent2p(8 downto 0) := ("111111111" xor Exponent2(8 downto 0)) + "000000001";
		ExpRes := Exponent1 + Exponent2p;
		if ExpRes(8) = '1' then
			shiftValueV := ("111111111" xor ExpRes(8 downto 0)) + "000000001";
		else
			shiftValueV := ExpRes;
		end if;
		shiftValueI := to_integer(unsigned(shiftValueV));
		
		-- if Exponents is equal
		if ExpRes = "000000000" then
			-- Find larger Fraction and determine that need two's complement or not
			if Fraction1 > Fraction2 then
				sign := sign1;
				leftF := Fraction2;
				rightF := Fraction1;
				Exponent := Exponent1;
				
				if sign1 = '1' then
					rightFp := (xorvector1 xor rightF) + xor1;
				else
					rightFp := rightF;
				end if;
				if sign2 = '1' then
					leftFp := (xorvector1 xor leftF) + xor1;
				else
					leftFp := leftF;
				end if;
				
			elsif Fraction1 < Fraction2 then
				sign := sign2;
				leftF := Fraction1;
				rightF := Fraction2;
				Exponent := Exponent2;
				if sign1 = '1' then
					leftFp := (xorvector1 xor leftF) + xor1;
				else
					leftFp := leftF;
				end if;
				if sign2 = '1' then
					rightFp := (xorvector1 xor rightF) + xor1;
				else
					rightFp := rightF;
				end if;
				
			elsif Fraction1 = Fraction2 then
				sign := '0';
				if sign1 = '1' then
					leftFp := (xorvector1 xor Fraction1) + xor1;
				else
					leftFp := Fraction1;
				end if;
				if sign2 = '1' then
					rightFp := (xorvector1 xor Fraction2) + xor1;
				else
					rightFp := Fraction2;
				end if;
				Exponent := Exponent1;
			end if;

		-- if Exponent2 is larger than Ecponent1:
		elsif ExpRes(8) = '1' then
			Exponent := Exponent2;
			
			-- sticky bit
			shifted := std_logic_vector(shift_left(unsigned(Fraction1), 28- shiftValueI));
			if shifted = xorvector0 then
				s := '0';
			else 
				s := '1';
			end if;
			
			-- determine both side of Big ALU
			leftF := std_logic_vector(shift_right(unsigned(Fraction1), shiftValueI));
			leftF(0) := s;
			rightF := Fraction2;
			
			-- determine sign of final result
			sign := sign2;
			
			-- convert to two's complement regard to its sign
			if sign1 = '1' then
				leftFp := (xorvector1 xor leftF) + xor1;
			else
				leftFp := leftF;
			end if;
			if sign2 = '1' then
				rightFp := (xorvector1 xor rightF) + xor1;
			else
				rightFp := rightF;
			end if;
			
		else
			Exponent := Exponent1;
			-- sticky bit
			shifted := std_logic_vector(shift_left(unsigned(Fraction2), 28- shiftValueI));
			if shifted = xorvector0 then
				s := '0';
			else 
				s := '1';
			end if;
			-- determine both side of Big ALU
			leftF := std_logic_vector(shift_right(unsigned(Fraction2), shiftValueI));
			leftF(0) := s;
			rightF := Fraction1;
			-- determine sign of final result
			sign := sign1;
			
			-- convert to two's complement regard to its sign
			if sign1 = '1' then
				rightFp := (xorvector1 xor rightF) + xor1;
			else
				rightFp := rightF;
			end if;
			if sign2 = '1' then
				leftFp := (xorvector1 xor leftF) + xor1;
			else 
				leftFp := leftF;
			end if;
			
		end if;

		FracRes := leftFp + rightFp;
		
		if FracRes(28) = '1' then
			FracResp := (xorvector1 xor FracRes) + xor1;
		else 
			FracResp := FracRes;
		end if;
		
		if FracResp = xorvector0 then
			Exponent := "000000000";
		end if;
		
		if FracResp(27) = '0' then 
			if     FracResp(26) = '1' then normShiftValue := 1;
			elsif  FracResp(25) = '1' then normShiftValue := 2;elsif  FracResp(24) = '1' then normShiftValue := 3;
			elsif  FracResp(23) = '1' then normShiftValue := 4;elsif  FracResp(22) = '1' then normShiftValue := 5;
			elsif  FracResp(21) = '1' then normShiftValue := 6;elsif  FracResp(20) = '1' then normShiftValue := 7;
			elsif  FracResp(19) = '1' then normShiftValue := 8;elsif  FracResp(18) = '1' then normShiftValue := 9;
			elsif  FracResp(17) = '1' then normShiftValue := 10;elsif  FracResp(16) = '1' then normShiftValue := 11;
			elsif  FracResp(15) = '1' then normShiftValue := 12;elsif  FracResp(14) = '1' then normShiftValue := 13;
			elsif  FracResp(13) = '1' then normShiftValue :=14;elsif  FracResp(12) = '1' then normShiftValue := 15;
			elsif  FracResp(11) = '1' then normShiftValue := 16;elsif  FracResp(10) = '1' then normShiftValue := 17;
			elsif  FracResp(9) = '1' then normShiftValue := 18;elsif  FracResp(8) = '1' then normShiftValue := 19;
			elsif  FracResp(7) = '1' then normShiftValue := 20;elsif  FracResp(6) = '1' then normShiftValue := 21;
			elsif  FracResp(5) = '1' then normShiftValue := 22;elsif  FracResp(4) = '1' then normShiftValue := 23;
			elsif  FracResp(3) = '1' then normShiftValue :=24;elsif  FracResp(2) = '1' then normShiftValue :=25;
			elsif  FracResp(1) = '1' then normShiftValue :=26;elsif  FracResp(0) = '1' then normShiftValue :=27;
			else normShiftValue := 0;
			end if;	
			
			if normShiftValue = 0 then
				resFrac := FracResp;
				ExpNorm1 := Exponent;
			else
				if Exponent > normShiftValue then
					s1 := FracResp(0);
					resFrac := std_logic_vector(shift_left(unsigned(FracResp), normShiftValue -1));
					resFrac(0) := s1;
					ExpNorm1 := std_logic_vector(to_unsigned(to_integer(unsigned(Exponent)) - normShiftValue + 1, 9));
				else
					s1 := FracResp(0);
					resFrac := std_logic_vector(shift_left(unsigned(FracResp),  to_integer(unsigned(Exponent))));
					resFrac := std_logic_vector(shift_right(unsigned(FracResp),  1));
					resFrac(0) := s1;
					ExpNorm1 := "000000001";
				end if;
				
			end if;

		-- if FracResp(27) = '1' then we should shift it in right in amount of 1
		else
			ExpNorm1 := Exponent + "000000001";
			s3 :=FracResp(0) or FracResp(1);
			resFrac := std_logic_vector(shift_right(unsigned(FracResp), 1));
			resFrac(0) := s3;
		end if;
		
		-- rounding
		if resFrac(2)='1' then 
			if resFrac(1)='1' or resFrac(0)='1' then
				roundFrac1 := resFrac + x"8";
			end if;
			if resFrac(1)='0' and resFrac(0)='0' then
				if resFrac(3) = '1' then
					roundFrac1 := resFrac + x"8";
				else
					roundFrac1 := resFrac + x"0";
				end if;
			end if;
		elsif resFrac(2)='0' then
			roundFrac1 := resFrac;
		end if;
		
		-- normalize again
		if roundFrac1(27) = '1' then 
			roundFrac2 := std_logic_vector(shift_right(unsigned(roundFrac1), 1));
		else
			roundFrac2 := roundFrac1;
		end if;
		

		output(31) <= sign;
		output(30 downto 23) <= ExpNorm1(7 downto 0);
		output(22 downto 0) <= roundFrac2(25 downto 3);

			
	end process;
	

end Behavioral;