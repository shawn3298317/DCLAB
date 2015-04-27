`timescale 1ns/1ps
module Audio_Ineterface(
    clk,
    reset,
    //-----signal and inputdata from codec-----
    Bclk, 
    ADCLRk,
    DACLRk,
    ADCdata,
    //-----operation switch-----
    record, 
    play,
    //-----output data to codec-----
    DACdata 
);

parameter RECORD   = 2'b01;
parameter PLAY     = 2'b10;
parameter STAND_BY = 2'b00;

parameter LOW      = 1'b0;
parameter HIGH     = 1'b1;
//-----input & output declaration-----
input  clk;
input  reset;
input  Bclk;
input  ADCdata;
input  ADCLRk;
input  DACLRk;
input  record;
input  play;

output DACdata;

//-----register & wire declaration-----
reg    [15:0] adc_data;         
reg    [15:0] next_adc_data;
reg    [15:0] dac_data;
reg    [4:0]  Bclk_counter;       // counting cycles of Bclk
reg    [4:0]  next_Bclk_counter;
reg    [1:0]  operation_state;
reg    [1:0]  next_operation_state;
reg    ADCLRk_state;
reg    next_ADCLRk_state;
reg    start;                     // start to get ADCdata
reg    next_start;
reg    DACdata_r;

wire   ready;                     // write enable for SRAM 
//SRAM(clk, reset, play, ready, adc_data dac_data)  //calling SRAM module

assign ready   = (Bclk_counter == 5'd16 && operation_state == RECORD)? 1'b1:1'b0; 
assign DACdata = DACdata_r;

// next_state logic for operation mode
always@(*) begin
    if(record == 1'b1 && play == 1'b0)
        next_operation_state = RECORD; 
    else if(record == 1'b0 && play == 1'b1) 
        next_operation_state = PLAY;
    else
        next_operation_state = STAND_BY;
end

always@(*) begin
    if(ADCLRk == 1'b0) next_ADCLRk_state = LOW;
    else               next_ADCLRk_state = HIGH;
end

// generate start pulse
always@(*) begin
    if(ADCLRk_state == LOW && next_ADCLRk_state == HIGH)
        next_start = 1'b1;
    else if(ADCLRk_state == HIGH && next_ADCLRk_state == LOW)
        next_start = 1'b1;
    else
        next_start = 1'b0;
end

// next_state logic
always@(*) begin
    next_adc_data     = adc_data;
    next_Bclk_counter = 5'b0;
    DACdata_r         = 1'b0;
    case(operation_state)
        RECORD: begin
            if(start == 1'b1) begin
                next_adc_data[5'd15 - Bclk_counter] = ADCdata;
                next_Bclk_counter                   = Bclk_counter + 5'b1;
            end
            else begin
                if(Bclk_counter == 5'd16) begin
                    next_adc_data     = adc_data;
                    next_Bclk_counter = 5'b0;
                end
                else begin
                    next_adc_data[5'd15 - Bclk_counter] = ADCdata;
                    next_Bclk_counter                   = Bclk_counter + 5'b1; 
                end
            end
        end
        PLAY: begin
            if(start == 1'b1) begin
                DACdata_r         = dac_data[5'd15 - Bclk_counter];
                next_Bclk_counter = Bclk_counter + 5'b1;
            end
            else begin
                if(Bclk_counter == 5'd16) begin
                    DACdata_r         = 1'b0;
                    next_Bclk_counter = 5'd0; 
                end
                else begin
                    DACdata_r         = dac_data[5'd15 - Bclk_counter];
                    next_Bclk_counter = Bclk_counter + 5'b1;
                end
            end
        end
        STAND_BY: begin
            next_Bclk_counter = 5'b0;
            next_adc_data     = adc_data;
            DACdata_r         = 1'b0;
        end
    endcase
end

always@(negedge Bclk or negedge reset) begin
    if(!reset) begin
        Bclk_counter           = 5'b0;
        operation_state        = STAND_BY;
        ADCLRk_state           = LOW;
        adc_data               = 16'b0;
    end
    else begin
        Bclk_counter           = next_Bclk_counter;
        operation_state        = next_operation_state;
        ADCLRk_state           = next_ADCLRk_state;
        adc_data               = next_adc_data;
    end
end

endmodule