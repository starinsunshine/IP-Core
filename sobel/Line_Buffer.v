`timescale 1ns / 1ps

module Line_Buffer (

input  Clk,
input  rst,
input  data_valid_in,
input  rd_data_in,
input  [7:0] data_in,
output  [23:0] data_out

);

// Declare internal signals 
reg [7:0] line_B [127:0];    
reg [6:0] wrPntr = 7'd0;     
reg [6:0] rdPntr = 7'd0;

 
// Generate data_out based on read pointer
assign data_out = (rdPntr <= 125) ? 
    {line_B[rdPntr], line_B[rdPntr+1], line_B[rdPntr+2]} :
    (rdPntr == 126) ? {line_B[126], line_B[127], line_B[0]} :
    {line_B[127], line_B[0], line_B[1]};
    
// Write data to the line buffer when data_valid_in is high
always @(posedge Clk) begin
if (data_valid_in) begin
line_B[wrPntr] <= data_in;  // Write data to the line buffer
end
end

// Increment write pointer
always @(posedge Clk) begin
if (rst) begin
    wrPntr <= 7'd0;
end
else if (data_valid_in) begin
    if (wrPntr == 7'd127) begin 
        wrPntr <= 7'd0;
    end else begin
        wrPntr <= wrPntr + 1;
    end
end
end

// Increment read pointer
always @(posedge Clk) begin
if (rst) begin
    rdPntr <= 7'd0;
end
else if (rd_data_in) begin
    if (rdPntr == 7'd127) begin  
        rdPntr <= 7'd0;
    end else begin
        rdPntr <= rdPntr + 1;
    end
end
end

endmodule
