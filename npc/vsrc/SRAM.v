module sram(
	input clk,
	input reset,

	input [31:0] araddr,
	input arvalid,
	output arready,

	output reg [31:0] rdata,
	output [1:0] rresp,
	output rvalid,
	input  rready,

	input [31:0] awaddr,
	input awvalid,
	output reg awready,

	input [31:0] wdata,
	input [3:0] wstrb,
	input wvalid,
	output wready,

	output reg [1:0] bresp,
	output bvalid,
	input bready,

	input [7:0] random
);

	wire araddr_valid;
	wire awaddr_valid;
	wire wdata_valid;

	always @(posedge clk) begin
		if (reset) begin
			rdata <= 0;
		end
		else if (arvalid & arready) begin
			rdata <= pmem_read(araddr);
		end
	end

	Reg #(2, 0) reg_rresp(
		.clk(clk),
		.rst(reset),
		.din(0),
		.dout(rresp),
		.wen(arvalid & arready)
	);

	Reg #(1, 0) reg_araddr_valid(
		.clk(clk),
		.rst(reset),
		.din(~araddr_valid & arvalid & arready | araddr_valid & ~(rvalid & rready)),
		.dout(araddr_valid),
		.wen(1)
	);

	delay rvalid_delay(
		.clk(clk),
		.reset(reset),
		.data_in(araddr_valid),
		.data_out(rvalid),
		.random(random[3:1])
	);

	Reg #(1, 1) reg_arready(
		.clk(clk),
		.rst(reset),
		.din(~arready & rvalid & rready | arready & ~arvalid),
		.dout(arready),
		.wen(1)
	);

	Reg #(1, 0) reg_awaddr_valid(
		.clk(clk),
		.rst(reset),
		.din(~awaddr_valid & awvalid & awready | awaddr_valid & ~(bvalid & bready)),
		.dout(awaddr_valid),
		.wen(1)
	);

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

	Reg #(1, 0) reg_wdata_valid(
		.clk(clk),
		.rst(reset),
		.din(~wdata_valid & wvalid & wready | wdata_valid & ~(bvalid & bready)),
		.dout(wdata_valid),
		.wen(1)
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

	delay bvalid_delay(
		.clk(clk),
		.reset(reset),
		.data_in(awaddr_valid & wdata_valid),
		.data_out(bvalid),
		.random(random[2:0])
	);

	always @(bvalid) begin
		if (~reset & bvalid) begin
			pmem_write(stored_awaddr, stored_wdata, {4'b0, stored_wstrb});
			bresp <= 0;
		end
	end
endmodule
