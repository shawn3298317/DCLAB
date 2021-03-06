<<<<<<< HEAD
odule MSB_LE (
=======
`timescale 1ns/1ps
module LSB_ME (
	reset,
>>>>>>> 7b70402c2b15ae183f34f3b083ecf61c7b4a8bf4
	clk,
	M_i,
	N_i,
	d_i,
	start,
	
	ready,
	S_out
);

<<<<<<< HEAD
	input 		  	   clk,
=======
	input 		  	   clk, 
					   reset,
>>>>>>> 7b70402c2b15ae183f34f3b083ecf61c7b4a8bf4
					   start;
	input [255:0] 	   M_i,
					   N_i,
					   d_i;
					   
	output reg   	   ready;
	output reg [255:0] S_out;
	
	
<<<<<<< HEAD
	reg   [1:0]   	   cmd_START_ST;
	reg   [1:0]   	   next_cmd_START_ST;
	wire  [1:0]   	   FINISH_FLAG;
=======
	reg   [255:0]      next_S_out;
	wire  [2:0]   	   finish_flag;
>>>>>>> 7b70402c2b15ae183f34f3b083ecf61c7b4a8bf4
	wire  [255:0] 	   T_o1,
					   S_o,
					   T_o2;
	reg   [255:0]      S,
					   T;
	reg   [255:0] 	   next_T,
					   next_S;
	reg   [8:0]   	   i,
					   next_i;
<<<<<<< HEAD
	
	
	parameter ST_PP      = 2'b10;
	parameter ST_WAITING = 2'b00;
	parameter ST_MA      = 2'b01;
	
	parameter FLAG_PP    = 2'b10;
	parameter FLAG_MA    = 2'b01;
	
	
	
	
	//****module initialization*****//
	PreProcess      PP   (.start(cmd_START_ST[1]),.N_i(N_i),.M_i(M_i)          ,.T_o(T_o1),.finish(FINISH_FLAG[1]));
	MA              MA_S (.start(cmd_START_ST[0]),.N_i(N_i),.A_i(S)   ,.B_i(T) ,.V_o(S_o ),.finish(FINISH_FLAG[0]));
	MA              MA_T (.start(cmd_START_ST[0]),.N_i(N_i),.A_i(T)   ,.B_i(T) ,.V_o(T_o2),.finish(FINISH_FLAG[0]));
	
	
	
	// S & T selector
	always@(*) begin
		
		// counter
		next_i = (i<9'd256)?i+1:i;
		case(FINISH_FLAG)
			
			FLAG_PP: begin
				S = 256'd1;
				T = T_o1;;
				FINISH_FLAG = FLAG_MA;
			end
			
			FLAG_MA: begin
				next_i = (i < 9'd256)? i+1: i;
				if( i == 9'd256) begin
					S_out = S; // can we do this??
					ready  = 1'b1; //can we do this??
				end
				else begin
					T = T_o2;
					if(d_i[i] == 1'b1)
						S = S_o;
					else
						S = S;
				end
				
			end
			
			default: begin
				S = 256'd1;
				T = T_o1;
			end
		
		endcase
		
	
	end
	
	
	/*
	always@(*) begin
		
		case(cmd_START_ST)
		
			ST_PP: begin
				next_cmd_START_ST = ST_WAITING;
			end
			
			ST_WAITING: begin
				if(FINISH_FLAG == FLAG_PP || FINISH_FLAG == FLAG_MA)
					next_cmd_START_ST = ST_MA;
				else
					next_cmd_START_ST = ST_WAITING;
			end
			
			ST_MA: begin
				next_cmd_START_ST = ST_WAITING;
			end
		
		
		endcase
	
	end
	*/
	//*sequential*//
	/*
	always@(posedge clk or posedge start) begin
		
		if(start == 1'b1) begin
			cmd_START_ST = ST_PP;
			i = 0;
			ready = 0;
			S = 0;
			T = 0;
			S_out = 0;

		end
		else begin
			i = next_i;
			S = next_S;
			T = next_T;
			cmd_START_ST  = next_cmd_START_ST;
		
		end
	end
	*/
	
	
endmodule
=======
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
	
	
	
endmodule
>>>>>>> 7b70402c2b15ae183f34f3b083ecf61c7b4a8bf4
