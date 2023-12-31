`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2023 02:20:57
// Design Name: 
// Module Name: spiControl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spiControl(
input clk,//100MHz
input reset,
input [7:0] data_in,
input load,//transmission indication signal

output reg done_send,//data sent
output spi_clk,//10 MHz max.
output reg spi_data
    );

reg [7:0] shiftReg; 
reg [2:0] count = 0;
reg [2:0] dcount;
reg [1:0] state;//since three states
reg clk_control;
reg CE;//clock enable

assign spi_clk = (CE ==1) ? clk_control : 1'b1;

localparam IDLE ='d0,
           SEND ='d1,
           DONE = 'd2;     

always @(posedge clk) begin
    if(count!=4)
        count <= count +1;
    else
        count <=0;
end 

initial 
    clk_control <= 1'b0;
    
always @(posedge clk) begin
    if(count == 4)
        clk_control <= ~clk_control;
end
//we need a state machine beause our current output depensds on previous value
//let's write a state machine in standard way

always @(negedge clk_control) begin
   if(reset) begin
        state<= IDLE;
        CE <=0;
        dcount <= 0;
        done_send <= 1'b0;
        spi_data <= 1'b1;
   end
   else begin
        case(state)
        IDLE: begin
              if(load) begin
                    shiftReg <= data_in;
                    state<=SEND;
                    dcount <=0;
              end
        end
        SEND: begin
              spi_data <= shiftReg[7];
              shiftReg <= {shiftReg[6:0],1'b0};
              CE <=1;
              if(dcount!=7) 
                    dcount <= dcount +1;
              else begin
                    state <= DONE;
              end        
        end
        DONE: begin
              done_send <= 1'b1;
              CE <=0;
              if(!load) begin
                    done_send <= 1'b0;
                    state <= IDLE;                  
              end                
        end
        endcase                 
   end                       
end            
endmodule
