module jpeg_idct_transpose_ram
(
    // Inputs
     input           clk0_i
    ,input           rst0_i
    ,input  [  4:0]  addr0_i
    ,input  [ 31:0]  data0_i
    ,input           wr0_i
    ,input           clk1_i
    ,input           rst1_i
    ,input  [  4:0]  addr1_i
    ,input  [ 31:0]  data1_i
    ,input           wr1_i

    // Outputs
    ,output [ 31:0]  data0_o
    ,output [ 31:0]  data1_o
);



//-----------------------------------------------------------------
// Dual Port RAM
// Mode: Read First
//-----------------------------------------------------------------
reg [31:0]   ram [31:0];

reg [31:0] ram_read0_q;
reg [31:0] ram_read1_q;


// Synchronous write
always @ (posedge clk0_i)
begin
    if (wr0_i)
        ram[addr0_i][31:0] <= data0_i[31:0];

    ram_read0_q <= ram[addr0_i];
end

always @ (posedge clk1_i)
begin
    if (wr1_i)
        ram[addr1_i][31:0] <= data1_i[31:0];

    ram_read1_q <= ram[addr1_i];
end


assign data0_o = ram_read0_q;
assign data1_o = ram_read1_q;



endmodule
