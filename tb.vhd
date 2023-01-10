LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;
 

 
ENTITY test IS
END test;
 
ARCHITECTURE behavior OF test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FPU
    PORT(
         input1 : IN  std_logic_vector(31 downto 0);
         input2 : IN  std_logic_vector(31 downto 0);
         output : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal input1 : std_logic_vector(31 downto 0) := x"00000000";
   signal input2 : std_logic_vector(31 downto 0) := x"00000000";

 	--Outputs
   signal output : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1 ns;
	
	file output_buf : text; 
	file input_buf : text;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: FPU PORT MAP (
          input1 => input1,
          input2 => input2,
          output => output
        );
		  

		  
		PROCESS
		variable wb : line;
		begin
		file_open(output_buf, "./result.txt",  write_mode);

			 wait for 100 ns; 
			 
			 input1 <= x"68df6f7c";
          input2 <= x"73480728";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("7348072f"));writeline(output_buf,  wb); 
          
			 wait for 100 ns;  
			 
			 input1 <= x"5bf63576";
          input2 <= x"d861748e";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("5bf4728d"));writeline(output_buf,  wb); 
  
  
  			 input1 <= x"57767652";
          input2 <= x"54373c48";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("57795343"));writeline(output_buf,  wb); 
  
  
  			 input1 <= x"39ef5839";
          input2 <= x"b0b145f6";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("39ef580d"));writeline(output_buf,  wb); 
  
			 input1 <= x"3d7f7f15";
          input2 <= x"bd7f7f16";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("b1800000"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"67072953";
          input2 <= x"e7072953";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("00000000"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"42a652f7";
          input2 <= x"43843f0b";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("43add3c9"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"104c658a";
          input2 <= x"14454261";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("14460ec7"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"7cc47336";
          input2 <= x"78fe55fc";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("7cc5718c"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"1dfb4245";
          input2 <= x"12161cc9";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("1dfb4246"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"231236f2";
          input2 <= x"1f394ee0";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("2312f041"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"1ca06511";
          input2 <= x"28824c16";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("28824c17"));writeline(output_buf,  wb); 
 
 
   		 input1 <= x"46660f70";
          input2 <= x"4b3333f7";
			 wait for 100 ns; 
			 write( wb, input1);write( wb, input2);write( wb, output);write(wb, string'("4b336d7b"));writeline(output_buf,  wb); 
 
			 
			file_close(output_buf);
        wait;
		  end process;
   -- Clock process definitions
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
