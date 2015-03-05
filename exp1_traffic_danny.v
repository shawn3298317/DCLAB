module exp1_traffic )
	clk,
	rst_n,
	pause,
	HEX0,
	HEX1
);

//==== parameter definition =======================
	// for finite state machine in pause switch
	parameter S_NORMAL = 1'd0;
	parameter S_PAUSE  = 1'd1;

	// for countdown
	parameter C_PERIOD = 4'd20;  //default: 20 seconds

	// for finite state machine in countUp & countDn button
	parameter S_U0 = 1'd0;
	parameter S_U1 = 1'd1;
	parameter S_U2 = 1'd2;
	parameter S_U3 = 1'd3;

	parameter S_D0 = 1'd0;
	parameter S_D1 = 1'd1;
	parameter S_D2 = 1'd2;
	parameter S_D3 = 1'd3;

//==== in/out declaration ========================
	//-------- input -----------------------------
	input clk;
	input rst_n;   // reset signal (button)
	input countUp; // count up   signal (button)
	input countDn; // count down signal (button)
	input pause;   // pause signal (switch)

	//-------- output ----------------------------
	output [6:0] HEX0;
	output [6:0] HEX1;

//==== reg/wire declaration ======================
	//-------- output ----------------------------
	reg [6:0] HEX0;
	reg [6:0] HEX1;

	//-------- wires -----------------------------
	wire clk_16;   // 16MHz clock signal
	wire [23:0] next_clks;
	reg			next_state;

	reg	  [1:0] next_countUp_state;   
	reg   [1:0] next_countDn_state;
	
	reg   [3:0] next_countdown;
	reg	  [6:0] next_HEX0;
	reg   [6:0] next_HEX1;

	//-------- flip-flops ------------------------
	reg [23:0] clks;
	reg	       state;
	
	reg  [1:0] countUp_state; // state for countUp
	reg  [1:0] countDn_state; // state for countDn 	

	reg  [3:0] countdown;

//==== combinational part ========================

	// clock signal : produce 1Hz
	clksrc clksrc1 (clk, clk_16);
	assign next_clks = (state == S_PAUSE)? clks: clks + 24'd1;
 
 	// finite state machine (state)
 	always@(*) begin
 		case(state)
 			S_NORMAL: begin
 				if(pause == 1) next_state = S_PAUSE;
 				else next_state = S_NORMAL;
 			end
 			S_PAUSE: begin
 				if(puase == 1) next_state = S_PAUSE;
 				else next_state = S_NORMAL;
 			end
 		endcase
 	end

 	// finite state machine (countUp_state)
 	always@(*) begin
 		case(countUp_state)
 			S_U0: begin
 				if(countUp == 0) next_countUp_state = S_U1;
 				else next_countUp_state = S_U0;
 			end
 			S_U1: begin
 				if(countUp == 0) next_countUp_state = S_U2;
 				else next_countUp_state = S_U1;
 			end
 			S_U2: begin
 				next_countUp_state = S_U3;
 			end
 			S_U3: begin
 				next_countdown = countdown + 4'd1;
 			end
 		endcase
 	end

 	// finite state machine (countDn_state)
 	always@(*) begin
 		case(countDn_state)
 			S_D0: begin
 				if(countDn == 0) next_countDn_state = S_D1;
 				else next_countDn_state = S_D0;
 			end
 			S_D1: begin
 				if(countDn == 0) next_countDn_state = S_D2;
 				else next_countDn_state = S_D1;
 			end
 			S_D2: begin
 				next_countDn_state = S_D3;
 			end
 			S_D3: begin
 				next_countdown = countdown - 4'd1;
 			end
 		endcase
 	end

 	// 7-segment Displays
 	always@(*) begin
 		case(countdown[0])
 			7'd0: next_HEX0 = 7'b1000000;
 			7'd1: next_HEX0 = 7'b1111001;
 			7'd2: next_HEX0 = 7'b0100100;
 			7'd3: next_HEX0 = 7'b0110000;
 			7'd4: next_HEX0 = 7'b0011001;
 			7'd5: next_HEX0 = 7'b0010010;
 			7'd6: next_HEX0 = 7'b0000010;
 			7'd7: next_HEX0 = 7'b1111000;
 			7'd8: next_HEX0 = 7'b0000000;
 			7'd9: next_HEX0 = 7'b0010000;
 			default: next_HEX0 = 7'b1111111;
 		endcase
 	end

 	always@(*) begin
 		case(countdown[1])
 			7'd0: next_HEX1 = 7'b1000000;
 			7'd1: next_HEX1 = 7'b1111001;
 			7'd2: next_HEX1 = 7'b0100100;
 			7'd3: next_HEX1 = 7'b0110000;
 			7'd4: next_HEX1 = 7'b0011001;
 			7'd5: next_HEX1 = 7'b0010010;
 			7'd6: next_HEX1 = 7'b0000010;
 			7'd7: next_HEX1 = 7'b1111000;
 			7'd8: next_HEX1 = 7'b0000000;
 			7'd9: next_HEX1 = 7'b0010000;
 			default: next_HEX1 = 7'b1111111;
 		endcase
 	end

//==== sequential part =========================
	always@( posedge clk_16 or negedge rst_n ) begin
		if(rst_n == 0) begin
			clks      <= 24'd0;
			state     <= S_NORMAL;
			countdown <= C_PERIOD;
			HEX0      <= 7'h7f;
			HEX1      <= 7'h7f;
		end
		else begin
			//TODO...

		end
	end
endmodule
















