`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 08:38:59
// Design Name: 
// Module Name: delay2ms
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


module delay2ms(
     input clk,
     input delayEn,//control
     output reg delayDone//these are all handshaking(producer consumer)
     //these are all handshaking(producer consumer)
    );                 
    
reg [17:0] count;//2ms delay needed

always @(posedge clk) begin
    if(delayEn & count != 200000)
        count<=count +1;
    else
        count<=0;
end
always @(posedge clk) begin
    if(delayEn & count == 200000)
        delayDone <= 1'b1;
    else
        delayDone <= 1'b0;
end         
endmodule
