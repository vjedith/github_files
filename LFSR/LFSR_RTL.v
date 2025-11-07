/* Name           : Vishnu Jangir
   Enrollment No. : 2203031079002
   Topic          : Linear Feedback Shift Register(LFSR) */
   
`define LENGTH 4//LENGTH means no. of bits (can be changed)
`define DEFAULT {`LENGTH{1'b1}} //111......upto LENGTH
`define INVALID {`LENGTH{1'b0}} //000......upto LENGTH

             
//module:LFSR
module lfsr (clk,rst,seed,out);

//input signals
input    clk;
input	 rst;
input    [`LENGTH-1:0] seed;

//output signals
output [`LENGTH-1:0] out;

//varibles
reg [`LENGTH-1:0] lfsr_reg ;
reg               feedback;

//main logic :start
always@(posedge clk or negedge rst)
   begin
      if (!rst)
	   begin
	     if (seed != 0)
          lfsr_reg <= seed;
		   else
		      lfsr_reg <= `DEFAULT;
	   end		
      else
	      lfsr_reg <= {feedback,lfsr_reg[`LENGTH-1:1]}; 
   end  

 
always @(*)
    begin
      case (`LENGTH)
	     2: begin
          feedback = lfsr_reg[0] ^ lfsr_reg[1];
        end
        3: begin
          feedback = lfsr_reg[0] ^ lfsr_reg[2];
        end
        4: begin
          feedback = lfsr_reg[0] ^ lfsr_reg[3];
        end
        8: begin
          feedback = lfsr_reg[0] ^ lfsr_reg[2] ^ lfsr_reg[3] ^ lfsr_reg[4];
        end
        16: begin
          feedback = lfsr_reg[0] ^ lfsr_reg[2] ^ lfsr_reg[3] ^ lfsr_reg[5];
        end  
	endcase
end	
//main logic :end

//output
  case(`LENGTH)
    2,3,4,8,16:assign out = lfsr_reg;
    default:assign out = `INVALID;
  endcase  
   
endmodule