`timescale 1ns/1ps
module LSB_ME (
	reset,
	clk,
	M_i,
	N_i,
	d_i,
	start,
	
	ready,
	S_out
);

	input 		  	   clk, 
					   reset,
					   start;
	input [255:0] 	   M_i,
					   N_i,
					   d_i;
					   
	output reg   	   ready;
	output reg [255:0] S_out;
	
	
	reg   [255:0]      next_S_out;
	wire  [2:0]   	   finish_flag;
	wire  [255:0] 	   T_o1,
					   S_o,
					   T_o2;
	reg   [255:0]      S,
					   T;
	reg   [255:0] 	   next_T,
					   next_S;
	reg   [8:0]   	   i,
					   next_i;
	reg   [3:0]        LSB_ST,
                       next_LSB_ST;



	parameter LSB_ST_0   = 4'b0010;
	parameter LSB_ST_1   = 4'b0000;
	parameter LSB_ST_2   = 4'b0001;
	parameter LSB_ST_3   = 4'b0100;
	parameter LSB_ST_4   = 4'b1000;
	
	//****module initialization*****//
	PreProcess_CLK  PP   (.clk(clk),.PP_start(LSB_ST[1]),.reset(reset),.N_i(N_i),.M_i(M_i),.T_o(T_o1),        .finish(finish_flag[1]));
	MA_CLK_mod4          MA_S (.clk(clk),.MA_start(LSB_ST[0]),.reset(reset),.N_i(N_i),.A_i(S)  ,.B_i(T),.V_o(S_o ),.finish(finish_flag[2]));
	MA_CLK_mod4          MA_T (.clk(clk),.MA_start(LSB_ST[0]),.reset(reset),.N_i(N_i),.A_i(T)  ,.B_i(T),.V_o(T_o2),.finish(finish_flag[0]));
	
	always@(*) begin   // FSM for LSB
		case(LSB_ST)
			LSB_ST_0: begin
					next_LSB_ST = LSB_ST_1; //PP start, go to ST_1
			end
			LSB_ST_1: begin // Calculating PP, wait for finish_flag[1]
				if( finish_flag[1] == 1'b1 ) begin
					next_LSB_ST = LSB_ST_2;
				end
				else
					next_LSB_ST = LSB_ST_1;
			end
			LSB_ST_2: next_LSB_ST = LSB_ST_3;// MA start, go to ST_3
			LSB_ST_3: begin // Calculating MA, wait for finish_flag[0]
				if( finish_flag[0] == 1'b1 && ready == 1'b0 )
					next_LSB_ST = LSB_ST_2;
			    else if( finish_flag[0] == 1'b1 && ready == 1'b1 )
			    	next_LSB_ST = LSB_ST_4;
			    else
			    	next_LSB_ST = LSB_ST_3;
			end
			LSB_ST_4: begin
				if(start == 1'b1)
					next_LSB_ST = LSB_ST_0;
				else
					next_LSB_ST = LSB_ST_4;//reset, stand-by
			end
			default : next_LSB_ST = LSB_ST_4;
		endcase
	end

	// S & T selector
	always@(*) begin
		//ready  = 1'b1;
		next_i = 9'd0;
		ready = 1'b1;
		next_S = S;
		next_T = T;
		next_S_out = S_out;
		case(LSB_ST)
			LSB_ST_0: ready = 1'b0;
			LSB_ST_1: begin
				if(finish_flag[1] == 1'b1) begin
					next_T = T_o1;
					next_S = 256'd1;
					ready = 1'b0;
				end
				else begin
					ready = 1'b0;
				end
			end
			LSB_ST_2: begin
				/*if( i == 9'd0 ) begin
				end
				else if( i != 9'd256 ) begin
					ready = 1'b0;
					next_T = T_o2;
					next_i = i+9'd1;
					if( d_i[i] == 1'b1 )
						next_S = S_o;   //is "i" right???
					else 
						next_S = S;
				end
				else begin*/
				    ready  = 1'b0;
				    next_i = i;
				//end
			end
			LSB_ST_3: begin
				if( i[8] != 1'd1 && finish_flag[0] == 1'b1) begin
					ready  = 1'b0;
					next_T = T_o2;
					next_i = i+9'd1;
					if( d_i[i] == 1'b1 )
						next_S = S_o;   //is "i" right???
					else 
						next_S = S;
				end
				else if( i[8] == 1'd1 && finish_flag[0] == 1'b1) begin
				    next_S_out = S;
					next_i = i;
					ready  = 1'b1;
				end	
				else begin
					next_i = i;
					ready  = 1'b0;
				end
			end
			LSB_ST_4: begin
				if(next_LSB_ST == LSB_ST_0) begin
					next_i      = 9'b0;
					next_S      = 256'b0;
					next_T      = 256'b0;
					next_S_out  = 256'b0;
					ready       = 1'b1;
				end
				else begin
					next_i = 9'd0;
					ready = 1'b1;
					next_S = S;
					next_T = T;
					next_S_out = S_out;
				end
			end
			default: begin
				next_i = 9'd0;
				ready = 1'b1;
				next_S = S;
				next_T = T;
				next_S_out = S_out;
			end
		endcase
	end
	
	
	//*sequential*//
	always@(posedge clk or posedge reset) begin
		if(reset) begin
			i      <= 9'b0;
			S      <= 256'b0;
			T      <= 256'b0;
			S_out  <= 256'b0;
			LSB_ST <= LSB_ST_4;
		end
		else begin
			i      <= next_i;
			S      <= next_S;
			T      <= next_T;
			S_out  <= next_S_out;
		    LSB_ST <= next_LSB_ST;
		end
	end
	
	
	
endmodule