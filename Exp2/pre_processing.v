module pre_processing (
    start,
    N_i,
    M_i,
    T_o,
    finish
);
    
    //input & output variables
    input  start;
    input  [255:0] N_i, M_i;
    output reg [255:0] T_o; 
    output reg finish;

    reg    [256:0] temp;

    //counter variables
    reg [8:0] i;

    
    always@(*) begin
        if (start == 1'b1) begin
            i = 0;
            temp = 0;
            T_o = 0;
            finish = 0;
        end

        else begin
            if (i != 9'd256) begin
                temp = M_i<<1;
                temp = (temp > N_i)? temp - N: temp;
                i = i+1;
            end
            else begin
                T_o = temp;
                finish = 1'b1;
            end
        end
    end
endmodule