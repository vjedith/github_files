`timescale 1ns/1ps

module uarttop #(parameter clk_frequency = 10000000,
            parameter baud_rate = 9600)
  (input clk,rst, //global signals
   input rx,
   input [7:0] tx_in,
   input new_data,   
   output tx,
   output [7:0] rx_out,
   output tx_done,
   output rx_done
  );
  
  uarttx #(clk_frequency,baud_rate) utx
  (.clk(clk), .rst(rst),.new_data(new_data),.tx_data(tx_in),.tx(tx),.tx_done(tx_done));
  
  uartrx #(clk_frequency,baud_rate) urx
  (.clk(clk),.rst(rst),.rx_data(rx_out),.rx(rx),.rx_done(rx_done));
endmodule


////////////////////reciver//////////////////////

module uartrx #(parameter clk_frequency = 10000000,
               parameter baud_rate = 9600)
  (
    input clk,rst,
    input rx,
    output reg rx_done,
    output reg [7:0] rx_data
  );
  
  localparam clk_count = (clk_frequency/baud_rate);
  
  integer count = 0;
  integer counts = 0;
  
  reg u_clk = 0;
  
  enum bit[1:0] {idle = 2'b00, start = 2'b01} state;
  
  always@(posedge clk)
    begin
      if(count <= clk_count/2)
        count <= count+1;
      else
         begin
           count <= 0;
           u_clk <= ~u_clk;
         end
    end
  
  always@(posedge u_clk)
    begin
      if(rst)
        state <= idle;
      else
        begin
          case(state)
            idle:
              begin
                rx_data <= 8'b0000_0000;
                counts <= 0;
                rx_done <= 1'b0;
                
                if(rx == 1'b0)
                  state <= start;
                else
                  state <= idle;
              end
            
            start:
              begin
                if(counts <= 7)
                  begin
                    counts <= counts+1;
                    rx_data <= {rx,rx_data[7:1]};
                  end
                else
                  begin
                    counts <= 0;
                    state <= idle;
                    rx_done <= 1'b1;
                  end
              end
            
            default:state <= idle;
            
          endcase
        end
    end
endmodule


////////////////////////transmitter////////////////////////
module uarttx #(
  parameter clk_frequency = 1000000,
  parameter baud_rate = 9600
  )
  
  (
    input new_data,
    input clk,rst,
    input [7:0] tx_data,
    output reg tx,
    output reg tx_done
  );
  
  
  localparam clk_count = (clk_frequency/baud_rate);
  
  integer count = 0; //for local_clk
  integer counts = 0; //for data
  
  reg u_clk = 0;
  
  enum bit[1:0] {idle = 2'b00, start = 2'b01, transfer = 2'b10, done = 2'b11} state;
  
  /////////////////local_clock//////////////////
  
  always@(posedge clk)
    begin
      if(count < clk_count/2)
        count <= count+1;
      else
        count = 0;
        u_clk = ~u_clk;
    end
  ////////////////////////////////////////////////
  
  reg [7:0] Din;
  
  always@(posedge u_clk)
    begin
      if(rst)
        state <= idle;
      else
        begin
        case(state)
        idle:
          begin
            count <= 0;
            tx <= 1'b1;
            tx_done <= 1'b0;
            
            if(new_data)
              begin
                state <= transfer;
                Din <= tx_data;
                tx <= 1'b0; 
              end
            else
              state <= idle;
          end
        
        transfer:
          begin
            if(count <= 7)
              begin
                counts <= counts+1;
                tx <= Din[counts];
                state <= transfer;
              end
            else
              begin
                count <= 0;
                tx <= 1'b1;
                state <= idle;
                tx_done <= 1'b1;
              end
          end
        
        default:state <= idle;
          
      endcase
     end
    end
  
endmodule
