`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/19 16:33:37
// Design Name: 
// Module Name: Displayor
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

// Input a 32-bit number and output it on the display screen.
module Displayor(
input [31:0] data,		// The data
input clk,		//clk signal.
input reset,		//reset signal.
output reg[7:0] whichLight,		//Decide which position's led to light.
output reg[6:0] whichPipe,		//Decide one position's which pipe to light.
output wire dp			//		dp signal.
    );
	
		wire [2:0] s;		//led's position.
        
        reg [3:0] digit=0;		//every digit.
        
        reg [19:0] clkdiv=0;		//clk circuit.
        
        assign dp=1;
        assign s=clkdiv[19:17];   	

     
		// Give every data's 4 bits to a digit.
        always @(*)
        case(s)
          0:digit=data[31:28];
          1:digit=data[27:24];
          2:digit=data[23:20];
          3:digit=data[19:16];
          4:digit=data[15:12];
          5:digit=data[11:8];
          6:digit=data[7:4];
          7:digit=data[3:0];
          default:digit=data[3:0];
          endcase 
    
		// Control which led to light.
        always @(*)
        case(s)
          0:whichLight=8'b11111110;
          1:whichLight=8'b11111101;
          2:whichLight=8'b11111011;
          3:whichLight=8'b11110111;
          4:whichLight=8'b11101111;
          5:whichLight=8'b11011111;
          6:whichLight=8'b10111111;
          7:whichLight=8'b01111111;
          default:whichLight=8'b11111110;
          endcase       
    
		// Control which pipe to light.
        always @(*)
                 case(digit)
                      0:whichPipe=7'b0000001;
                      1:whichPipe=7'b1001111;
                      2:whichPipe=7'b0010010;
                      3:whichPipe=7'b0000110;
                      4:whichPipe=7'b1001100;
                      5:whichPipe=7'b0100100;
                      6:whichPipe=7'b0100000;
                      7:whichPipe=7'b0001111;
                      8:whichPipe=7'b0000000;
                      9:whichPipe=7'b0000100;
                      'hA:whichPipe=7'b0001000;
                      'hB:whichPipe=7'b1100000;
                      'hC:whichPipe=7'b0110001;
                      'hD:whichPipe=7'b1000010;
                      'hE:whichPipe=7'b0110000;
                      'hF:whichPipe=7'b0111000;
                     default:whichPipe=7'b0000001;
                 endcase
         
		// Control clock signal.
        always @(posedge clk)
           begin
             /*if(reset==0)
                clkdiv<=0;
             else*/
                clkdiv=clkdiv+1;
          end
endmodule
