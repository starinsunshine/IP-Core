module my_int_ctrl_one(
    input clk,
    input resetn,

    input int_in,
    input int_en,

    input int_edge,
    input int_pol,
    input int_clr,


    output int_state
); 

    // assign int_state = int_en & int_in;
    // 边沿检测寄存器
    reg int_in_prev;
    always @(posedge clk) begin
        if (!resetn) int_in_prev <= 1'b0;
        else int_in_prev <= int_in;
    end

    // 中断检测逻辑
    wire edge_trigger = int_edge & (
        int_pol ? (int_in & ~int_in_prev) :  // 上升沿
                 (~int_in & int_in_prev)     // 下降沿
    );
    
    wire level_trigger = ~int_edge & (
        int_pol ? int_in :       // 高电平触发
                 ~int_in         // 低电平触发
    );

    // 中断信号产生
    reg state;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= 1'b0;
        end else if (int_en) begin
                // 边沿触发模式
                if(int_edge) begin
                    if (edge_trigger)        state <= 1'b1;
                    else if (int_clr)       state <= 1'b0;
                end
                // 电平触发模式
                else begin
                    if (level_trigger)      state <= 1'b1;
                    else                   state <= 1'b0;
                end
        end else begin
            state <= 1'b0;  // 中断未使能
        end
    end

    assign int_state = state;


endmodule


module my_int_ctrl #(parameter N = 5) (
    input sys_clk,
    input sys_resetn,
    input cpu_clk,
    input cpu_resetn,

    input [N-1:0] int_in,
    input [N-1:0] int_en,
    input [N-1:0] int_edge,
    input [N-1:0] int_pol,
    input [N-1:0] int_clr,

    output [N-1:0] int_state,
    output int_out
);

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            my_int_ctrl_one u_my_int_ctrl_one (
                .clk        ( sys_clk        ),
                .resetn     ( sys_resetn     ),
                .int_in     ( int_in[i]  ),
                .int_en     ( int_en[i]  ),
                .int_edge   ( int_edge[i]  ),
                .int_pol    ( int_pol[i]    ),
                .int_clr    ( int_clr[i]    ),
                .int_state  ( int_state[i] )
            );
        end
    endgenerate

    reg int_valid;
    always @(posedge sys_clk or negedge sys_resetn) begin 
        if(~sys_resetn)begin
            int_valid <= 1'b0;
        end
        else begin
            int_valid <= | int_state;
        end 
    end

    //CDC
    reg [1:0] int_valid_r;
    always @(posedge cpu_clk or negedge cpu_resetn) begin 
        if(~cpu_resetn)begin
            int_valid_r <= 2'b00;
        end
        else begin
            int_valid_r <= {int_valid_r[0],int_valid};
        end 
    end
    assign int_out = int_valid_r[1];

endmodule