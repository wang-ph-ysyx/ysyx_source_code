module ysyx_23060236_clint(
	input  clock,
	input  reset,

	input  [31:0] araddr,
	input  arvalid,
	output reg arready,

	output reg [31:0] rdata,
	output [1:0]  rresp,
	output rvalid,
	input  rready
);

	wire [63:0] mtime;
	wire [31:0] data_out;
	
	assign data_out = araddr[2] ? mtime[63:32] : mtime[31:0];
	assign rresp = 0;

	ysyx_23060236_Reg #(64, 0) reg_mtime(
		.clock(clock),
		.reset(reset),
		.din(mtime + 1),
		.dout(mtime),
		.wen(1)
	);

	always @(posedge clock) begin
		if (reset) arready <= 1;
		else if (arready & arvalid) arready <= 0;
		else if (rready & rvalid) arready <= 1;
	end

	always @(posedge clock) begin
		if (arvalid & arready) rdata <= data_out;
	end

	always @(posedge clock) begin
		if (reset) rvalid <= 0;
		else if (rvalid & rready) rvalid <= 0;
		else if (arvalid & arready) rvalid <= 1;
	end

endmodule
