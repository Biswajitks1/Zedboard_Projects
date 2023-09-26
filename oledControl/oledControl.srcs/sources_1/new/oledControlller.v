`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 08:24:37
// Design Name: 
// Module Name: oledControlller
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


module oledControlller(
input clk,
input reset,
input [6:0] sendData,
input sendDataValid,

output oled_spi_clk,
output oled_spi_data,
output reg oled_vdd,
output reg oled_vbat,
output reg oled_resetn,
output reg oled_dcn,
output reg sendDone    
    );

reg startDelay;
wire delayDone;

delay2ms DG(
     .clk(clk),
     .delayEn(startDelay),
     .delayDone(delayDone)
    );

reg spiLoadData;
reg [7:0]spiData;     
wire spidone;
reg [7:0] pageCount;
     
spiControl SC(
.clk(clk),//100MHz
.reset(reset),
.data_in(spiData),
.load(spiLoadData),//transmission indication signal

.done_send(spidone),//data sent
.spi_clk(oled_spi_clk),//10 MHz max.
.spi_data(oled_spi_data)
    );    

wire [63:0] CBM;//character bit map
charROM CR(
    .addr(sendData),
    .data(CBM)
 );
reg [1:0] currPage;
//to initialze we will follow the flow and using state machine
localparam IDLE = 'd0,
           DELAY = 'd1,
            INIT ='d2,
            RESET ='d3,
            CP = 'd4,
            WAIT_SPI = 'd5,
            CP1 = 'd6,
            PRE_CRG = 'd7,
            PRE_CRG1 = 'd8,
            VBATon = 'd9,
            CTRST = 'd10,
            CTRST1 = 'd11,
            SEG_REMAP = 'd12,
            SCAN_DIR = 'd13,
            COM_PIN = 'd14,
            COM_PIN1 = 'd15,
            DSIP_ON = 'd16,
            CHECK = 'd17,
            DONE = 'd18,
            COL_ADDR ='d19,
            PAGE_ADDR ='d20,
            PAGE_ADDR1 ='d21,
            PAGE_ADDR2 ='d22,
            SEND_DATA = 'd23;
           
reg [4:0]state;
reg [4:0]nextState;
reg [3:0] bcount;

always @(posedge clk) begin
    if(reset) begin
        state <= IDLE;
        nextState <= IDLE;
        oled_vdd <= 1'b1;
        oled_vbat <= 1'b1;
        oled_resetn <= 1'b1;
        oled_dcn <= 1'b1;
        startDelay <= 1'b0;
        spiData <= 8'd0;
        spiLoadData <= 1'b0;
        currPage <= 0;
        sendDone<=0;
        pageCount<=0;
        
    end 
    else begin
        case(state)
            IDLE:begin
                oled_vdd <= 1'b0;
                oled_vbat <= 1'b1;
                oled_resetn <= 1'b1;
                oled_dcn <= 1'b0;
                state<=DELAY;
                nextState <= INIT;
            end
            DELAY:begin
                startDelay <= 1'b1;
                if(delayDone) begin
                    state <= nextState;
                    startDelay <= 1'b0;
                end    
            end
            INIT:begin
                spiData <= 'hAE;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    oled_resetn <= 1'b0;
                    state <= DELAY ;
                    nextState <= RESET; 
                end
            end
            RESET:begin
                 oled_resetn <= 1'b1;
                 state <= DELAY;
                 nextState <= CP;
            end
            CP: begin
                spiData <= 'h8D;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= CP1;
                end
            end
            WAIT_SPI:begin
                if(!spidone) begin
                    state<= nextState;
                end                   
            end
            CP1: begin
                spiData <= 'h14;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= PRE_CRG;
                end
            end
            PRE_CRG: begin
                spiData <= 'hD9;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= PRE_CRG1;
                end
            end
            PRE_CRG1: begin
                spiData <= 'hF1;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= VBATon;
                end
            end
            VBATon:begin
                oled_vbat <= 1'b0;
                state <= DELAY;
                nextState <= CTRST;
            end
            CTRST: begin
                spiData <= 'h81;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= CTRST1;
                end
            end
            CTRST1: begin
                spiData <= 'hFF;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= SEG_REMAP;
                end
            end
            SEG_REMAP: begin
                spiData <= 'hA0;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= SCAN_DIR;
                end
            end
            SCAN_DIR: begin
                spiData <= 'hC0;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= COM_PIN;
                end
            end 
            COM_PIN: begin
                spiData <= 'hDA;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= COM_PIN1;
                end
            end
            COM_PIN1: begin
                spiData <= 'h00;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= DSIP_ON;
                end
            end
            DSIP_ON: begin
                spiData <= 'hAF;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= PAGE_ADDR; //CHECK;
                end
            end
            PAGE_ADDR:begin
                spiData <= 'h22;
                spiLoadData <= 1'b1;
                oled_dcn <= 1'b0;
                if(spidone) begin
                    spiLoadData <=1'b0;
                    state <=WAIT_SPI;
                    nextState <= PAGE_ADDR1;
                end
            end
            PAGE_ADDR1: begin
                spiData <= currPage;
                spiLoadData <=1'b1;
                if(spidone) begin
                    spiLoadData <=1'b0;
                    state <=WAIT_SPI;
                    currPage <=currPage+1;
                    nextState <= PAGE_ADDR2;
                end
            end
            PAGE_ADDR2: begin
                spiData <= currPage;
                spiLoadData <=1'b1;
                if(spidone) begin
                    spiLoadData <=1'b0;
                    state <=WAIT_SPI;
                    nextState <= COL_ADDR;
                end
            end
            COL_ADDR: begin
                spiData <= 'h10;
                spiLoadData <=1'b1;
                if(spidone) begin
                    spiLoadData <=1'b0;
                    state <=WAIT_SPI;
                    nextState <= DONE;
                end
            end           
            /*CHECK: begin
                spiData <= 'hA5;
                spiLoadData <= 1'b1;
                if(spidone) begin
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI ;
                    nextState <= DONE;
                end
            end*/
            DONE:begin
                sendDone <= 1'b0;
                if(sendDataValid & pageCount !=128 & !sendDone) begin
                    state <= SEND_DATA;
                    bcount <=8;
                end
                else if(sendDataValid & pageCount ==128 & !sendDone) begin
                    state<= PAGE_ADDR;
                    bcount <=8;
                    pageCount<=0;
                end  
            end
            SEND_DATA:begin  
                spiData <= CBM[(bcount*8 -1)-:8];
                spiLoadData <= 1'b1;
                oled_dcn <=1'b1;
                if(spidone) begin
                    pageCount <= pageCount +1;
                    spiLoadData <= 1'b0;
                    state <= WAIT_SPI;
                    if(bcount !=1) begin
                        bcount <= bcount -1;
                        nextState <= SEND_DATA;
                    end
                    else begin
                        nextState <= DONE;
                        sendDone <= 1'b1;
                    end        
                end       
            end                                   
         endcase          
    end       
end     
endmodule
