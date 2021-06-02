# 7-Element Finite-Impulse-Response-Filter

## Purpose
The goal is to design a fast 7-element finite-impulse-response(FIR) filter. The FIR output is found every clock cycle by performing 1-D convolution on a continuous stream of data and an adjustable filter.

## Specific Design Goals
* The stream of incoming data and filter hold seven 8-bit elements.
* The 1-D convolution result is 16-bits. Overflow is ignored.
* Ready and valid signals are used to communicate between modules.
* A pipelined architecture is used to increase the operating frequency. Stage 1 will update the input/filter, and the following stages will calculate the output.

## Detailed Description
The FIR consists of three parts: updating the input stream, updating the filter, and calculating the output. The next section has links to detailed block diagrams of the FIR filter.

The input is a continuous stream of 8-bit data handled by using a 7-element FIFO. On each rising clock edge, if there is new data, every element inside the FIFO is shifted left by 1. After shifting, the newly received data is placed at the 0th position inside the FIFO. If there isn’t new data, then the FIFO is untouched.

Like the FIFO, the filter is 7-elements wide, and each element is 8 bits. I will refer to each element inside the filter as a weight. On each rising clock edge, if there is an incoming weight, then the new weight is placed inside the filter. Another signal called weight_idx determines the position of the new weight inside the filter. 

1-D convolution is performed in 3 separate stages to calculate the output. The 1st stage multiplies element i of the filter with element i of the FIFO collecting the input stream. The 4 products are stored in registers called add_results_s1.The 2nd stage adds the products of stage 1 in pairs. The two results are stored in add_results_s2. The final stage, stage 3, sets the output to the sum of both results found in stage 2.

## Block Diagram Links
* FIR Block Diagram: https://docs.google.com/drawings/d/18etfafupazUfJcN8g4o10CzM9l3_K5mCgpO8Z9e3l1o/edit
* Detailed Filter and Input Stream Block Diagram: https://docs.google.com/drawings/d/15v8AtdmGHCrTuUK6cQvjDqJ7pQW6O0H4i25wO9bx9Gg/edit
* Detailed Output Block Diagram: https://docs.google.com/drawings/d/1qreCHda5csYKL2db6tJi-taY_Ww-JLlhz1i-mWeQCD8/edit
