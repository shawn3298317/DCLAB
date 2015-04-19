`timescale 1ns/1ps
`define CYCLE      20.0
`define End_CYCLE  1000       // Modify cycle times once your design need more cycle times!
`define TOTAL_DATA 38
`define TEST_DATA  2


module I2C_tb;

//===============================================================
//==== signal declaration =======================================
    // ----------------------------------------------------------
    // -------- singals in top module ---------------------------
    reg   clk;
    reg   [23:0] data;
    reg   reset;
    reg   activate;

    wire  end_o;
    wire  ack_o;
    wire  SDO_o;
    wire  SD_cnt_o; 

    wire  I2C_SCLK;
    wire  I2C_SDAT;

    // -------- input data & output golden pattern --------------
    

    // -------- variables &indices ------------------------------
    


//==== module connection ========================================
    I2C_Interface I2C_test(
    //Top module I/O port
    .CLK(clk),
    .DATA(data),
    .RESET(reset),
    .ACTIVATE(activate),
    .END(end_o),
    .ACK(ack_o),
    //Codec port
    .I2C_SCLK(I2C_SCLK),
    .I2C_SDAT(I2C_SDAT),
    //Debug port
    .SDO(SDO_o),
    .SD_cnt(SD_cnt_o)
    );

//==== create waveform file =====================================
    initial begin
        $dumpfile("I2C_tb.fsdb");
        $dumpvars;
    end

//==== start simulation =========================================
    
    always begin 
        #(`CYCLE/2) clk = ~clk; 
    end

    initial begin
        #0;
        clk   = 1'b1;
        data  = 24'b0;
        reset = 1'b1;
        activate  = 1'b0;

        #(`CYCLE)
        reset = 1'b0;

        #(`CYCLE*4)
        //data = 24'b001101000000000010010111;
        data = 24'b101010101010101010101010;
        activate = 1'b1;

        #(`CYCLE*50)

        $display("-----------------------------------------------------\n");
        $display("Congratulations! All data have been generated successfully!\n");
        $display("-------------------------PASS------------------------\n");
        $finish;
    end
    
    

endmodule
