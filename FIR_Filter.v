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
    input clk,                 // use clk to run every module on a positive clock edge
    input rst,                 // use rst to reset the module
    
    input [7:0] weight_data,   // insert this input data into the 7 element weight table(filter)
    input [2:0] weight_idx,    // index directs weight_data to the correct position in the weight_table(filter)
    input weight_valid,        // assert this signal when there is valid weight_data
    output weight_ready,       // assert this signal when the weight module is ready to recieve data
   
    input [7:0] input_data,    // insert this data into the 7 element register
    input input_valid,         // assert this signal when there is valid_data 
    output input_ready,        // assert this signal when the input module is ready to recieve data 
    
    input output_ready,        // assert this signal when the output module is ready to recieve data
    output output_valid,       // assert this signal when there is valid output_data
    output [15:0] output_data  // set this signal to the output of the 2D convolution
);

//---- start of weight(filter) module --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

reg [7:0] weight_table [6:0];  // this line creates a 7 element filter where each element is-8 bits

assign weight_ready = ~rst;    // filter is ready to recieve data as long as reset is not asserted

always@(posedge clk)           // at every rising clock edge
begin
    if(rst)                    // if reset = 1, set every value inside the filter to zero
    begin
        weight_table[0] <= 0;
        weight_table[1] <= 0;
        weight_table[2] <= 0;
        weight_table[3] <= 0;
        weight_table[4] <= 0;
        weight_table[5] <= 0;
        weight_table[6] <= 0;
    end else begin                                    // else 
        if(weight_valid & weight_ready)               // if the weight module is ready to recieve data and if there is valid weight data
        begin
            weight_table[weight_idx] <= weight_data;  // then place weight_data inside weight_table at address weight_idx
        end
    end
end

//---- End of weight module ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//---- start of input module ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

reg [7:0] shift_register [6:0]; // this line creates a 7-element shift register where every element is 8-bits

assign input_ready = !rst;      // input module is ready to recieve input as long as reset equals 0

always@(posedge clk)            // at every positive clock edge
begin
    if(rst)                     // if reset = 1, then set every element inside the shift register to zero
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
        begin                                        // else
            shift_register[6] <= shift_register[5];  // if the input module is ready to recieve data and if there is valid input data
            shift_register[5] <= shift_register[4];  // then:
            shift_register[4] <= shift_register[3];  // shift everything in the shift_register to the left by 1
            shift_register[3] <= shift_register[2];  // and set the 1st element inside the shift register to input_data
            shift_register[2] <= shift_register[1];
            shift_register[1] <= shift_register[0];
            shift_register[0] <= input_data;
        end
    end
end

//---- End of weight module ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//---- start of output module ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

reg output_ready_reg[2:0];        // creates a shift register for output_ready because the output module is broken into stages
reg valid_delay;                  // use to assert output_valid when rst is low 
assign output_valid = rst ? output_ready_reg[2]: valid_delay;  // mux that decides when the ouput is valid

reg [15:0] output_reg;            
assign output_data = output_reg;  // continuously assigns the output to output_reg

reg ready_delay;                  // when reset goes high, this signal adds an extra delay to ensure the pipeline gets cleared
reg [15:0] mult_results[6:0];     // next set of registers are just temporary holders for computations
reg [15:0] add_results_s1[3:0];
reg [15:0] add_results_s2[1:0];

//if rst, start the daisy chain that resets each stage of the 2D convolution
always@(posedge clk)
begin
    output_ready_reg[1] <= output_ready_reg[0];  // always pass output_ready to the next stage
    output_ready_reg[2] <= output_ready_reg[1]; 
    valid_delay <= output_ready_reg[2];         
    if(rst)                                      // if rst is asserted
    begin
        ready_delay <= 0;                        // create a delay in output_ready to ensure the output module gets cleared
        output_ready_reg[0] <= ready_delay;
        mult_results[0] <= 0;                    // and clear the first stage of the output module
        mult_results[1] <= 0;
        mult_results[2] <= 0;
        mult_results[3] <= 0;
        mult_results[4] <= 0;
        mult_results[5] <= 0;
        mult_results[6] <= 0;
    end
    else begin                                   // else
        ready_delay <= 1;                        // shift output_ready normally
        output_ready_reg[0] <= output_ready;
    end
end

// next chunck handles the 2D convolution to find the output
always@(posedge clk) 
begin
    if(output_ready) begin
        // stage 0 - multiply element i of shifr_register with element i of weight_table
        mult_results[0] <= shift_register[0] * weight_table[0];
        mult_results[1] <= shift_register[1] * weight_table[1];
        mult_results[2] <= shift_register[2] * weight_table[2];
        mult_results[3] <= shift_register[3] * weight_table[3];
        mult_results[4] <= shift_register[4] * weight_table[4];
        mult_results[5] <= shift_register[5] * weight_table[5];
        mult_results[6] <= shift_register[6] * weight_table[6];
    end
    if(output_ready_reg[0]) begin
        ///stage 1 - add multiplication results from stage 0 in pairs
        add_results_s1[0] <= mult_results[0] + mult_results[1];
        add_results_s1[1] <= mult_results[2] + mult_results[3];
        add_results_s1[2] <= mult_results[4] + mult_results[5];
        add_results_s1[3] <= mult_results[6]; 
    end
    if(output_ready_reg[1]) begin
        // stage 2 - add sum results from stage 1 in pairs
        add_results_s2[0] <= add_results_s1[0] + add_results_s1[1];
        add_results_s2[1] <= add_results_s1[2] + add_results_s1[3];
    end
    if(output_ready_reg[2]) begin 
        // stage 3 - add stage 2 sum results in pairs
        output_reg <= add_results_s2[0] + add_results_s2[1];
    end  
    
end

//---- End of output module ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



endmodule
















