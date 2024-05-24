module ysyx_23060236_clint(
	input  clk,
	input  reset,

	input  [31:0] araddr,
	input  arvalid,
	output arready,

	output [31:0] rdata,
	output [1:0]  rresp,
	output rvalid,
	input  rready
);

	wire [63:0] mtime;
	wire [31:0] data_out;
	
	assign data_out = {32{araddr == 32'ha0000048}} & mtime[31:0] | {32{araddr == 32'ha000004c}} & mtime[63:32];

	ysyx_23060236_Reg #(64, 0) reg_mtime(
		.clk(clk),
		.rst(reset),
		.din(mtime + 1),
		.dout(mtime),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 1) reg_arready(
		.clk(clk),
		.rst(reset),
		.din(~arready & rvalid & rready | arready & ~arvalid),
		.dout(arready),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_rdata(
		.clk(clk),
		.rst(reset),
		.din(data_out),
		.dout(rdata),
		.wen(arvalid & arready)
	);

	ysyx_23060236_Reg #(2, 0) reg_rresp(
		.clk(clk),
		.rst(reset),
		.din(0),
		.dout(rresp),
		.wen(arvalid & arready)
	);

	ysyx_23060236_Reg #(1, 0) reg_rvalid(
		.clk(clk),
		.rst(reset),
		.din(~rvalid & arvalid & arready | rvalid & ~rready),
		.dout(rvalid),
		.wen(1)
	);

endmodule
