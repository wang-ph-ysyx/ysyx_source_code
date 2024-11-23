module vga(
  input         clock,
  input         reset,

  output [7:0]  vga_r,
  output [7:0]  vga_g,
  output [7:0]  vga_b,
  output        vga_hsync,
  output        vga_vsync,
  output        vga_valid
);

	parameter h_frontporch = 96;
	parameter h_active = 144;
	parameter h_backporch = 784;
	parameter h_total = 800;
	
	parameter v_frontporch = 2;
	parameter v_active = 35;
	parameter v_backporch = 515;
	parameter v_total = 525;

	reg [23:0] vmem [307199:0];
	
	reg [9:0] x_cnt;
	reg [9:0] y_cnt;
	wire [23:0] vga_data;
	wire [9:0] v_addr;
	wire [9:0] h_addr;
	wire h_valid;
	wire v_valid;
	wire addr_valid = (in_paddr >= 32'h21000000) & (in_paddr < 32'h21200000);

	//写入缓存
	always @(posedge clock) begin
		if (in_psel & in_penable & in_pwrite & addr_valid) begin
			vmem[in_paddr[20:2]] <= in_pwdata[23:0];
		end
	end
	
	//计算画面更新位置
	always @(posedge clock) begin
			if(reset) begin
					x_cnt <= 1;
					y_cnt <= 1;
			end
			else begin
					if(x_cnt == h_total)begin
							x_cnt <= 1;
							if(y_cnt == v_total) y_cnt <= 1;
							else y_cnt <= y_cnt + 1;
					end
					else x_cnt <= x_cnt + 1;
			end
	end

	//生成同步信号    
	assign vga_hsync = (x_cnt > h_frontporch);
	assign vga_vsync = (y_cnt > v_frontporch);
	//生成消隐信号
	assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
	assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
	assign vga_valid = h_valid & v_valid;
	//计算当前有效像素坐标
	assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
	assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;
	//设置输出的颜色值
	assign {vga_r, vga_g, vga_b} = vga_data;
	assign vga_data = vmem[v_addr*640 + h_addr];

endmodule
