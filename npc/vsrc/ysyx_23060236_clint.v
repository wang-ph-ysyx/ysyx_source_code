`include "ysyx_23060236_defines.v"
module ysyx_23060236_clint(
	input  clock,
	input  reset,

	input  [31:0] araddr,
	input  arvalid,
	output arready,

	output [31:0] rdata,
	output [1:0]  rresp,
	output rvalid,
	input  rready,

	input  handle_intr,
	output reg time_intr
);

	wire [63:0] mtime;
	wire idle;
	reg  high_data;
	
	assign rdata = high_data ? mtime[63:32] : mtime[31:0];
	assign rresp = 0;
	assign arready = idle;
	assign rvalid = ~idle;

	always @(posedge clock) begin
		if (arvalid & arready) high_data <= araddr[2];
	end

	always @(posedge clock) begin
		if (reset) time_intr <= 0;
		else if (mtime[21:0] == 22'h2fffff) time_intr <= 1'b1;
		else if (handle_intr) time_intr <= 1'b0;
	end

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

endmodule
