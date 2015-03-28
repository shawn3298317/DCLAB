//*************************************************************************************************//
// File: exp1_traffic.v                                                                            //
// Description: This is the verilog file for traffic light control logic                           //
//              phase count can be customized by signal                                            //
//*************************************************************************************************//



//*  
// @parameter clk   : 50MHz clock signal
// @parameter reset : reset signal
// @parameter change: change signal
//*
module traffic_ctr (
	clk,
	reset,
	change,
	HEX0,
	HEX1
	);
//==== input/output declaration======//
	//--- input ---//
	input clk;
	input reset;
	input change;

	//--- output ---//
	output [6:0] HEX0;
	output [6:0] HEX1;

//==== reg/wire declaration =========//
	//--- output ---//
	reg [6:0] HEX0;
	reg [6:0] HEX1;

	//--- wires ---//
	wire clk_16;
	wire [23:0] next_clks;
	reg  [4:0]  next_countdown;
	reg  [6:0]  next_HEX0;
	reg  [6:0]  next_HEX1;




//*******combinational part*********//
	



	



//*******sequential part************//

	
	
endmodule

