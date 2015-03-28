module MSB_LE (
	clk,
	M_i,
	N_i,
	d_i,
	start,
	
	ready,
	S_out
);

	input 		  	   clk,
					   start;
	input [255:0] 	   M_i,
					   N_i,
					   d_i;
					   
	output reg   	   ready;
	output reg [255:0] S_out;
	
	
	reg   [1:0]   	   cmd_START_ST;
	reg   [1:0]   	   next_cmd_START_ST;
	wire  [1:0]   	   FINISH_FLAG;
	wire  [255:0] 	   T_o1,
					   S_o,
					   T_o2;
	reg   [255:0]      S,
					   T;
	reg   [255:0] 	   next_T,
					   next_S;
	reg   [8:0]   	   i,
					   next_i;
	
	
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
				next_S = 256'd1;
				next_T = T_o1;
			end
			
			FLAG_MA: begin
				
				if( i == 9'd256) begin
					next_S = S;
					next_T = T;
					S_out = S; // can we do this??
					ready  = 1'b1; //can we do this??
				end
				else begin
					next_T = T_o2;
					if(d_i[i] == 1'b1)
						next_S = S_o;
					else
						next_S = S;
				end
				
			end
			
			default: begin
				next_S = S;
				next_T = T;
			end
		
		endcase
		
	
	end
	
	
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
	
	//*sequential*//
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
	
	
	
endmodule