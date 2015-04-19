module PreProcess (
    start,
    N_i,
    M_i,
    clear,
    T_o,
    finish
);
    
    //input & output variables
    input  start, clear;
    input  [255:0] N_i, M_i;
    output reg [255:0] T_o; 
    output reg finish;

    reg    [256:0] temp,
                   next_temp;
    reg    [255:0] next_T_o;
    reg            next_finish;

    //counter variables
    reg [8:0] i,
              next_i;

    //combinational part
    always@(*) begin
        if (i != 9'd256) begin
            next_temp = M_i<<1;
            next_T_o = (temp > N_i)? temp - N_i: temp;
            next_i = i+1;
        end
        else begin
            next_temp = temp;
            next_T_o = temp;
            next_finish = 1'b1;
        end
    end

    //sequential part
    alwaye@(posedge clk or posedge start or posedge clear) begin
        if(start == 1'b1) begin
            i      <= 9'b0;
            temp   <= 257'b0;
            T_o    <= 256'b0;
            finish <= 1'b0;
        end
        else if(clear == 1'b1) begin
            i      <= 1'b0;
            T_o    <= next_T_o;
            temp   <= 257'b0;
            finish <= 1'b0;
        end
        else begin
            i      <= next_i;
            T_o    <= next_T_o;
            temp   <= next_temp;
            finish <= next_finish;

endmodule