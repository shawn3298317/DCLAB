`timescale 1ns/1ps
module exp2_rsa (
    clk,
    reset,
    ready,
    we,
    oe,
    start,
    reg_sel,
    addr,
    data_i,
    data_o, 
    // signals below are inputs of LA (for observation)
    clk_o, 
    reset_o,
    ready_o,
    we_o,
    oe_o,
    start_o,
    reg_sel_o,
    addr_o,
    data_i_o
);

//==== parameter definition ===============================

    
//==== in/out declaration ==================================
    //-------- input ---------------------------
    input clk;
    input reset;
    input we;
    input oe;
    input start;
    input [1:0] reg_sel;
    input [4:0] addr;
    input [7:0] data_i;
    
    //-------- output --------------------------------------
    output ready;
    output [7:0] data_o;
    // signals below are inputs of LA (for observation)
    output clk_o;
    output reset_o;
    output ready_o;
    output we_o;
    output oe_o;
    output start_o;
    output [1:0] reg_sel_o;
    output [4:0] addr_o;
    output [7:0] data_i_o;

//==== parameter part ======================================
    integer i;
//==== reg/wire declaration ================================
    reg    [255:0] input_data [2:0];
    wire   [255:0] output_data;
    reg    [255:0] next_input_data [2:0];
    reg    [7:0]   data_o_r;
    reg    [7:0]   next_data_o_r;
    reg            ready_r;
    wire           next_ready;
    
//==== combinational part ==================================
    
    //output of LA
    assign clk_o      = clk;
    assign reset_o    = reset;
    assign we_o       = we;
    assign oe_o       = oe;
    assign start_o    = start;
    assign reg_sel_o  = reg_sel;
    assign addr_o     = addr;
    assign data_i_o   = data_i;

    assign output_data = 256'b0;
    assign next_ready  = 1'b1;
    //write data, we == 1
	
	
    always@(*) begin
        if(ready == 1 && we == 1) begin
            for( i = 0; i < 3; i = i + 1 )
                next_input_data[i] = input_data[i];
            case(reg_sel)
                2'd3: next_input_data[2][addr<<3 +: 8] = data_i;
                2'd2: next_input_data[1][addr<<3 +: 8] = data_i;
                2'd1: next_input_data[0][addr<<3 +: 8] = data_i;
            endcase
        end
        else begin
            for( i = 0; i < 3; i = i + 1 )
                next_input_data[i] = input_data[i];
        end
    end

	
	
	
    //output data, oe == 1
    always@(*) begin
        if(ready == 1 && oe == 1) begin
            next_data_o_r = output_data[addr<<3 +: 8];
        end
        else 
			next_data_o_r = data_o_r;
    end

    assign data_o = data_o_r;
    assign ready  = ready_r;

	
	
	
	
//==== sequential part ===================================== 
    
    always@(posedge clk or posedge reset) begin
        if(reset == 1) begin
            input_data[0] = 256'b0;
            input_data[1] = 256'b0;
            input_data[2] = 256'b0;
            ready_r       = 1'b1;
            data_o_r      = 7'b0;
        end
        else begin
            input_data[0] = next_input_data[0];
            input_data[1] = next_input_data[1];
            input_data[2] = next_input_data[2];
            ready_r       = next_ready;
            data_o_r      = next_data_o_r;
        end
    end
 
endmodule
