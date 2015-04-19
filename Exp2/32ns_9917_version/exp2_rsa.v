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
    reg    [255:0] input_data_0;
    reg    [255:0] input_data_1;
    reg    [255:0] input_data_2;
    wire   [255:0] output_data;
    reg    [255:0] next_input_data_0;
    reg    [255:0] next_input_data_1;
    reg    [255:0] next_input_data_2;
    //reg    [7:0]   data_o_r;
    //reg    [7:0]   next_data_o_r;
    //reg            ready_r;
    //wire           next_ready;
    wire    [7:0]   addr_idx;

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
	assign ready_o    = ready;

    //assign output_data = 256'b0;
    //assign next_ready  = 1'b1;
    //write data, we == 1   
	assign addr_idx   = addr<<2'd3;

    always@(*) begin
        if(we == 1) begin      
			next_input_data_0 = input_data_0;
            next_input_data_1 = input_data_1;
            next_input_data_2 = input_data_2;
            case(reg_sel)
                2'd3: next_input_data_2[addr_idx  +: 8] = data_i;
                2'd2: next_input_data_1[addr_idx  +: 8] = data_i;
                2'd1: next_input_data_0[addr_idx  +: 8] = data_i;
                default: begin
                    next_input_data_0 = input_data_0;
                    next_input_data_1 = input_data_1;
                    next_input_data_2 = input_data_2;
                end
            endcase
        end
        else begin
            next_input_data_0 = input_data_0;
            next_input_data_1 = input_data_1;
            next_input_data_2 = input_data_2;
        end
    end
	
	LSB_ME lsb_me(.reset(reset),.clk(clk),.M_i(input_data_0),.N_i(input_data_2),.d_i(input_data_1),.start(start),.ready(ready),.S_out(output_data));

	
	
	
    //output data, oe == 1
    /*always@(*) begin
        if( oe == 1 ) begin
            next_data_o_r = output_data[addr_idx +: 8];
        end
        else 
            next_data_o_r = data_o_r;
    end*/
    assign data_o = (oe == 1)? (output_data[addr_idx +: 8]):8'd0;
    //assign data_o = data_o_r;
    //assign ready  = ready_r;

	
	
	
	
//==== sequential part ===================================== 
    
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            input_data_0 <= 256'b0;
            input_data_1 <= 256'b0;
            input_data_2 <= 256'b0;
            //data_o_r     <= 7'b0;
        end
        else begin
            input_data_0 <= next_input_data_0;
            input_data_1 <= next_input_data_1;
            input_data_2 <= next_input_data_2;
            //data_o_r     <= next_data_o_r;
        end
    end
 
endmodule
