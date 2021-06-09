
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2021 03:52:37 PM
// Design Name: 
// Module Name: testbench
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


module testbench;

reg clk, rst;

wire [15:0] output_data;
reg [7:0] input_data;
reg [7:0] weight_data;
reg [2:0] weight_idx;

wire weight_ready;
wire input_ready;
reg input_valid;
reg weight_valid;
reg output_ready;
wire output_valid;

initial begin
    clk = 0;
    rst = 1;
    weight_idx = 0;
    weight_data = 0;
    input_data = 0;
    output_ready = 0;
    input_valid = 0;
    weight_valid = 0;
    #14
    weight_valid = 1;
    #6;
    rst = 0;
    #4;
    output_ready = 1;
    weight_idx = 0;
    weight_data = 1;
    #4;
    weight_idx = 1;
    weight_data = 1;
    #4;
    weight_idx = 2;
    weight_data = 1;
    #4;
    weight_idx = 3;
    weight_data = 1;
    #4;
    weight_idx = 4;
    weight_data = 1;
    #4;
    weight_idx = 5;
    weight_data = 1;
    #4;
    weight_idx = 6;
    weight_data = 1;
    #4;
    weight_valid = 0;
    #8
    input_valid = 1;
    #32
    rst = 1;
    weight_idx = 0;
    weight_data = 0;
    input_data = 0;
    output_ready = 0;
    input_valid = 0;
    weight_valid = 0;
    #14
    weight_valid = 1;
    #6;
    rst = 0;
//    #4;
    output_ready = 1;
    weight_idx = 0;
    weight_data = 1;
    input_valid = 1;
    #4;
    weight_idx = 1;
    weight_data = 1;
    #4;
    weight_idx = 2;
    weight_data = 1;
    #4;
    weight_idx = 3;
    weight_data = 1;
    #4;
    weight_idx = 4;
    weight_data = 1;
    #4;
    weight_idx = 5;
    weight_data = 1;
    #4;
    weight_idx = 6;
    weight_data = 1;
    #4;
    weight_valid = 0;
//    #8
//    input_valid = 1;
end 

FIR_Filter fir(.clk(clk), .rst(rst), .input_data(input_data), .weight_data(weight_data), .weight_idx(weight_idx), .weight_ready(weight_ready),
            .weight_valid(weight_valid), .input_ready(input_ready), .input_valid(input_valid), .output_ready(output_ready), .output_valid(output_valid), .output_data(output_data));



always 
begin
    clk = ~clk;
    #2;
end 

always@(posedge clk)
begin
    if(input_valid & input_ready)
        input_data <= input_data + 1;
end
    
endmodule

