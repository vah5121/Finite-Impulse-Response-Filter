`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2021 12:32:25 PM
// Design Name: 
// Module Name: fir_7_7_inclass
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Filter
(
    input clk,                 // clock is used to run everything on a positive clock edge
    input rst,                 // reset signal is used to ser everything to zero if rst = 1
    
    input [7:0] weight_data,   // data thats is inserted into the filter
    input [2:0] weight_idx,    // used to direct the weight to the correct position in memory
    input weight_valid,        // used to tell the weight module that there is valid weight data ready to be inserted into the  
    output weight_ready,       // used to tell the output module that there are valid weights
   
    input [7:0] input_data,    // data that is sent into a fifo to be passed by a filter
    input input_valid,         // signal telling the input module that there is valid input data 
    output input_ready,        // signal telling the output module that there is valid input data 
    
    input output_ready,        // 
    output output_valid,       //
    output [15:0] output_data  //
);

//---- start of weight module --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

reg [7:0] weight_table [6:0];  // this create a 7 element filter where each element is 8 bits

assign weight_ready = ~rst;    // because

always@(posedge clk)
begin
    if(rst)
    begin
        weight_table[0] <= 0;
        weight_table[1] <= 0;
        weight_table[2] <= 0;
        weight_table[3] <= 0;
        weight_table[4] <= 0;
        weight_table[5] <= 0;
        weight_table[6] <= 0;
    end else begin
        if(weight_valid & weight_ready)
        begin
            weight_table[weight_idx] <= weight_data;
        end
    end
end

//---- End of weight module ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//---- start of input module ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

reg [7:0] shift_register [6:0]; //shift register for input data

assign input_ready = !rst;

always@(posedge clk)
begin
    if(rst)
    begin
        shift_register[0] <= 0;
        shift_register[1] <= 0;
        shift_register[2] <= 0;
        shift_register[3] <= 0;
        shift_register[4] <= 0;
        shift_register[5] <= 0;
        shift_register[6] <= 0;
    end else begin
        if(input_ready & input_valid)
        begin
            shift_register[6] <= shift_register[5];
            shift_register[5] <= shift_register[4];
            shift_register[4] <= shift_register[3];
            shift_register[3] <= shift_register[2];
            shift_register[2] <= shift_register[1];
            shift_register[1] <= shift_register[0];
            shift_register[0] <= input_data;
        end
    end
end

//---- End of weight module ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//---- start of output module ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

reg output_ready_reg[2:0];
reg valid_delay;
assign output_valid = rst ? output_ready_reg[2]: valid_delay;

reg [15:0] output_reg;
assign output_data = output_reg;

reg ready_delay;
reg [15:0] mult_results[6:0];
reg [15:0] add_results_s1[3:0];
reg [15:0] add_results_s2[1:0];

//if rst, start the daisy chain the resets each stage of the 2D convolution
always@(posedge clk)
begin
    output_ready_reg[1] <= output_ready_reg[0];
    output_ready_reg[2] <= output_ready_reg[1]; 
    valid_delay <= output_ready_reg[2];
    if(rst)
    begin
        ready_delay <= 0;
        output_ready_reg[0] <= ready_delay;
        mult_results[0] <= 0;
        mult_results[1] <= 0;
        mult_results[2] <= 0;
        mult_results[3] <= 0;
        mult_results[4] <= 0;
        mult_results[5] <= 0;
        mult_results[6] <= 0;
    end
    else begin
        ready_delay <= 1;
        output_ready_reg[0] <= output_ready;
    end
end

// next chunck handles the 2D convolution to find the output
always@(posedge clk) 
begin
    if(output_ready) begin
        // stage 0 - multiply shift register with weight table
        mult_results[0] <= shift_register[0] * weight_table[0];
        mult_results[1] <= shift_register[1] * weight_table[1];
        mult_results[2] <= shift_register[2] * weight_table[2];
        mult_results[3] <= shift_register[3] * weight_table[3];
        mult_results[4] <= shift_register[4] * weight_table[4];
        mult_results[5] <= shift_register[5] * weight_table[5];
        mult_results[6] <= shift_register[6] * weight_table[6];
    end
    if(output_ready_reg[0]) begin
        ///stage 1 - add multiplication results
        add_results_s1[0] <= mult_results[0] + mult_results[1];
        add_results_s1[1] <= mult_results[2] + mult_results[3];
        add_results_s1[2] <= mult_results[4] + mult_results[5];
        add_results_s1[3] <= mult_results[6]; 
    end
    if(output_ready_reg[1]) begin
        // stage 2 - add stage 1 sums
        add_results_s2[0] <= add_results_s1[0] + add_results_s1[1];
        add_results_s2[1] <= add_results_s1[2] + add_results_s1[3];
    end
    if(output_ready_reg[2]) begin
        // stage 3 - add stage 2 sums
        output_reg <= add_results_s2[0] + add_results_s2[1];
    end  
    
end

//---- End of output module ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



endmodule
















