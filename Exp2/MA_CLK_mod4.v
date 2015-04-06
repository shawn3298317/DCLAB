`timescale 1ns/1ps
module MA_CLK_mod4 (
	//input
	clk,
	MA_start,
	N_i,
    A_i,
	B_i,
	reset,
	//output
	V_o,
	finish
    );
    
	//----input declaration----//
	input              clk,
	                   MA_start,
	                   reset;
    input      [255:0] A_i,
    	     		   B_i,
    	     		   N_i;
	
	//----output declaration----//
    output  [255:0] V_o;
    output reg         finish;
	
	//----reg declaration----//
    reg        [257:0] Vi;
	reg        [258:0] f1,
					   f2,
		     	       f;
	reg        [8:0]   i;
	reg        [1:0]   MA_ST;
	reg        [2:0]   q;

	//----next reg declaration----//
	//reg        [255:0] next_V_o;
    reg        [257:0] next_Vi; // Vi
	reg        [258:0] next_f; // f = Vi + ai*B + qi*N
	reg        [8:0]   next_i; // bit counter
	reg        [1:0]   next_MA_ST;
	reg                next_finish;

	//parameter MA_ST_0 = 2'b00;
	parameter MA_ST_1 = 2'b10;
	parameter MA_ST_2 = 2'b11;
	
	assign V_o = Vi;

	// state machine
	always@(*) begin
		case(MA_ST)
		/*MA_ST_0: begin  // MA_CLK is in stand-by mode (triggered by reset signal)
			if( MA_start == 1'b1 )
				next_MA_ST = MA_ST_1;
			else
				next_MA_ST = MA_ST_0;
		end*/
		MA_ST_1: begin // MA_CLK is under calculating...
			if( finish != 1'b1 )
				next_MA_ST = MA_ST_1;
			else
				next_MA_ST = MA_ST_2;
		end
		MA_ST_2: begin // MA_CLK finished calaculating, final
			if( MA_start == 1'b1 )
				next_MA_ST = MA_ST_1;
			else
				next_MA_ST = MA_ST_2; //wait for LSB_ME to give out the next start cmd..
		end
		default: next_MA_ST = MA_ST_2;
		endcase
	end



	// calculate block
	always@(*) begin
	    next_i   = 9'b0;
		next_Vi  = Vi;
		//next_V_o = V_o;
		next_f   = f;
		f1       = 259'b0;
		f2       = 259'b0;
		q        = 3'b0;
		finish   = 1'b0;
        case(MA_ST)
		/*MA_ST_0: begin
			if( next_MA_ST == MA_ST_1 ) begin // calculate only when we are in MA_ST_1
				next_Vi     = 258'b0;
				next_f      = 258'b0;
				//f1          = 258'b0;
			end
			else finish = 1'b0;

		end*/
		MA_ST_1: begin
			if( i[8] != 1'd1 ) begin
				next_i   = i + 9'd2;

				f1       = (A_i[i+1] == 1'b1)? ((A_i[i] == 1'b1)?(Vi+B_i+B_i+B_i):(Vi+B_i+B_i)) : ((A_i[i] == 1'b1)?(Vi+B_i):Vi); 
				/*can we use multiplier?*/

				q        = (f1[1:0] == 2'b0)?3'b0: 3'd4-{1'b0,f1[1:0]};

				f2       = (q[0] == 1'b1)? ((q[1] == 1'b1)?(f1+N_i+N_i+N_i):(f1+N_i)) : ((q[1] == 1'b1)?(f1+N_i+N_i):(f1));

				next_f   = f2 >> 2'd2;
				next_Vi  = (next_f >= N_i)? next_f - N_i : next_f; 

				


				


				/*
				f1       = (A_i[i] == 1'b1)? Vi + B_i : Vi;
				next_f   = (f1[0] == 1'b1)? ( f1 + N_i )>>1 : f1>>1;
				next_Vi  = (next_f >= N_i)? next_f - N_i : next_f; // maintain V under the limitation of N*/
			end
			else begin
				finish = 1'b1;
				//next_V_o = Vi;
			end
		end
		MA_ST_2: begin
			if( next_MA_ST == MA_ST_1 ) begin
				//next_i = 9'b0;
				//finish = 1'b0;
				next_f = 259'b0;
				//next_V_o = V_o;
				//f1 = 258'b0;
				next_Vi = 257'b0;
			end
			else finish = 1'b0;
		end
		endcase
	end

	
	always@(posedge clk or posedge reset ) begin //finish should be default to 0 before we (wait for solving)
		
		if(reset) begin
			i      <= 9'd0;
			Vi     <= 257'b0;
			//V_o    <= 256'b0;
			f      <= 259'b0;
			MA_ST  <= MA_ST_2;
		end
		else begin
			i      <= next_i; 
			Vi     <= next_Vi;
			//V_o    <= next_V_o;
			f      <= next_f;
			MA_ST  <= next_MA_ST;
		end
	end
	
endmodule