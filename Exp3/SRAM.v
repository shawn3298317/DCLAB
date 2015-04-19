`timescale 1ns/1ps
module SRAM(
	//Host side
	clk,
	reset,
	WriteRAM,
	ReadRAM,   //= Play (by Tommy's module)
	addr,
	DataWrite,   //data to be written in
	DataRead ,   //data to be read out
	//SRAM side
	SRAM_ADDR,
	SRAM_DQ,
	SRAM_OE,
	SRAM_WE,
	SRAM_CE,
	SRAM_LB,
	SRAM_UB
);
	input             clk, reset, WriteRAM, ReadRAM;
	input      [19:0] addr;
	input  reg [15:0] DataWrite;
	output reg [15:0] DataRead ;

	output [19:0] SRAM_ADDR;
	output        SRAM_OE, SRAM_WE, SRAM_CE, SRAM_LB, SRAM_UB;
	inout  [15:0] SRAM_DQ;

	/*
	wire [1:0] STATE;
	parameter READ_CYCLE  = 2'b10; //read  == 1
	parameter WRITE_CYCLE = 2'b01; //write == 1
	assign STATE   = {ReadRAM, WriteRAM};
	*/

	assign SRAM_CE = 0; //SRAM is always ready
	assign SRAM_UB = 0; //upper byte is always available
	assign SRAM_LB = 0; //lower byte is always available
	assign SRAM_OE = ~ReadRAM; 
	assign SRAM_WE = ~WriteRAM;
	assign SRAM_ADDR = addr;

	assign SRAM_DQ = WriteRAM? DataWrite: 16'bz; 

	always@(posedge clk or posedge reset) begin	
		if(reset) begin
			DataRead <= 16'b0;
		end
		else begin
			if (ReadRAM == 1)
				DataRead <= SRAM_DQ; 
			else 
				DataRead <= 16'b0; 
		end
	end
endmodule
