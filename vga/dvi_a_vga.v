module dvi_a_vga (
    input         vga_clk,        // 像素时钟 (25MHz)
    input         resetn,         // 异步复位，低有效
    input  [31:0] vram_data,      // 显存输入数据
    output [19:0] vram_addr,      // 显存地址
    output        video_hsync,    // 行同步
    output        video_vsync,    // 场同步
    output        video_de,       // 数据有效
    output [2:0]  video_red,      // R[2:0]
    output [2:0]  video_green,    // G[2:0]
    output [1:0]  video_blue,     // B[1:0]
    output        video_clk       // 像素时钟输出
);

// 时序参数（640x480@60Hz）
parameter H_SYNC   = 10'd96,     // 行同步脉冲
          H_BACK   = 10'd48,     // 行后沿
          H_ACTIVE = 10'd640,    // 行有效
          H_FRONT  = 10'd16,     // 行前沿
          H_TOTAL  = 10'd800;    // 行总计
          
parameter V_SYNC   = 10'd2,      // 场同步脉冲
          V_BACK   = 10'd33,     // 场后沿
          V_ACTIVE = 10'd480,    // 场有效
          V_FRONT  = 10'd10,     // 场前沿
          V_TOTAL  = 10'd525;    // 场总计

// 寄存器声明
reg [9:0] h_cnt;    // 行计数器
reg [9:0] v_cnt;    // 列计数器
reg [19:0] addr_reg;// 地址寄存器

// 时钟输出
assign video_clk = vga_clk;

// 同步计数器控制
always @(posedge vga_clk or negedge resetn) begin
    if (!resetn) begin
        h_cnt <= 10'd0;
        v_cnt <= 10'd0;
    end else begin
        // 行计数器
        h_cnt <= (h_cnt == H_TOTAL-1) ? 10'd0 : h_cnt + 1;
        
        // 场计数器
        if (h_cnt == H_TOTAL-1) begin
            v_cnt <= (v_cnt == V_TOTAL-1) ? 10'd0 : v_cnt + 1;
        end
    end
end

// 同步信号生成
assign video_hsync = (h_cnt < H_SYNC) ? 1'b1 : 1'b0;  // 低电平有效
assign video_vsync = (v_cnt < V_SYNC) ? 1'b1 : 1'b0;   // 低电平有效

// 有效显示区域判断
wire h_valid = (h_cnt >= (H_SYNC + H_BACK)) && 
               (h_cnt <  (H_SYNC + H_BACK + H_ACTIVE));
               
wire v_valid = (v_cnt >= (V_SYNC + V_BACK)) && 
               (v_cnt <  (V_SYNC + V_BACK + V_ACTIVE));

assign video_de = h_valid && v_valid;

// 地址生成逻辑
always @(posedge vga_clk or negedge resetn) begin
    if (!resetn) begin
        addr_reg <= 20'd0;
    end else begin
        if (video_de) begin
            // 行优先地址计算
            if(((v_cnt - V_SYNC - V_BACK)<=256) && ((h_cnt - H_SYNC - H_BACK)<=128))
                addr_reg <= ((v_cnt - V_SYNC - V_BACK) % 256) * 128 + ((h_cnt - H_SYNC - H_BACK) % 128);
            else
                addr_reg <= 20'd0;
        end else begin
            addr_reg <= 20'd0;  // 非有效区域地址清零
        end
    end
end

assign vram_addr = addr_reg;

// 颜色空间转换（32位RGBA8888→8位RGB332）
assign video_red   = vram_data[23:21];  // 取R高3位
assign video_green = vram_data[15:13];  // 取G高3位
assign video_blue  = vram_data[7:6];    // 取B高2位

endmodule