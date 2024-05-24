module ysyx_23060236_xbar(
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


	output [31:0] sram_araddr,
	output sram_arvalid,
	input  sram_arready,

	input  [31:0] sram_rdata,
	input  [1:0]  sram_rresp,
	input  sram_rvalid,
	output sram_rready,

	output [31:0] sram_awaddr,
	output sram_awvalid,
	input  sram_awready,

	output [31:0] sram_wdata,
	output [3:0]  sram_wstrb,
	output sram_wvalid,
	input  sram_wready,

	input  [1:0]  sram_bresp,
	input  sram_bvalid,
	output sram_bready,

	output [31:0] uart_awaddr,
	output uart_awvalid,
	input  uart_awready,

	output [31:0] uart_wdata,
	output [3:0]  uart_wstrb,
	output uart_wvalid,
	input  uart_wready,

	input  [1:0]  uart_bresp,
	input  uart_bvalid,
	output uart_bready,

	output [31:0] clint_araddr,
	output clint_arvalid,
	input  clint_arready,

	input  [31:0] clint_rdata,
	input  [1:0]  clint_rresp,
	input  clint_rvalid,
	output clint_rready
);

	wire ifu_reading, lsu_reading;
	wire sram_writing, uart_writing;
	wire sram_reading, clint_reading;
	wire [31:0] awaddr;
	wire [31:0] araddr;

	assign sram_writing = (awaddr >= 32'h80000000) & (awaddr <= 32'h87ffffff);
	assign uart_writing = (awaddr == 32'ha00003f8);
	assign sram_reading = (araddr >= 32'h80000000) & (awaddr <= 32'h87ffffff);
	assign clint_reading = (araddr == 32'ha0000048) | (araddr == 32'ha000004c);

	ysyx_23060236_Reg #(1, 0) state_ifu_reading(
		.clk(clk),
		.rst(reset),
		.din(~ifu_reading & ~lsu_reading & ifu_arvalid | ifu_reading & ~(ifu_rvalid & ifu_rready)),
		.dout(ifu_reading),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) state_lsu_reading(
		.clk(clk),
		.rst(reset),
		.din(~lsu_reading & ~ifu_arvalid & ~ifu_reading & lsu_arvalid | lsu_reading & ~(lsu_rvalid & lsu_rready)),
		.dout(lsu_reading),
		.wen(1)
	);

	assign araddr = lsu_araddr;

	assign sram_araddr   = {32{ifu_reading}} & ifu_araddr | {32{lsu_reading}} & {32{sram_reading}} & lsu_araddr;
	assign clint_araddr  = {32{lsu_reading}} & {32{clint_reading}} & lsu_araddr;
	assign sram_arvalid  = ifu_reading & ifu_arvalid | lsu_reading & sram_reading & lsu_arvalid;
	assign clint_arvalid = lsu_reading & clint_reading & lsu_arvalid;
	assign ifu_arready   = ifu_reading & sram_arready;
	assign lsu_arready   = lsu_reading & (sram_reading & sram_arready | clint_reading & clint_arready);

	assign ifu_rdata    = {32{ifu_reading}} & sram_rdata;
	assign lsu_rdata    = {32{lsu_reading}} & ({32{sram_reading}} & sram_rdata | {32{clint_reading}} & clint_rdata);
	assign ifu_rvalid   = ifu_reading & sram_rvalid;
	assign lsu_rvalid   = lsu_reading & (sram_reading & sram_rvalid | clint_reading & clint_rvalid);
	assign ifu_rresp    = {2{ifu_reading}} & sram_rresp;
	assign lsu_rresp    = {2{lsu_reading}} & ({2{sram_reading}} & sram_rresp | {2{clint_reading}} & clint_rresp);
	assign sram_rready  = ifu_reading & ifu_rready | lsu_reading & lsu_rready;
	assign clint_rready = lsu_reading & clint_reading & lsu_rready;

	assign awaddr = lsu_awaddr;

	assign sram_awaddr = {32{sram_writing}} & lsu_awaddr;
	assign uart_awaddr = {32{uart_writing}} & lsu_awaddr;
	assign sram_awvalid= sram_writing & lsu_awvalid;
	assign uart_awvalid= uart_writing & lsu_awvalid;
	assign lsu_awready = sram_writing & sram_awready | uart_wvalid & uart_awready;

	assign sram_wdata  = {32{sram_writing}} & lsu_wdata;
	assign uart_wdata  = {32{uart_writing}} & lsu_wdata;
	assign sram_wstrb  = {4{sram_writing}} & lsu_wstrb;
	assign uart_wstrb  = {4{uart_writing}} & lsu_wstrb;
	assign sram_wvalid = sram_writing & lsu_wvalid;
	assign uart_wvalid = uart_writing & lsu_wvalid;
	assign lsu_wready  = sram_writing & sram_wready | uart_writing & uart_wready;

	assign lsu_bresp   = {2{sram_writing}} & sram_bresp | {2{uart_writing}} & uart_bresp | {2{~sram_writing & ~uart_writing}} & 2'b11;
	assign lsu_bvalid  = sram_writing & sram_bvalid | uart_writing & uart_bvalid;
	assign sram_bready = sram_writing & lsu_bready;
	assign uart_bready = uart_writing & lsu_bready;

endmodule
