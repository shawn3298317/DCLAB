`timescale 1ns/1ps
module Audio_Ineterface(
    clk,
    reset,
    Bclk,
    ADCLRclk,
    DACLRclk,
    ADCData,
    dac_data,  // receive data from the SRAM
    record,    // writing data from voice
    play,      // reading data from the SRAM
    DACData,   // output data to the CODEC
    adc_data,  // store data to the SRAM
    ready
);

parameter RECORD   = 2'b01;
parameter PLAY     = 2'b10;
parameter STAND_BY = 2'b00;
    //-----input & output declaration-----
input  clk,
       reset,
       Bclk,
       ADCLRclk,
       DACLRclk,
       ADCData,
       record,
       play;
input  [15:0] dac_data;

output DACData,
       ready;
output [15:0] adc_data;

    //-----register & wire declaration-----
reg    [15:0] adc_data_r,
              next_adc_data_r;
reg    ready_r,
       next_ready,
       DACData_r;
reg    [4:0]  Bclk_counter,       // counting cycles of Bclk
              next_Bclk_counter;
reg    [1:0]  state,
              next_state;

SRAM()

assign Bclk     = ~clk;
assign ready    = ready_r;
assign adc_data = adc_data_r;
assign DACData  = DACData_r;

always@(*) begin
    if(record == 1'b1) 
        next_state = RECORD;
    else if(play == 1'b1)
        next_state = PLAY;
    else
        next_state = STAND_BY;
end

always@(*) begin
    case(state)
        RECORD: begin
            if(ADCLRclk == 1'b1) begin                        //not sure yet, this is definitely wrong
                if(Bclk_counter == 5'b0) begin
                    next_Bclk_counter = Bclk_counter + 5'b1;
                    next_adc_data_r   = 16'b0;
                    next_ready        = 1'b0;
                end
                else if(Bclk_counter == 5'd17) begin
                    next_Bclk_counter = 5'b0;
                    next_adc_data_r   = adc_data_r;
                    next_ready        = 1'b1;
                end
                else begin
                    next_Bclk_counter = Bclk_counter + 5'b1;
                    next_adc_data_r[5'd16 - Bclk_counter] = ADCData;
                    next_ready = 1'b0;
                end
            end
            else begin
                next_Bclk_counter = 5'b0;
                next_adc_data_r   = 16'b0;
                next_ready        = 1'b0;
            end
        end
        PLAY: begin
            if(DACLRclk == 1'b1) begin                       //not sure yet, this is definitely wrong
                if(Bclk_counter == 5'b0) begin
                    next_Bclk_counter = Bclk_counter + 5'b1;
                    DACData_r         = 1'b0;
                end
                else if(Bclk_counter == 5'd17) begin
                    next_Bclk_counter = 5'b0;
                    DACData_r         = 1'b0;
                end
                else begin
                    next_Bclk_counter = Bclk_counter + 5'b1;
                    DACData_r         = dac_data[5'd16 - Bclk_counter];
                end
            end
            else begin
                next_Bclk_counter = 5'b0;
                DACData_r         = 1'b0;
            end
        end
        STAND_BY: begin
            next_Bclk_counter = 5'b0;
            next_adc_data_r   = 16'b0;
            DACData_r         = 1'b0;
            next_ready        = 1'b0;
        end
        default: begin
            next_Bclk_counter = 5'b0;
            next_adc_data_r   = 16'b0;
            DACData_r         = 1'b0;
            next_ready        = 1'b0;
        end
    endcase
end

always@(negedge Bclk or negedge reset) begin
    if(!reset) begin
        Bclk_counter = 5'b0;
        state = STAND_BY;
        ready_r = 1'b0;
        adc_data_r = 16'b0;
    end
    else begin
        Bclk_counter = next_Bclk_counter;
        state = next_state;
        ready_r = next_ready;
        adc_data_r = next_adc_data_r;
    end
end

endmodule