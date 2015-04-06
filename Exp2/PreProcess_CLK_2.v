`timescale 1ns/1ps
module PreProcess_CLK (
    //input
    clk,
    PP_start,
    reset,
    N_i,
    M_i,
    //output
    T_o,
    finish
);
    
    //input & output variables
    input  clk;
    input  PP_start, reset;
    input  [255:0] N_i, M_i;
    output reg         finish;
    output    [255:0] T_o;

    //reg    [256:0] temp,
    //               next_temp;
    reg    [256:0] temp;
    reg    [256:0] next_temp;
    reg            next_finish;
    reg    [1:0]  PP_ST,
                  next_PP_ST;
    //reg [255:0] next_T_o;

    //counter variables
    reg [8:0] i,
              next_i;

    //parameter PP_ST_0 = 2'b00;
    parameter PP_ST_1 = 2'b10;
    parameter PP_ST_2 = 2'b11;

    //combinational part
    assign T_o = temp;
    // state machine
    always@(*) begin
        case(PP_ST)
        /*PP_ST_0: begin  // PP_CLK is in stand-by mode (triggered by reset signal)
            if(PP_start == 1'b1) begin
                next_PP_ST = PP_ST_1;
            end
            else
                next_PP_ST = PP_ST_0;
        end*/
        PP_ST_1: begin // PP_CLK is under calculating...
            if( finish != 1'b1) begin
                next_PP_ST = PP_ST_1;
            end
            else
                next_PP_ST = PP_ST_2;
        end
        PP_ST_2: begin // PP_CLK finished calaculating
            if(PP_start == 1'b1) begin
                next_PP_ST = PP_ST_1;
            end
            else
                next_PP_ST = PP_ST_2; //wait for LSB_ME to give out the next start cmd..
        end
        default: next_PP_ST = PP_ST_2;
        endcase
    end



    always@(*) begin
        finish = 1'b0;
        next_temp = 257'b0;
        //next_T_o  = 256'b0;
        next_i    = 9'b0;
        case(PP_ST) 
        /*PP_ST_0: begin
            if( next_PP_ST == PP_ST_1 ) begin
                finish      = 1'b0;
                next_i      = 9'b0;
                next_temp   = M_i;
                next_T_o    = T_o;
            end
        end*/
        PP_ST_1: begin

            if ( i[8] != 1'd1 ) begin
                finish      = 1'b0;
                next_i      = i + 9'b1;
                //CALCULATION : temp = temp*2 % N
                next_temp   = ((temp<<1) > N_i)? (temp<<1)-N_i: temp<<1;
                //next_T_o    = T_o;
            end
            else begin
                finish      = 1'b1;
                next_i      = 9'b0;
                next_temp   = temp;
                //next_T_o    = temp;
            end
        end
        PP_ST_2: begin
            if( next_PP_ST == PP_ST_1 ) begin
                finish      = 1'b0;
                next_i      = 9'b0;
                next_temp   = M_i;
                //next_T_o    = T_o;
            end
            else begin /*TO CHECK*/
                finish     = 1'b1;
                next_temp  = temp;
                //next_T_o   = T_o;
                next_i     = i;
            end
        end
        endcase
    end

    //sequential part
    always@(posedge clk or posedge reset ) begin

        if(reset) begin
            i      <= 9'd0;
            //T_o    <= 256'd0;
            temp   <= 257'd0;
            PP_ST  <= PP_ST_2;
        end
        else begin
            i      <= next_i;
            temp   <= next_temp;
            //T_o    <= next_T_o;
            PP_ST  <= next_PP_ST;
        end
    end

endmodule