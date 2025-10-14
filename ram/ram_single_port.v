module ram(cs,
           we,
		   addr
		   data);
      
    parameter ADDR_WIDTH = 4,
              DATA_WIDTH = 8,
              DEPTH = 16;			  

    input we, cs;
    input [ADDR_WIDTH-1:0] addr;
    inout [DATA_WIDTH-1:0] data;

    reg [DATA_WIDTH-1:0] ram [0:DEPTH];

    always@(cs,we,addr,data)
      if (cs && we)
          ram[addr]=data;

    assign data = (cs && !we) ? ram[addr] : 8'hzz;
	
endmodule 