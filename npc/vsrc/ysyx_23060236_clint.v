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
	reg  idle;
	reg  high_data;
	
	assign rdata = high_data ? mtime[63:32] : mtime[31:0];
	assign rresp = 0;
	assign arready = idle;
	assign rvalid = ~idle;

	always @(posedge clock) begin
		if (reset) idle <= 1;
		else idle <= idle & ~arvalid | ~idle & rready;
	end

	always @(posedge clock) begin
		if (arvalid & arready) high_data <= araddr[2];
	end

	ysyx_23060236_Reg #(64, 0) reg_mtime(
		.clock(clock),
		.reset(reset),
		.din(mtime + 1),
		.dout(mtime),
		.wen(1)
	);

endmodule
