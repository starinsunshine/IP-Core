module jpeg_dht_std_y_dc
(
     input  [ 15:0]  lookup_input_i
    ,output [  4:0]  lookup_width_o
    ,output [  7:0]  lookup_value_o
);

//-----------------------------------------------------------------
// Y DC Table (standard)
//-----------------------------------------------------------------
reg [7:0] y_dc_value_r;
reg [4:0] y_dc_width_r;

always @ *
begin
    y_dc_value_r = 8'b0;
    y_dc_width_r = 5'b0;

    if (lookup_input_i[15:14] == 2'h0)
    begin
         y_dc_value_r = 8'h00;
         y_dc_width_r = 5'd2;
    end
    else if (lookup_input_i[15:13] == 3'h2)
    begin
         y_dc_value_r = 8'h01;
         y_dc_width_r = 5'd3;
    end
    else if (lookup_input_i[15:13] == 3'h3)
    begin
         y_dc_value_r = 8'h02;
         y_dc_width_r = 5'd3;
    end
    else if (lookup_input_i[15:13] == 3'h4)
    begin
         y_dc_value_r = 8'h03;
         y_dc_width_r = 5'd3;
    end
    else if (lookup_input_i[15:13] == 3'h5)
    begin
         y_dc_value_r = 8'h04;
         y_dc_width_r = 5'd3;
    end
    else if (lookup_input_i[15:13] == 3'h6)
    begin
         y_dc_value_r = 8'h05;
         y_dc_width_r = 5'd3;
    end
    else if (lookup_input_i[15:12] == 4'he)
    begin
         y_dc_value_r = 8'h06;
         y_dc_width_r = 5'd4;
    end
    else if (lookup_input_i[15:11] == 5'h1e)
    begin
         y_dc_value_r = 8'h07;
         y_dc_width_r = 5'd5;
    end
    else if (lookup_input_i[15:10] == 6'h3e)
    begin
         y_dc_value_r = 8'h08;
         y_dc_width_r = 5'd6;
    end
    else if (lookup_input_i[15:9] == 7'h7e)
    begin
         y_dc_value_r = 8'h09;
         y_dc_width_r = 5'd7;
    end
    else if (lookup_input_i[15:8] == 8'hfe)
    begin
         y_dc_value_r = 8'h0a;
         y_dc_width_r = 5'd8;
    end
    else if (lookup_input_i[15:7] == 9'h1fe)
    begin
         y_dc_value_r = 8'h0b;
         y_dc_width_r = 5'd9;
    end
end

assign lookup_width_o = y_dc_width_r;
assign lookup_value_o = y_dc_value_r;

endmodule