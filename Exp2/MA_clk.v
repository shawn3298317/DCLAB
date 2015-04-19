module MA (
	//input
	clk,
	start,
	N_i,
    A_i,
	B_i,
	//output
	V_o,
	finish
    );
    
	//----input declaration----//
	input clk,start;
    input [255:0] A_i,B_i,N_i;
	
	//----output declaration----//
    output reg [255:0] V_o;
    output reg         finish;
	
	//----reg declaration----//
    reg   [257:0] Vi; // Vi
	reg   [258:0] f; // f = Vi + ai*B + qi*N
	reg   [8:0]   i; // bit counter
	reg           qi;
	

	
	always@(*) begin
	
		next_i  = (i<9'd256)? i+1 : i;
		
		if(i != 9'd256) begin
			next_finish = 1'b0;
			next_V_o  = 1'b0;
			
			if(A_i[i] == 1'b1) 
				next_f = Vi + B_i;
			else
				next_f = Vi;
			
			qi = next_f[0];
			
			if( qi == 1'b1)
				next_f = (f + N_i)<<2;
			else
				next_f = f<<2;
			
			next_Vi = (f > N_i)? f-N_i : f;
		end
		else begin
			next_finish = 1'b1;
			next_V_o = Vi;
			next_f = 0;
			next_Vi = 0;
		end
	end
	
	
	always@(posedge clk or posedge start) begin
		
		if(start == 1'b1) begin
			i      = 0;
			Vi     = 0;
			V_o    = 0;
			finish = 0;
			f      = 0;
		end
		else begin
			i      = next_i;
			finish = next_finish;
			V_o    = next_V_o;
			Vi     = next_Vi;
			f      = next_f;
		end
	end
	
endmodule

