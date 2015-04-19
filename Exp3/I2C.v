`timescale 1ns/1ps
module I2C_Interface (
	//Top module I/O port
	CLK,
	DATA,
	RESET,
	ACTIVATE,
	END,
	ACK,
	//Codec port
	I2C_SDAT,
	I2C_SCLK,
	//Debug port
	SDO,
	SD_cnt
);

//=======================================================
//  PORT declarations
//=======================================================
			
	input 			 CLK;
	input 	[23:0]   DATA;	
	input  			 RESET;	
	input            ACTIVATE;	

	//I2C_interface <=> Codec 
 	inout  			 I2C_SDAT;
	output 			 I2C_SCLK;

	//I2C_interface <=> I2C_test
	output	reg		 END;	
	output 	reg		 ACK;

	//debug port
	output reg		 SDO;
	output reg [5:0] SD_cnt;


	reg 			 next_END,next_SDO;
	reg 	[29:0]	 DATA_REG;
	reg 	[5:0]	 next_SD_cnt;
	reg              state,next_state;

	reg     [2:0]    ACK_R;

assign I2C_SCLK = (state ==  1'b1)? ~CLK : 1'b1;
assign I2C_SDAT = SDO;



//=============================================================================
// Combinational Part
//=============================================================================


//FSM
always@(*) begin
	if(SD_cnt >= 6'd28 || SD_cnt == 6'b0)
		next_state = 1'b0;
	else
		next_state = 1'b1;
end


//input to register buffer
always@(*) begin
	DATA_REG    = (ACTIVATE == 1'b1) ? {1'b0,DATA[23:16],1'bz,DATA[15:8],1'bz,DATA[7:0],1'bz,2'b01} : 30'b0;
end


//counter logic
always@(*) begin
	next_SD_cnt = ((ACTIVATE == 1'b1) && (SD_cnt<6'd29)) ? SD_cnt + 1'b1 : SD_cnt;
end

//SDO output logic
always@(*) begin
	
	if(ACTIVATE == 1'b1) begin

		next_SDO = DATA_REG[6'd29 - SD_cnt];
		next_END = (next_SD_cnt == 6'd29)?1'b1:1'b0;	

	end
	else begin
		next_SDO = 1'b1;
		next_END = END;
	end

end


//=============================================================================
// Sequential Part
//=============================================================================
always@(posedge CLK or RESET) begin
	
	if(RESET == 1'b1) begin
		SD_cnt  <= 6'b0;
		state   <= 1'b0;
		ACK     <= 1'b0;
		END     <= 1'b0;
		SDO     <= 1'b1;
	end
	else begin
		SDO     <= next_SDO;
		ACK     <= I2C_SDAT;
		state   <= next_state;
		SD_cnt  <= next_SD_cnt;
		END     <= next_END;
	end
end

endmodule