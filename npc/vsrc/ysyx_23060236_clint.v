module ysyx_23060236_clint(
	input  clock,
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
	reg  idle;
	
	assign data_out = araddr[2] ? mtime[63:32] : mtime[31:0];
	assign rresp = 0;
	assign arready = idle;
	assign rvalid = ~idle;

	ysyx_23060236_Reg #(1, 1) reg_idle(
		.clock(clock),
		.reset(reset),
		.din(idle & ~arvalid | ~idle & rready),
		.dout(idle),
		.wen(1)
	);

	ysyx_23060236_Reg #(64, 0) reg_mtime(
		.clock(clock),
		.reset(reset),
		.din(mtime + 1),
		.dout(mtime),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_rdata(
		.clock(clock),
		.reset(reset),
		.din(data_out),
		.dout(rdata),
		.wen(arvalid & arready)
	);

endmodule
