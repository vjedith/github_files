/* Name           : Vishnu Jangir
   Enrollment No. : 2203031079002
   Topic          : Linear Feedback Shift Register(LFSR) */
   
`timescale 1ns/1ps

//testbench for LFSR
module tb;

//signals
  reg  clk, rst;
  reg  [`LENGTH-1:0] seed;
  wire [`LENGTH-1:0] out;


//intentaion
  lfsr DUT(.clk(clk),
           .rst(rst),
		       .seed(seed),
		       .out(out)
		      );

//reset button
task reset();
	 begin
	    rst= 0;
	    #0.5
	    rst= 1;
	end
endtask

//length check 
integer count=1;
integer prev_length;
integer temp;  
reg     length_check;

always@(out)
begin

  begin
	 if (out == seed)
      begin       
        temp=count;
    	  count = 1;
      end  
    else
      begin
		   if( seed==`INVALID && out==`DEFAULT)
        begin
          temp=count;
		      count=1;
        end
		   else
        count=count+1;
      end
  end

  begin
    if(count==1)
      length_check=0;
     else
      length_check=1;
  end

end

always@(negedge length_check)
begin
  prev_length = temp;
end


//zero check
reg zero_check;

always@(out)
 begin
  if(out==`INVALID)
   zero_check=1;
  else
   zero_check=0;
 end


//repeat check
  reg [`LENGTH-1:0] prev_out;
  reg repeat_check ;

  always @(posedge clk or negedge rst) begin
    prev_out <= out; // Update prev_out synchronously with the clock edge
  end

  always@(out,prev_out)
  begin
    if(out==prev_out)
     repeat_check=1;
    else
     repeat_check=0;
  end


/*simulation

NOTE : THIS SIMULATION BLOCK IS MADE FOR A   
4-BIT LINEAR FEEDBACK SHIFT REGISTER   
SO WHEN YOU CHANGE BIT CHANGE SIMULATION
TIMINGS ACCORGING TO THAT  */
  initial begin 
    $monitor("OUTPUT=%d",out);  
    seed = $random;
    clk = 0;             
    reset();             
    #10                  
	  reset();             
    #80                  
    reset();             
    #10
    seed = `INVALID;
    #7
    reset();
    #9
    seed = 6;
    #80
	  $finish;
  end


//clk genration
  always #2 clk=~clk;
  
  
//result
  //valid length
  always@(negedge length_check,prev_length)
    begin
        if(prev_length==(2**`LENGTH-1))
          $display("process end : SUCCESS \nLENGTH ACQUIRED:%0d",prev_length); 
       else
          $display("process end : FAILURE \nLENGTH  ACQUIRED:%0d",prev_length);   
    end
  //invalid length or in case of any errors
  always@(repeat_check==1,zero_check==1) 
    begin
      $display("ERROR in process");      
    end
  
//dump file
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end

endmodule