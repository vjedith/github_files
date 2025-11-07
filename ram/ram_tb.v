// Code your testbench here
// or browse Examples

parameter int WIDTH = 8;
parameter int DEPTH = 16;
parameter int ADDR_WIDTH = $clog2(DEPTH);

class transaction;
  randc bit [WIDTH-1 : 0] din;
  randc bit [ADDR_WIDTH-1:0] addr;
  rand bit we;
  rand bit re;
  bit [WIDTH-1:0] dout;
  
  constraint data {
    we dist { 0 := 30 , 1 := 90 };
    re dist { 0 := 30 , 1 := 90 };
   
      }
  
   function void display();
     $display("D_in : %0d \t D_out: %0d \t write : %0d \t read : %0d",din,dout,we,re);  
  endfunction
  
  function transaction copy();
    copy = new();
    copy.din = this.din;
    copy.addr = this.addr;
    copy.we = this.we;
    copy.re = this.re;
    copy.dout = this.dout;
    return copy;
  endfunction
endclass

interface ram_if;
  logic  [WIDTH-1:0] din;
  logic [ADDR_WIDTH-1:0] addr;
  logic clk;
  logic rst;
  logic we;
  logic re;
  logic [WIDTH-1:0] dout;
endinterface

class generator;
  transaction trans;
  mailbox #(transaction) mbx;
  event done;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    trans = new();
  endfunction
  
  
  task run();
    for(int i = 0; i<10; i++) begin
      trans.randomize();
      mbx.put(trans.copy);
      $display("[GEN] : DATA SENT TO DRIVER");
      trans.display();
      #20;
    end
   -> done;
  endtask
endclass

class driver;
  
  virtual ram_if rif;
  mailbox #(transaction) mbx;
  transaction d;
  event next;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction 
  
  
  task run();
    forever begin
      mbx.get(d);
      @(posedge rif.clk);  
      rif.din <= d.din;
      rif.addr <= d.addr;
      rif.we <= d.we;
      rif.re <= d.re;
      $display("[DRV] : Interface Trigger");
      d.display();
    end
  endtask
  
  
endclass
module tb;
  
 ram_if rif();
 driver drv;
 generator gen;
 event done;
 
  
   mailbox #(transaction) mbx;
  
  RAM dut (.din(rif.din), .addr(rif.addr), .clk(rif.clk), .rst(rif.rst), .we(rif.we), .re(rif.re), .dout(rif.dout));
 
 
  initial begin
    rif.clk <= 0;
  end
  
  always #10 rif.clk <= ~rif.clk;
 
   initial begin
     mbx = new();
     drv = new(mbx);
     gen = new(mbx);
     drv.rif = rif;
     done = gen.done;
   end
  
  initial begin
  fork
    gen.run();
    drv.run();
  join_none
    wait(done.triggered);
    $finish();
  end
  
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;  
  end
  
endmodule