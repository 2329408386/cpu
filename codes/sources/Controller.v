`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/27 17:07:26
// Design Name: 
// Module Name: Controller
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

// This is the controller module of a CPU, by giving the operand of a directive, we can get the controller signals.
module Controller(
input [5:0] operand,	
output reg [15:0] signals	
    );
	
	always @(operand) begin
		case(operand)
			
			/*R-Type-------------*/
			2'h0: signals=16'h6020;

			/*--------------R-Type*/
			
			/*I-Type-------------*/			
			//lw
			6'b100011:signals=16'hc832;
			
			//sw
			6'b101011:signals=16'h8804;
			
			//beq
			6'b000100:signals=16'h9c00;
			
			//bne
			6'b000101:signals=16'h9b00;
			
			//addi
			6'b001000:signals=16'he820;
			
			//andi
			6'b001100:signals=16'he821;
			
			//ori
			6'b001101:signals=16'he822;
			
			//xori
			6'b001110:signals=16'he823;
			
			//lui
			6'b001111:signals=16'h6800;		
			/*-------------I-Type*/
			
			/*J-Type-------------*/
			//j
			6'b000010:signals=16'h0040;
			
			//jal
			6'b000011:signals=16'h0080;		
			/*-------------J-Type*/
			
		endcase
	end
	
endmodule
