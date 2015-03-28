module MA (
	//input
	start,
	N_i,
    A_i,
	B_i,
	//output
	V_o,
	finish
    );
    
	//----input declaration----//
    input [255:0] A_i,B_i,N_i;
	input start;
	
	//----output declaration----//
    output reg [255:0] V_o;
    output reg         finish;
	
	//----reg declaration----//
    reg   [257:0] Vi; // Vi
	reg   [258:0] f; // f = Vi + ai*B + qi*N
	reg   [8:0]   i; // bit counter
	reg           qi;
	
	
	
	always@(*) begin
	
		if(start == 1'b1) begin
			i   = 0;
			Vi  = 0;
			V_o = 0;
			finish = 0;
		end

		else begin 
			if(i != 9'd256) begin
				if(A_i[i] == 1'b1) 
					f = Vi + B_i;
				else
					f = Vi;
				
				qi = f[0];
				
				if( qi == 1'b1)
					f = (f + N_i)<<2;
				else
					f = f<<2;
				
				Vi = (f > N_i)? f-N_i : f;
				i  = i+1;
			end
			else begin
				finish = 1'b1;
				V_o = Vi;
			end
		end	
	end
	
endmodule

