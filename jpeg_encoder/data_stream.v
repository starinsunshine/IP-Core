 module data_stream(
  input                 sys_clk,
  input                 sys_rst,  

  input                 data_in_valid,
  output reg            data_in_ready,
  input                 data_in_user,
  input                 data_in_last,
  input	 [23:0]	        data_in,

  output [23:0]         jpeg_rgb_data,
  output reg            jpeg_rgb_data_en,
  output reg            jpeg_rgb_data_last     
 	);

 parameter      IMAGE_HIGH     =  720;
 parameter      IMAGE_WIDTH    =  1280; 
 parameter      PACK_IPG       =  15;

 //register
 reg   [23:0]           image_line_cnt;
 reg                    fifo_wr_en    ;
 reg   [23:0]           fifo_wr_data  ;
 reg                    fifo_wr_last  ;
 reg   [23:0]           image_data_cnt;
 reg   [20:0]           image_data8_cnt;
 reg                    rd_addr_flag;
 reg                    rd_addr_en  ;
 reg                    rd_addr_sel ;
 reg   [23:0]           rd_addr     ;
 reg   [7:0]            rd_addr_64_cnt;
 reg                    rd_addr_64;
 wire  [23:0]           rd_addra  ;
 wire  [23:0]           rd_addrb  ;
 wire  [23:0]           rd_dataa  ;
 wire  [23:0]           rd_datab  ;
 reg   [23:0]           rd_data_cnt;
 reg                    wr_addra_de;
 reg   [23:0]           wr_addra   ;
 reg   [23:0]           wr_dataa   ;
 reg                    wr_addrb_de;
 reg   [23:0]           wr_addrb   ;
 reg   [23:0]           wr_datab   ;
 reg                    wr_addr_sel;


 
 //对行号计数
 always @(posedge sys_clk) begin
  if (sys_rst == 1'b1) begin
    image_line_cnt <= 0;
  end
  else if (data_in_user == 1'b1 && data_in_ready == 1'b1 && data_in_valid == 1'b1) begin
    image_line_cnt <= 0;  	
  end
  else if (fifo_wr_last == 1'b1) begin
    image_line_cnt <= image_line_cnt + 1'b1; 
  end
 end

 //对一行数据计数
 always @(posedge sys_clk) begin
  if (sys_rst == 1'b1) begin
    image_data_cnt <= 24'd0;
  end
  else if (fifo_wr_en == 1'b1 && fifo_wr_last == 1'b1) begin
    image_data_cnt <= 24'd0;  	
  end
  else if (fifo_wr_en == 1'b1) begin
    image_data_cnt <= image_data_cnt + 1'b1; 
  end
 end

 //一行每8个数据进行加1
 always @(posedge sys_clk) begin
  if (sys_rst == 1'b1) begin
   image_data8_cnt <= 0;
  end
  else if (fifo_wr_en == 1'b1 && fifo_wr_last == 1'b1) begin
   image_data8_cnt <= 0; 
  end
  else if (fifo_wr_en == 1'b1 && image_data_cnt[2:0] == 3'b111) begin
   image_data8_cnt <= image_data8_cnt + 1'b1;   	
  end
 end

 //对输入数据进行打拍
 always @(posedge sys_clk) begin
  if (sys_rst == 1'b1) begin
   fifo_wr_en   <= 0;
   fifo_wr_data <= 0;   
  end
  else if (data_in_ready == 1'b1 && data_in_valid == 1'b1) begin
   fifo_wr_en   <= 1;
   fifo_wr_data <= data_in;    
  end
  else begin
   fifo_wr_en   <= 0;  	
  end
 end

 //写入一行地址结束
 always @(posedge sys_clk) begin
  if (sys_rst == 1'b1) begin
  fifo_wr_last <= 0;
  end
  else if (data_in_ready == 1'b1 && data_in_valid == 1'b1 && data_in_last == 1'b1) begin
  fifo_wr_last <= 1; 
  end
  else begin
  fifo_wr_last <= 0;  	
  end
 end

 //允许输入数据
 always @(posedge sys_clk) begin
  if (sys_rst == 1'b1) begin
   data_in_ready <= 1'b1;
  end
  else if ( wr_addra >= (IMAGE_WIDTH*8-8) && rd_addr_flag == 1'b1) begin
   data_in_ready <= 1'b0;
  end
  else if (wr_addrb >= (IMAGE_WIDTH*8-8) && rd_addr_flag == 1'b1) begin
   data_in_ready <= 1'b0;
  end    
  else begin
   data_in_ready <= 1'b1;  	
  end
 end

  //写入内存数据地址使能
  always @(posedge sys_clk) begin
   if (sys_rst == 1'b1) begin
    wr_addra_de <= 1'b0;
    wr_dataa <= 0;    
   end
   else if (fifo_wr_en == 1'b1 && wr_addr_sel == 1'b0) begin
    wr_addra_de <= 1'b1; 
    wr_dataa <= fifo_wr_data;     
   end
   else begin
    wr_addra_de <= 1'b0;   	
   end
  end

  //写入内存数据地址
  always @(posedge sys_clk) begin
   if (sys_rst == 1'b1) begin
     wr_addra <= 0;
   end
   else if (wr_addra_de == 1'b1 && wr_addr_sel == 1'b0 && wr_addra == (IMAGE_WIDTH*8-1)) begin
     wr_addra <= 0;   	
   end   
   else if (wr_addra_de == 1'b1 && wr_addr_sel == 1'b0) begin
     wr_addra <= image_data8_cnt*64 +  image_line_cnt[2:0]*8 + image_data_cnt[2:0] ;     
   end
  end

  //写入内存b数据地址使能
  always @(posedge sys_clk) begin
   if (sys_rst == 1'b1) begin
    wr_addrb_de <= 1'b0;
    wr_datab <= 0;
   end
   else if (fifo_wr_en == 1'b1 && wr_addr_sel == 1'b1) begin
    wr_addrb_de <= 1'b1; 
    wr_datab <= fifo_wr_data; 
   end
   else begin
    wr_addrb_de <= 1'b0;   	
   end
  end

  //写入内存b数据地址
  always @(posedge sys_clk) begin
   if (sys_rst == 1'b1) begin
     wr_addrb <= 0;
   end
   else if (wr_addrb_de == 1'b1 && wr_addr_sel == 1'b1 && wr_addrb == (IMAGE_WIDTH*8-1)) begin
     wr_addrb <= 0;   	
   end
   else if (wr_addrb_de == 1'b1 && wr_addr_sel == 1'b1) begin
     wr_addrb <= image_data8_cnt*64  + image_line_cnt[2:0]*8 + image_data_cnt[2:0] ;     
   end
  end 

  //地址切换
  always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     wr_addr_sel <= 0;
    end
    else if (data_in_user == 1'b1 && data_in_ready == 1'b1 && data_in_valid == 1'b1) begin
     wr_addr_sel <= 0;    	
    end
    else if (wr_addra_de == 1'b1 && wr_addr_sel == 1'b0 && wr_addra == (IMAGE_WIDTH*8-1)) begin
     wr_addr_sel <= 1;     
    end
    else if (wr_addrb_de == 1'b1 && wr_addr_sel == 1'b1 && wr_addrb == (IMAGE_WIDTH*8-1)) begin
     wr_addr_sel <= 0;     
    end    
   end 

 /*********************************读取数据逻辑**********************************************************/
  assign        rd_addra           =  rd_addr_sel == 1'b0 ? rd_addr : 0;
  assign        rd_addrb           =  rd_addr_sel == 1'b1 ? rd_addr : 0;
  assign        jpeg_rgb_data      =  rd_addr_sel == 1'b1 ? rd_datab : rd_dataa;
  
  //读取8行数据过程整个过程
  always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
      rd_addr_flag <= 1'b0;  
    end
    else if (rd_addr_flag == 1'b1 && rd_addr == (IMAGE_WIDTH*8)  && rd_addr_64_cnt == (PACK_IPG+64-1)) begin
      rd_addr_flag <= 1'b0;     	
    end
    else if (wr_addra_de == 1'b1 && wr_addr_sel == 1'b0 && wr_addra == (IMAGE_WIDTH*8-1)) begin
      rd_addr_flag <= 1'b1;  
    end
    else if (wr_addrb_de == 1'b1 && wr_addr_sel == 1'b1 && wr_addrb == (IMAGE_WIDTH*8-1)) begin
      rd_addr_flag <= 1'b1;     	
    end
   end 

   //读取8行数据的ram选择
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     rd_addr_sel <= 1'b0;
    end
    else if (wr_addrb_de == 1'b1 && wr_addr_sel == 1'b1 && wr_addrb == (IMAGE_WIDTH*8-1)) begin
     rd_addr_sel <= 1'b1;   
    end
    else if (wr_addra_de == 1'b1 && wr_addr_sel == 1'b0 && wr_addra == (IMAGE_WIDTH*8-1)) begin
     rd_addr_sel <= 1'b0;    	
    end
   end

   //读取数据使能标志
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     rd_addr_en <= 1'b0;
    end
    else if (rd_addr_flag == 1'b1 && rd_addr_64 == 1'b1) begin
     rd_addr_en <= 1'b1;
    end
    else begin
     rd_addr_en <= 1'b0;    	
    end
   end

   //读取数据地址信号
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
      rd_addr <= 0;
    end
    else if (rd_addr_flag == 1'b1 && rd_addr == (IMAGE_WIDTH*8)  && rd_addr_64_cnt == (PACK_IPG+64-1)) begin
      rd_addr <= 0;    	
    end
    else if (rd_addr_en == 1'b1) begin
      rd_addr <= rd_addr + 1'b1;   
    end
   end
   
   //计数64+PACK_IPG个周期，用于规范8X8数据块的间隔
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     rd_addr_64_cnt <= 0;
    end
    else if (rd_addr_flag == 1'b1 && rd_addr_64_cnt == (PACK_IPG+64-1)) begin
     rd_addr_64_cnt <= 0;     
    end
    else if (rd_addr_flag == 1'b1) begin
     rd_addr_64_cnt <= rd_addr_64_cnt + 1'b1;    	
    end
   end
   
   //数据有效周期为64个时钟
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     rd_addr_64 <= 0;
    end
    else if (rd_addr_flag == 1'b1 && rd_addr_64_cnt == 64) begin
     rd_addr_64 <= 0;    	
    end
    else if (rd_addr_flag == 1'b1 && rd_addr_64_cnt == 0) begin
     rd_addr_64 <= 1;   
    end
   end

   //输出数据有效标志
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     jpeg_rgb_data_en <= 0;
    end
    else if (rd_addr_flag == 1'b1 && rd_addr_64_cnt == (PACK_IPG+64-2)) begin
     jpeg_rgb_data_en <= 0;
    end
    else if(rd_addr_en == 1'b1) begin
     jpeg_rgb_data_en <= 1'b1;
    end
   end

   //统计输出数据个数
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     rd_data_cnt <= 0;
    end
    else if (rd_addr_en == 1'b1 && rd_data_cnt == IMAGE_WIDTH*IMAGE_HIGH-1) begin
     rd_data_cnt <= 0;    	
    end
    else if (rd_addr_en == 1'b1) begin
     rd_data_cnt <= rd_data_cnt + 1'b1;   
    end
   end

   //一帧数据结束标志
   always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
     jpeg_rgb_data_last <= 0;
    end
    else if (rd_addr_flag == 1'b1 && rd_addr_64_cnt == (PACK_IPG+64-1)) begin
     jpeg_rgb_data_last <= 0;    	
    end
    else if (rd_addr_en == 1'b1 && rd_data_cnt == IMAGE_WIDTH*IMAGE_HIGH-1) begin
     jpeg_rgb_data_last <= 1;   
    end
   end

		tdpram #(
			.AW (14 ),
			.DW (24 )  
		)
		u1_tdprama 
		(
		  .clka		(sys_clk		),
		  .wea		(wr_addra_de	),
		  .addra	(wr_addra		),
		  .dina		(wr_dataa		),
		  .douta	(	            ),
		  .clkb		(sys_clk		),
		  .web		(1'b0			),
		  .addrb	(rd_addra		),
		  .dinb		(8'd0			),
		  .doutb	(rd_dataa	    ) 
		);		


		tdpram #(
			.AW (14 ),
			.DW (24 )  
		)
		u1_tdpramb 
		(
		  .clka		(sys_clk	),
		  .wea		(wr_addrb_de),
		  .addra	(wr_addrb	),
		  .dina		(wr_datab   ),
		  .douta	(	        ),
		  .clkb		(sys_clk	),
		  .web		(1'b0		),
		  .addrb	(rd_addrb	),
		  .dinb		(0			),
		  .doutb	(rd_datab	) 
		);	


 //计算地址和读数据使能
 



 endmodule