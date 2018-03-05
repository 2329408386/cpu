`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: happyboy
// 
// Create Date: 2017/12/27 15:38:34
// Design Name: 
// Module Name: ALU_sim
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


module CPU(
input clk,	// simulate the clock signal.
input debug,	// simulate the debug style.
input reset,	// reset signal.
input isClk,	// Judge if it's clock signal.
input [4:0] displayAddress,		// The place to display data.
input [1:0] displayController,	// Decide to display registers or datas. 1 is registers and 0 is datas.

output [15:0] leds,
output [7:0] whichLight,		//Decide which position's led to light.
output [6:0] whichPipe,		//Decide one position's which pipe to light.
output dp
    );
		
	
	
	reg mode=0;		// Decide which mode to use.
	
	
	reg [4:0] pc=0;		// current PC
	
	reg [31:0] directives[0:30];		// Store all directives which need to test
	reg [31:0] directive;		// Store the current directive which is executing.
	
	reg [31:0] registers[0:31];		// register heap;
	reg [31:0] datas[0:31];			// data heap;

	//	Useful common data come from register.
	reg [31:0] readRs=0;
	reg [31:0] readRt=0;
	reg [31:0] readRd=0;

	// R-Type
	reg [4:0] readRdAddress=0;	
	reg [4:0] shiftNumber=0;

	// I-Type
	reg [15:0] I_immediate=0;	
	reg [4:0] readRtAddress=0;

	reg [25:0] J_immediate=0;	// J-Type

	reg [5:0] operand=0;		// The operand part of a directive
	reg [5:0] funct=0;			// The function part of a directive

	//   Data and address need to put into data ram.
	wire [4:0] writeBackAddress;
	wire [31:0] result;

	wire isZero;		// Judge if the result is zero.
	wire isBranch;		// Judge if it's a branch.
	wire isJAL;		// Judge if it's jal command.
	
	wire [1:0] loadWrite;		//Judge if it's lw or sw command. 10 is lw, 01 is sw.
	wire [4:0] loadWriteAddress;
	
	integer i=0;
	
	
	/*Add display module.*/
	
	
	reg [31:0] displayData=0;	// The data need to display.
	
		
	
	/*Add controller module.*/
	
	reg isOver=0;		//Used to judge if current procedure is over.
	integer counter=0;		// Used to record how many directives have been excecuted.
	
	wire [1:0] inOut; 	//Judge if it's in or out command. 10 is in, 01 is out.
	wire [4:0] inOutAddress;		// The address used to in or out.
	
	ALU alu0(pc,readRs,readRt,readRd,readRdAddress,shiftNumber,I_immediate,readRtAddress,J_immediate,operand,funct,writeBackAddress,result,isZero,isBranch,isJAL,loadWrite,loadWriteAddress,inOut,inOutAddress);
	Displayor displayor0(displayData,clk,reset,whichLight,whichPipe,dp);
	Controller controller0(operand,leds);
	
	// Initialize all test directives and test registers.
	initial begin
		// Nomal I-Type
		directives[0]=32'h00000000;
		directives[1]=32'h22100003;
		directives[2]=32'h3610000a;
		directives[3]=32'h32100009;
		directives[4]=32'h3a100005;
		
		// lui
		directives[5]=32'h3c120003;
		
		// Nomal R-Type
		directives[6]=32'h02108820;
		directives[7]=32'h02308822;
		directives[8]=32'h00129402;
		directives[9]=32'h00129040;
		directives[10]=32'h00129083;		
		directives[11]=32'h02128025;
		directives[12]=32'h02329024;
		directives[13]=32'h0251802a;
		
		// bne
		directives[14]=32'h16120001;
		directives[15]=32'h00000000;
		
		// beq
		directives[16]=32'h22520001;
		directives[17]=32'h12120001;
		directives[18]=32'h00000000;
		
		// j
		directives[19]=32'h22520001;
		directives[20]=32'h08100015;
		directives[21]=32'h00000000;
		
		// jal
		directives[22]=32'h22520001;
		directives[23]=32'h0c100018;
		directives[24]=32'h00000000;
		
		// lw, sw
		directives[25]=32'b100011_00001_00000_0000_0000_0001_0000;	// registers[0]=16;
		directives[26]=32'b101011_00010_00000_0000_0000_0000_0000;	// datas[2]=16;
		
		// in,out
		directives[27]=32'b100000_00000_00000_0000_0000_0001_1111;
		directives[28]=32'b100001_00000_00000_0000_0000_0000_0011;
		
		directives[29]=32'h02200008;
		directives[30]=32'h00000000;
		for(i=0;i<32;i=i+1) begin
			registers[i]=0;
			datas[i]=i;
		end	
	end
	
	
	
	always @(isClk or debug or clk or reset) begin
		mode=(isClk==0)?debug:clk;
	end

	always @(displayController or reset) begin
		case (displayController) 
				2'b00:displayData=datas[displayAddress];
				2'b01:displayData=registers[displayAddress];
				2'b10:displayData=directives[displayAddress];
				2'b11:displayData=pc;

		endcase
		// out
		if(inOut==2'b01)
			displayData=datas[inOutAddress];
		// When it's over.
		if(isOver==1'b1 && isClk==1'b0)
			displayData=32'hffffffff;
		if(reset==0)
			displayData=32'h80808080;
	end
	
	
	// Test every directive
	always @(posedge mode) begin
		// for(pc=0;pc<25;pc=pc+1) begin
			
			if(pc<31 && counter<31 && isOver==0) begin
				directive=directives[pc];
			
				operand=directive[31:26];
				readRs=registers[directive[25:21]];
				readRt=registers[directive[20:16]];
				readRd=registers[directive[15:11]];
				shiftNumber=directive[10:6];
				funct=directive[5:0];
				
				readRdAddress=directive[15:11];
				readRtAddress=directive[20:16];
				I_immediate=directive[15:0];
				J_immediate=directive[25:0];
				
				
			
			end
			
			
		// end
	end
	
	always @(negedge mode) begin
            
	
		if(pc<31 && counter<31 && isOver==0) begin			
			// lw
			if(loadWrite==2'b10) begin
				registers[writeBackAddress]=datas[loadWriteAddress];
			end
			
			// sw
			else if(loadWrite==2'b01) begin
				datas[loadWriteAddress]=registers[writeBackAddress];
			end
			
			// in
			else if(inOut==2'b10) begin
				datas[inOutAddress]=displayData;
			end
				
			//out
			else if(inOut==2'b01) begin
				;
			end
			
			// other commands
			else begin
				if(isBranch==0)
					registers[writeBackAddress]=result;
				if(isJAL==1)
					registers[31]=writeBackAddress;
			end
			
			if(isBranch==0)
				pc=pc+1;
			else
				pc=writeBackAddress;
				
			counter=counter+1;
		end
		
		
		else
			isOver=1;

		
		if (reset==0) begin
            pc=0;
			isOver=0;
			counter=0;
			for(i=0;i<32;i=i+1) begin
                registers[i]=0;
                datas[i]=i;
            end;
        end
	end
	
endmodule
