module axi_wrap_ram_sp_ext (
    input         aclk,
    input         aresetn,
    //ar
    input  [4 :0] axi_arid   ,
    input  [31:0] axi_araddr ,
    input  [7 :0] axi_arlen  ,
    input  [2 :0] axi_arsize ,
    input  [1 :0] axi_arburst,
    input         axi_arlock ,
    input  [3 :0] axi_arcache,
    input  [2 :0] axi_arprot ,
    input         axi_arvalid,
    output        axi_arready,
    //r
    output [4 :0] axi_rid    ,
    output [31:0] axi_rdata  ,
    output [1 :0] axi_rresp  ,
    output        axi_rlast  ,
    output        axi_rvalid ,
    input         axi_rready ,
    //aw
    input  [4 :0] axi_awid   ,
    input  [31:0] axi_awaddr ,
    input  [7 :0] axi_awlen  ,
    input  [2 :0] axi_awsize ,
    input  [1 :0] axi_awburst,
    input         axi_awlock ,
    input  [3 :0] axi_awcache,
    input  [2 :0] axi_awprot ,
    input         axi_awvalid,
    output        axi_awready,
    //w
    input  [31:0] axi_wdata  ,
    input  [3 :0] axi_wstrb  ,
    input         axi_wlast  ,
    input         axi_wvalid ,
    output        axi_wready ,
    //b
    output [4 :0] axi_bid    ,
    output [1 :0] axi_bresp  ,
    output        axi_bvalid ,
    input         axi_bready ,

    //BaseRAM信号
    input  [31:0] base_ram_data_i,
    output [31:0] base_ram_data_o,
    output [31:0] base_ram_data_oe,//0:output 1:input
    output [19:0] base_ram_addr, //BaseRAM地址
    output [ 3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  base_ram_ce_n,       //BaseRAM片选，低有效
    output  base_ram_oe_n,       //BaseRAM读使能，低有效
    output  base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    input  [31:0] ext_ram_data_i,
    output [31:0] ext_ram_data_o,
    output [31:0] ext_ram_data_oe,
    output [19:0] ext_ram_addr, //ExtRAM地址
    output [ 3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  ext_ram_ce_n,       //ExtRAM片选，低有效
    output  ext_ram_oe_n,       //ExtRAM读使能，低有效
    output  ext_ram_we_n,       //ExtRAM写使能，低有效

    // 新增视频接口
    output [2:0]    video_red,
    output [2:0]    video_green,
    output [1:0]    video_blue,
    output          video_hsync,
    output          video_vsync,
    output          video_clk,
    output          video_de
);


//ram axi
//ar
wire [4 :0] ram_arid   ;
wire [31:0] ram_araddr ;
wire [7 :0] ram_arlen  ;
wire [2 :0] ram_arsize ;
wire [1 :0] ram_arburst;
wire        ram_arlock ;
wire [3 :0] ram_arcache;
wire [2 :0] ram_arprot ;
wire        ram_arvalid;
wire        ram_arready;
//r
wire [4 :0] ram_rid    ;
wire [31:0] ram_rdata  ;
wire [1 :0] ram_rresp  ;
wire        ram_rlast  ;
wire        ram_rvalid ;
wire        ram_rready ;
//aw
wire [4 :0] ram_awid   ;
wire [31:0] ram_awaddr ;
wire [7 :0] ram_awlen  ;
wire [2 :0] ram_awsize ;
wire [1 :0] ram_awburst;
wire        ram_awlock ;
wire [3 :0] ram_awcache;
wire [2 :0] ram_awprot ;
wire        ram_awvalid;
wire        ram_awready;
//w
wire [31:0] ram_wdata  ;
wire [3 :0] ram_wstrb  ;
wire        ram_wlast  ;
wire        ram_wvalid ;
wire        ram_wready ;
//b
wire [4 :0] ram_bid    ;
wire [1 :0] ram_bresp  ;
wire        ram_bvalid ;
wire        ram_bready ;

//sram signal
wire  [31:0]    soc_sram_addr;
wire            soc_sram_cs;
wire            soc_sram_we;
wire  [3:0]     soc_sram_be;
wire  [31:0]    soc_sram_wdata;
wire  [31:0]    soc_sram_rdata;

//ar
assign ram_arid    = axi_arid   ;
assign ram_araddr  = axi_araddr ;
assign ram_arlen   = axi_arlen  ;
assign ram_arsize  = axi_arsize ;
assign ram_arburst = axi_arburst;
assign ram_arlock  = axi_arlock ;
assign ram_arcache = axi_arcache;
assign ram_arprot  = axi_arprot ;
assign ram_arvalid = axi_arvalid;
assign axi_arready = ram_arready;
//r
assign axi_rid    = axi_rvalid ? ram_rid   :  5'd0 ;
assign axi_rdata  = axi_rvalid ? ram_rdata : 32'd0 ;
assign axi_rresp  = axi_rvalid ? ram_rresp :  2'd0 ;
assign axi_rlast  = axi_rvalid ? ram_rlast :  1'd0 ;
assign axi_rvalid = ram_rvalid;
assign ram_rready = axi_rready;
//aw
assign ram_awid    = axi_awid   ;
assign ram_awaddr  = axi_awaddr ;
assign ram_awlen   = axi_awlen  ;
assign ram_awsize  = axi_awsize ;
assign ram_awburst = axi_awburst;
assign ram_awlock  = axi_awlock ;
assign ram_awcache = axi_awcache;
assign ram_awprot  = axi_awprot ;
assign ram_awvalid = axi_awvalid;
assign axi_awready = ram_awready;
//w
assign ram_wdata  = axi_wdata  ;
assign ram_wstrb  = axi_wstrb  ;
assign ram_wlast  = axi_wlast  ;
assign ram_wvalid = axi_wvalid ;
assign axi_wready = ram_wready ;
//b
assign axi_bid    = axi_bvalid ? ram_bid   : 5'd0 ;
assign axi_bresp  = axi_bvalid ? ram_bresp : 2'd0 ;
assign axi_bvalid = ram_bvalid ;
assign ram_bready = axi_bready ;


axi2sram_sp_ext #(
    .AXI_ID_WIDTH   ( 5  ),
    .AXI_ADDR_WIDTH ( 32 ),
    .AXI_DATA_WIDTH ( 32 ))
 u_axi_sram_sp (
    .clk                     ( aclk         ),
    .resetn                  ( aresetn      ),

    .s_araddr                ( ram_araddr    ),
    .s_arburst               ( ram_arburst   ),
    .s_arcache               ( ram_arcache   ),
    .s_arid                  ( ram_arid      ),
    .s_arlen                 ( ram_arlen     ),
    .s_arlock                ( ram_arlock    ),
    .s_arprot                ( ram_arprot    ),
    .s_arsize                ( ram_arsize    ),
    .s_arvalid               ( ram_arvalid   ),
    .s_awaddr                ( ram_awaddr    ),
    .s_awburst               ( ram_awburst   ),
    .s_awcache               ( ram_awcache   ),
    .s_awid                  ( ram_awid      ),
    .s_awlen                 ( ram_awlen     ),
    .s_awlock                ( ram_awlock    ),
    .s_awprot                ( ram_awprot    ),
    .s_awsize                ( ram_awsize    ),
    .s_awvalid               ( ram_awvalid   ),
    .s_bready                ( ram_bready    ),
    .s_rready                ( ram_rready    ),
    .s_wdata                 ( ram_wdata     ),
    .s_wlast                 ( ram_wlast     ),
    .s_wstrb                 ( ram_wstrb     ),
    .s_wvalid                ( ram_wvalid    ),
    .s_arready               ( ram_arready   ),
    .s_awready               ( ram_awready   ),
    .s_bid                   ( ram_bid       ),
    .s_bresp                 ( ram_bresp     ),
    .s_bvalid                ( ram_bvalid    ),
    .s_rdata                 ( ram_rdata     ),
    .s_rid                   ( ram_rid       ),
    .s_rlast                 ( ram_rlast     ),
    .s_rresp                 ( ram_rresp     ),
    .s_rvalid                ( ram_rvalid    ),
    .s_wready                ( ram_wready    ),

    .req_o                   ( soc_sram_cs       ),
    .we_o                    ( soc_sram_we       ),
    .addr_o                  ( soc_sram_addr     ),
    .be_o                    ( soc_sram_be       ),
    .data_o                  ( soc_sram_wdata    ),
    .data_i                  ( soc_sram_rdata    )
);


//-----------------------------------------------------
// 新增VGA接口信号
wire        vga_clk_25m;    // 25MHz像素时钟
wire [19:0] vga_addr;       // VGA地址总线
wire [31:0] vga_data;       // VGA读取数据

// 仲裁逻辑
wire vga_rd_req     = video_de;  // VGA在有效区域请�?

reg  arb_grant_axi;
wire arb_grant_vga = ~arb_grant_axi;

// 状态定义
localparam IDLE   = 1'b0;
localparam ACTIVE = 1'b1;
reg state;

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        arb_grant_axi <= 1'b0;
        state         <= IDLE;
    end else begin
        case (state)
            IDLE: begin
                // 检测到写请求且需要访问ExtRAM
                // if (axi_ext_ram_req && ram_awvalid) begin
                if (axi_ext_ram_req) begin
                // if (axi_ext_ram_req && soc_sram_we) begin   不对
                    arb_grant_axi <= 1'b1;    // 授权给AXI
                    state         <= ACTIVE;  // 进入传输状态
                end
            end
            ACTIVE: begin
                // 等待AXI传输完成（最后一个数据包 + B响应）
                // if (ram_wlast && ram_wvalid && ram_wready) begin
                if (ram_wlast && ram_bvalid && ram_bready) begin
                    arb_grant_axi <= 1'b0;    // 释放授权
                    state         <= IDLE;
                end
            end
        endcase
    end
end

wire axi_ext_ram_req = choose_sram & soc_sram_cs;
// ExtRAM接口复用
assign ext_ram_addr = arb_grant_axi ? soc_sram_addr[21:2] : vga_addr;
assign ext_ram_data_o = (arb_grant_axi && soc_sram_we) ? soc_sram_wdata : 32'hzzzzzzzz;
assign ext_ram_ce_n = ~(arb_grant_axi | arb_grant_vga);
// assign ext_ram_oe_n = arb_grant_axi ? ~soc_sram_we : 1'b0;
//4-29 改
assign ext_ram_oe_n = arb_grant_axi ? ~ext_ram_we_n : 1'b0;
assign ext_ram_we_n = ~(arb_grant_axi && soc_sram_we);
assign ext_ram_be_n = arb_grant_axi ? ~soc_sram_be : 4'b0000;

// VGA数据同步
reg [31:0] vga_data_sync;
always @(posedge vga_clk_25m) begin
    vga_data_sync <= ext_ram_data_i;
end
assign vga_data = vga_data_sync;

// 实例化PLL生成像素时钟
vga_pll vga_pll (
    .clk_in1 (aclk),       // 输入时钟50MHz
    .clk_out1(vga_clk_25m),// 输出25.175MHz
    .resetn  (aresetn)
);

// 实例化VGA模块
dvi_a_vga u_vga (
    .vga_clk     (vga_clk_25m),
    .resetn      (aresetn),
    .vram_data   (vga_data),
    .vram_addr   (vga_addr),
    .video_hsync (video_hsync),
    .video_vsync (video_vsync),
    .video_de    (video_de),
    .video_red   (video_red),
    .video_green (video_green),
    .video_blue  (video_blue),
    .video_clk   (video_clk)
);
//-------------------------------------------------------









wire choose_sram = soc_sram_addr[22];//1:ExtRAM 0:BaseRAM
wire [3:0] be_out = soc_sram_we ? soc_sram_be : 4'b1111;

assign base_ram_addr = soc_sram_addr[21:2];
assign base_ram_be_n = choose_sram ? 4'b1111 : ~be_out;
assign base_ram_ce_n = ~(soc_sram_cs & (~choose_sram));
assign base_ram_oe_n = soc_sram_we | choose_sram;
assign base_ram_we_n = ~(soc_sram_we & (~choose_sram));
assign base_ram_data_oe = {32{~((~choose_sram) & soc_sram_cs & soc_sram_we)}};
assign base_ram_data_o  = soc_sram_wdata;

// assign ext_ram_addr = soc_sram_addr[21:2];
// assign ext_ram_be_n = choose_sram ? ~be_out : 4'b1111;
// assign ext_ram_ce_n = choose_sram ? ~soc_sram_cs : 1'b1;
// assign ext_ram_oe_n = choose_sram ? soc_sram_we : 1'b1;
// assign ext_ram_we_n = choose_sram ? ~soc_sram_we : 1'b1;
assign ext_ram_data_oe = {32{~((choose_sram) & soc_sram_cs & soc_sram_we)}};
// assign ext_ram_data_o  = soc_sram_wdata;

// assign soc_sram_rdata = choose_sram ? ext_ram_data_i : base_ram_data_i;
assign soc_sram_rdata = choose_sram ? ext_ram_data_o : base_ram_data_i;

endmodule
