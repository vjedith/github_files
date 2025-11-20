
module fifo #(parameter Width = 8,
              parameter Depth = 16,
              localparam Addr_width = $clog2(Depth)
             )(input logic clk,rst,rd,wr,
               input logic [Width-1:0] din,
               output logic [Width-1:0] dout,
               output logic full, empty);
  
  logic [Addr_width-1:0] rptr,wptr;
  logic [Addr_width:0] count;
  logic [Width-1:0] mem [Depth-1:0];
  
  always_ff @(posedge clk)begin
    
    if(rst)begin
      dout <= '0;
      rptr <= '0;
      wptr <= '0;
      count <= '0;
    end
    
    else begin
      
      if(wr && !full)begin
        mem[wptr] <= din;
        wptr <= wptr+1;
      end
      
      if(rd && !empty)begin
        dout <= mem[rptr];
        rptr <= (rptr+1) % Depth;
      end
      
      case({wr && !full,rd && !empty})
        2'b10: count <= count+1;//write opn
        2'b01: count <= count-1;//read opn
        default: count <= count;
      endcase
    end
  end
  
  assign full = (count == Depth);
  assign empty = (count == 0);
 
endmodule

interface fifo_if;
  
  logic clk, rd, wr;           // Clock, read, and write signals
  logic full, empty;           // Flags indicating FIFO status
  logic [7:0] din;             // Data input
  logic [7:0] dout;            // Data output
  logic rst;                   // Reset signal
 
endinterface
