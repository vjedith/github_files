module RAM #(parameter WIDTH = 8,
             parameter DEPTH = 16,
             parameter ADDR_WIDTH = $clog2(DEPTH))
  (
    input logic [WIDTH-1:0] din,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic clk,rst,we,re,
    output logic [WIDTH-1:0] dout
  );
  
  logic [WIDTH-1:0] mem [0:DEPTH-1];
  
  always_ff @(posedge clk) begin
  if (rst) begin
    for(int i=0; i<DEPTH; i++)begin
      dout <= '0;
    end
  end 
    else begin
    if (we)
      mem[addr] <= din;
    if (re)
      dout <= mem[addr];
   end
end

endmodule