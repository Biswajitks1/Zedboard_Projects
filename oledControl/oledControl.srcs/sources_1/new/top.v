`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.09.2023 16:01:47
// Design Name: 
// Module Name: top
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


module top(
input clock,
input reset,

output oled_spi_clk,
output oled_spi_data,
output  oled_vdd,
output  oled_vbat,
output  oled_resetn,
output  oled_dcn    
    );


//lrt's declare string to display
localparam text = "Hello World";//it is 8 bit data but our oled is 7bit ascii
localparam stringlen = 11; 


localparam IDLE = 'd0,
           SEND = 'd1,
           DONE = 'd2; 

reg [1:0] state;
reg [7:0] sendData;
wire sendDone;
reg sendDataValid;
integer bcount;//uses 32 bit but vivado decides the bits itself based on max. number
//now we will send one character at a time

always @(posedge clock) begin
    if(reset) begin
        state <=IDLE;
        bcount <= stringlen;
        sendDataValid = 1'b0;
    end
    else begin
       case(state)
           IDLE:begin
                if(!sendDone)begin
                    sendData <= text[(bcount*8-1)-:8];
                    sendDataValid = 1'b1;
                    state <= SEND;
                end                
           end
           SEND:begin
                if(sendDone) begin
                    sendDataValid <=1'b0;
                    bcount <= bcount-1;
                    if(bcount !=1)
                         state <= IDLE;
                    else
                         state <=DONE;                         
                end    
           end
           DONE:begin
               state<=DONE; 
           end 
       endcase
    end        
end    
oledControlller(
    .clk(clock),
    .reset(reset),
    
    .sendData(sendData),//lower 7 bits will be connected
    .sendDataValid(sendDataValid),
    
    .oled_spi_clk(oled_spi_clk),
    .oled_spi_data(oled_spi_data),
    .oled_vdd(oled_vdd),
    .oled_vbat(oled_vbat),
    .oled_resetn(oled_resetn),
    .oled_dcn(oled_dcn),
   
    .sendDone(sendDone)
        
    );    
endmodule
