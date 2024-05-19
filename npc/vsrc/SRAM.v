module sram(
	input clk,
	input reset,

	input [31:0] araddr,
	input arvalid,
	output arready,

	output [31:0] rdata,
	output [1:0] rresp,
	output rvalid,
	input  rready,

	input [31:0] awaddr,
	input awvalid,
	output awready,

	input [31:0] wdata,
	input [3:0] wstrb,
	input wvalid,
	output wready,

	output reg [1:0] bresp,
	output bvalid,
	input bready
);

	Reg #(32, 0) reg_rdata(
		.clk(clk),
		.rst(reset),
		.din(pmem_read(araddr)),
		.dout(rdata),
		.wen(arvalid & arready)
	);

	Reg #(2, 0) reg_rresp(
		.clk(clk),
		.rst(reset),
		.din(0),
		.dout(rresp),
		.wen(arvalid & arready)
	);

	Reg #(1, 0) reg_rvalid(
		.clk(clk),
		.rst(reset),
		.din(arvalid & arready | rvalid & ~rready),
		.dout(rvalid),
		.wen(1)
	);

	assign arready = ~rvalid;

	Reg #(1, 1) reg_awready(
		.clk(clk),
		.rst(reset),
		.din(bvalid & bready | awready & ~awvalid),
		.dout(awready),
		.wen(1)
	);

	reg [31:0] stored_awaddr;
	Reg #(32, 0) reg_awaddr(
		.clk(clk),
		.rst(reset),
		.din(awaddr),
		.dout(stored_awaddr),
		.wen(awvalid & awready)
	);

	Reg #(1, 1) reg_wready(
		.clk(clk),
		.rst(reset),
		.din(bvalid & bready | wready & ~wvalid),
		.dout(wready),
		.wen(1)
	);

	reg [31:0] stored_wdata;
	Reg #(32, 0) reg_wdata(
		.clk(clk),
		.rst(reset),
		.din(wdata),
		.dout(stored_wdata),
		.wen(wvalid & wready)
	);

	reg [3:0] stored_wstrb;
	Reg #(4, 0) reg_wstrb(
		.clk(clk),
		.rst(reset),
		.din(wstrb),
		.dout(stored_wstrb),
		.wen(wvalid & wready)
	);

	assign bvalid = ~awready & ~wready;

	always @(bvalid) begin
		if (~reset & bvalid) begin
			pmem_write(stored_awaddr, stored_wdata, {4'b0, stored_wstrb});
			bresp <= 0;
		end
	end
endmodule
