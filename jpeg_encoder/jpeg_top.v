`timescale 1ns / 100ps

module jpeg_top(
input		          clk,
input		          rst,
input                 data_in_valid,
output                data_in_ready,
input                 data_in_user,
input                 data_in_last,
input	[23:0]	      data_in,
output  [31:0]        jpeg_data_bitstream,
output		          jpeg_data_valid,
output	[4:0]         jpeg_data_bitstream_count,
output		          jpeg_data_last
);

 parameter      IMAGE_HIGH     =  128;
 parameter      IMAGE_WIDTH    =  128; 
 parameter      PACK_IPG       =  15;

wire [31:0] JPEG_FF;
wire        data_ready_FF;
wire [4:0]  orc_reg_in;
wire [23:0] jpeg_rgb_data;
wire        jpeg_rgb_data_en,jpeg_rgb_data_last;
wire [31:0] JPEG_bitstream;
wire [4:0]  end_of_file_bitstream_count;
wire        eof_data_partial_ready,data_ready;
reg         jpeg_data_flag;
reg         jpeg_data_rst;
reg  [4:0]  jpeg_data_rst_cnt;


  data_stream #(
      .IMAGE_HIGH(IMAGE_HIGH),
      .IMAGE_WIDTH(IMAGE_WIDTH),
      .PACK_IPG(PACK_IPG)
    ) inst_data_stream (
      .sys_clk            (clk),
      .sys_rst            (rst),
      .data_in_valid      (data_in_valid),
      .data_in_ready      (data_in_ready),
      .data_in_user       (data_in_user),
      .data_in_last       (data_in_last),
      .data_in            (data_in),
      .jpeg_rgb_data      (jpeg_rgb_data),
      .jpeg_rgb_data_en   (jpeg_rgb_data_en),
      .jpeg_rgb_data_last (jpeg_rgb_data_last)
    );



 fifo_out u19 (.clk(clk), .rst(rst|jpeg_data_rst), .enable(jpeg_rgb_data_en), .data_in(jpeg_rgb_data), 
 .JPEG_bitstream(JPEG_FF), .data_ready(data_ready_FF), .orc_reg(orc_reg_in));
 
 ff_checker u20 (.clk(clk), .rst(rst|jpeg_data_rst), 
 .end_of_file_signal(jpeg_rgb_data_last), .JPEG_in(JPEG_FF), 
 .data_ready_in(data_ready_FF), .orc_reg_in(orc_reg_in),
 .JPEG_bitstream_1(JPEG_bitstream), 
 .data_ready_1(data_ready), .orc_reg(end_of_file_bitstream_count),
 .eof_data_partial_ready(eof_data_partial_ready));

  
 always @(posedge clk) begin
   if (rst == 1'b1) begin
     jpeg_data_flag <= 0;   
   end
   else if (eof_data_partial_ready == 1'b1) begin
     jpeg_data_flag <= 0;      	
   end
   else if (data_in_user == 1'b1 && data_in_ready == 1'b1 && data_in_valid == 1'b1) begin
     jpeg_data_flag <= 1;     
   end
  end 

  assign  jpeg_data_bitstream       =  JPEG_bitstream;
  assign  jpeg_data_valid           =  jpeg_data_flag == 1'b1 ? (data_ready | eof_data_partial_ready) : 1'b0;
  assign  jpeg_data_last            =  jpeg_data_flag == 1'b1 ? (eof_data_partial_ready) : 1'b0;
  assign  jpeg_data_bitstream_count =  eof_data_partial_ready ? end_of_file_bitstream_count : 0;

  //下一帧产生复位重置
 always @(posedge clk) begin
   if (rst == 1'b1) begin
    jpeg_data_rst <= 1'b1;
    jpeg_data_rst_cnt <= 0;
   end
   else if (eof_data_partial_ready == 1'b1) begin
    jpeg_data_rst <= 1'b1;
    jpeg_data_rst_cnt <= 0;  
   end
   else if (jpeg_data_rst == 1'b1 && jpeg_data_rst_cnt == 5'd15) begin
    jpeg_data_rst_cnt <= jpeg_data_rst_cnt;
    jpeg_data_rst <= 0;
   end
    else if (jpeg_data_rst == 1'b1) begin
    jpeg_data_rst_cnt <= jpeg_data_rst_cnt + 1'b1;    	
    end    	
  end


 endmodule