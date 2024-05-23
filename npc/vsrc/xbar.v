module xbar(
	input  clk,
	input  reset,

	input  [31:0] ifu_araddr,
	input  ifu_arvalid,
	output ifu_arready,

	output [31:0] ifu_rdata,
	output [1:0]  ifu_rresp,
	output ifu_rvalid,
	input  ifu_rready,
	
	input  [31:0] lsu_araddr,
	input  lsu_arvalid,
	output lsu_arready,

	output [31:0] lsu_rdata,
	output [1:0]  lsu_rresp,
	output lsu_rvalid,
	input  lsu_rready,

	input  [31:0] lsu_awaddr,
	input  lsu_awvalid,
	output lsu_awready,

	input  [31:0] lsu_wdata,
	input  [3:0]  lsu_wstrb,
	input  lsu_wvalid,
	output lsu_wready,

	output [1:0]  lsu_bresp,
	output lsu_bvalid,
	input  lsu_bready,


	output [31:0] araddr,
	output arvalid,
	input  arready,

	input  [31:0] rdata,
	input  [1:0]  rresp,
	input  rvalid,
	output rready,

	output [31:0] awaddr,
	output awvalid,
	input  awready,

	output [31:0] wdata,
	output [3:0]  wstrb,
	output wvalid,
	input  wready,

	input  [1:0]  bresp,
	input  bvalid,
	output bready
);

	wire ifu_reading, lsu_reading;

	Reg #(1, 0) state_ifu_reading(
		.clk(clk),
		.rst(reset),
		.din(~ifu_reading & ~lsu_reading & ifu_arvalid | ifu_reading & ~(ifu_rvalid & ifu_rready)),
		.dout(ifu_reading),
		.wen(1)
	);

	Reg #(1, 0) state_lsu_reading(
		.clk(clk),
		.rst(reset),
		.din(~lsu_reading & ~ifu_arvalid & ~ifu_reading & lsu_arvalid | lsu_reading & ~(lsu_rvalid & lsu_rready)),
		.dout(lsu_reading),
		.wen(1)
	);

	assign araddr      = {32{ifu_reading}} & ifu_araddr | {32{lsu_reading}} & lsu_araddr;
	assign arvalid     = ifu_reading & ifu_arvalid | lsu_reading & lsu_arvalid;
	assign ifu_arready = ifu_reading & arready;
	assign lsu_arready = lsu_reading & arready;

	assign ifu_rdata   = {32{ifu_reading}} & rdata;
	assign lsu_rdata   = {32{lsu_reading}} & rdata;
	assign ifu_rvalid  = ifu_reading & rvalid;
	assign lsu_rvalid  = lsu_reading & rvalid;
	assign ifu_rresp   = {2{ifu_reading}} & rresp;
	assign lsu_rresp   = {2{lsu_reading}} & rresp;
	assign rready      = ifu_reading & ifu_rready | lsu_reading & lsu_rready;

	assign awaddr      = lsu_awaddr;
	assign awvalid     = lsu_awvalid;
	assign lsu_awready = awready;

	assign wdata       = lsu_wdata;
	assign wstrb       = lsu_wstrb;
	assign wvalid      = lsu_wvalid;
	assign lsu_wready  = wready;

	assign lsu_bresp   = bresp;
	assign lsu_bvalid  = bvalid;
	assign bready      = lsu_bready;

endmodule
