`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: happyboy
// 
// Create Date: 2017/12/27 10:48:36
// Design Name: 
// Module Name: ALU
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

// The ALU module, used to do some calculation by given operand, function and some necessary data.
module ALU(
// current PC
input [4:0] pc,

//	Useful common data come from register.
input [31:0] readRs,
input [31:0] readRt,
input [31:0] readRd,

// R-Type
input [4:0] readRdAddress,	
input [4:0] shiftNumber,

// I-Type
input [15:0] I_immediate,	
input [4:0] readRtAddress,

input [25:0] J_immediate,	// J-Type

input [5:0] operand,		// The operand part of a directive
input [5:0] funct,			// The function part of a directive

//   Data and address need to put into data ram.
output reg [4:0] writeBackAddress,
output reg [31:0] result,

output reg isZero,		// Judge if the result is zero.
output reg isBranch,		// Judge if it's a branch.
output reg isJAL,		// Judge if it's jal command.

output reg [1:0] loadWrite,		//Judge if it's lw or sw command. 10 is lw, 01 is sw.
output reg [4:0] loadWriteAddress,		// The address used to lw or sw.


output reg [1:0] inOut, 	//Judge if it's in or out command. 10 is in, 01 is out.
output reg [4:0] inOutAddress		// The address used to in or out.

    );
	
	// Basic initialization.
	initial @(operand or funct) begin
		writeBackAddress=0;
		result=1;
		isZero=0;
		isBranch=0;
	end
	
	// Update the isZero flag along with result.
	always @(result) begin
		isZero=(result==0)?1:0;
	end
	
	always @(operand or funct) begin
		writeBackAddress=readRdAddress;
		isBranch=0;
		isJAL=0;
		loadWrite=2'b00;
		inOut=2'b00;
		
		// Judge if it's nop command.
		if(operand!=6'b0 || J_immediate!=26'b0) begin
			case(operand)
			
			/*R-Type-------------*/
			6'b0:begin
				
				case(funct)
				
					//nop, which means do nothing.
					/*6'b0:begin
						result=readRd;
					end*/
					
					//add
					6'b100000:begin
						result=readRs+readRt;
					end
					
					//sub
					6'b100010:begin
						result=readRs-readRt;
					end
					
					//and
					6'b100100:begin
						result=readRs&readRt;
					end
					
					//or
					6'b100101:begin
						result=readRs|readRt;
					end
					
					//slt
					6'b101010:begin
						if(readRs<readRt)
							result=1;
						else
							result=0;
					end
					
					//jr
					6'b001000:begin
						isBranch=1;
						writeBackAddress=readRs[4:0];
					end
					
					//sll
					6'b0:begin
						result=readRt<<shiftNumber;
					end
					
					//srl
					6'b000010:begin
						result=readRt>>shiftNumber;
					end
						
					//sra
					6'b000011:begin
						result=readRt>>>shiftNumber;
					end
					
				endcase
			end
			/*--------------R-Type*/
			
			/*I-Type-------------*/			
			//lw
			6'b100011:begin
				loadWrite=2'b10;
				loadWriteAddress=(readRs+I_immediate)%32;
			end
			
			//sw
			6'b101011:begin
				loadWrite=2'b01;
				loadWriteAddress=(readRs+I_immediate)%32;
			end
			
			//beq
			6'b000100:begin
				if (readRs==readRt) begin
					isBranch=1;
					writeBackAddress=I_immediate[4:0]+pc+1;
				end
			end
			
			//bne
			6'b000101:begin
				if(readRs!=readRt) begin
					isBranch=1;
					writeBackAddress=I_immediate[4:0]+pc+1;
				end
			end
			
			//addi
			6'b001000:begin				
				writeBackAddress=readRtAddress;
				result=readRs+I_immediate;
				// $display("addi: result=%b",result);
			end
			
			//andi
			6'b001100:begin
				writeBackAddress=readRtAddress;
				result=readRs&I_immediate;
				// $display("andi: result=%b",result);
			end
			
			//ori
			6'b001101:begin
				writeBackAddress=readRtAddress;
				result=readRs|I_immediate;
				// $display("andi: result=%b",result);
			end
			
			//xori
			6'b001110:begin
				writeBackAddress=readRtAddress;
				result=readRs^I_immediate;
			end
			
			//lui
			6'b001111:begin
				writeBackAddress=readRtAddress;
				result=I_immediate<<16;
			end			
			/*-------------I-Type*/
			
			/*J-Type-------------*/
			//j
			6'b000010:begin
				isBranch=1;
				writeBackAddress=J_immediate[4:0]+1;
			end
			
			//jal
			6'b000011:begin
				isBranch=1;
				writeBackAddress=J_immediate[4:0]+1;
				isJAL=1;
			end			
			/*-------------J-Type*/
			
			/*Self-Type-------------*/
			//in: put current display data into data[31].
			6'b100000:begin
				inOut=2'b10;
				inOutAddress=J_immediate[4:0];
			end
			
			//out: put data[31] into current display.
			6'b100001:begin
				inOut=2'b01;
				inOutAddress=J_immediate[4:0];
			end			
			/*-------------Self-Type*/
			
		endcase
		end
		
		// If it's nop command, then it's result is its readRd.
		else begin
			result=readRd;
		end
	end
		
		

endmodule
