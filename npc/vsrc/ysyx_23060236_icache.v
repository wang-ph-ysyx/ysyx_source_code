module ysyx_23060236_icache(
	input         clock,
	input         reset,

	input  [31:0] icache_araddr,
	input         icache_arvalid,
	output        icache_arready,

	output [31:0] icache_rdata,
	output [1:0]  icache_rresp,
	output        icache_rvalid,
	input         icache_rready,

	input  [31:0] icache_awaddr,
	input         icache_awvalid,
	output        icache_awready,

	input  [31:0] icache_wdata,
	input  [7:0]  icache_wstrb,
	input         icache_wvalid,
	output        icache_wready,

	output [1:0]  icache_bresp,
	output        icache_bvalid,
	input         icache_bready
);

	reg [31:0] icache_data [15:0];
	reg [25:0] icache_tag  [15:0];
	reg [15:0] icache_valid;

	wire hit_icache;
	wire [3:0]  read_index;
	wire [25:0] read_tag;
	wire [3:0]  write_index;
	wire [25:0] write_tag;
	wire awaddr_valid;
	wire wdata_valid;
	wire [31:0] awaddr_reg;
	wire [31:0] wdata_reg;

	assign read_tag = icache_araddr[31:6];
	assign read_index = icache_araddr[5:2];
	assign write_tag = awaddr_reg[31:6];
	assign write_index = awaddr_reg[5:2];
	assign hit_icache = icache_valid[read_index] & (icache_tag[read_index] == read_tag);

	ysyx_23060236_Reg #(1, 1) calculate_icache_arready(
		.clock(clock),
		.reset(reset),
		.din(icache_arready & ~icache_arvalid | ~icache_arready & icache_rvalid & icache_rready),
		.dout(icache_arready),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) calculate_icache_rdata(
		.clock(clock),
		.reset(reset),
		.din(icache_data[read_index]),
		.dout(icache_rdata),
		.wen(icache_arvalid & icache_arready)
	);

	ysyx_23060236_Reg #(2, 0) calculate_icache_rresp(
		.clock(clock),
		.reset(reset),
		.din({~hit_icache, 1'b0}),
		.dout(icache_rresp),
		.wen(icache_arvalid & icache_arready)
	);

	ysyx_23060236_Reg #(1, 0) calculate_icache_rvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_rvalid & ~icache_rready | ~icache_rvalid & icache_arvalid & icache_arready),
		.dout(icache_rvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 1) calculate_icache_awready(
		.clock(clock),
		.reset(reset),
		.din(icache_awready & ~icache_awvalid | ~icache_awready & icache_bvalid & icache_bready),
		.dout(icache_awready),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 1) calculate_icache_wready(
		.clock(clock),
		.reset(reset),
		.din(icache_wready & ~icache_wvalid | ~icache_wready & icache_bvalid & icache_bready),
		.dout(icache_wready),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) calculate_awaddr_reg(
		.clock(clock),
		.reset(reset),
		.din(icache_awaddr),
		.dout(awaddr_reg),
		.wen(icache_awvalid & icache_awready)
	);

	ysyx_23060236_Reg #(32, 0) calculate_wdata_reg(
		.clock(clock),
		.reset(reset),
		.din(icache_wdata),
		.dout(wdata_reg),
		.wen(icache_wvalid & icache_wready)
	);

	ysyx_23060236_Reg #(1, 0) calculate_awaddr_valid(
		.clock(clock),
		.reset(reset),
		.din(awaddr_valid & ~(icache_bvalid & icache_bready) | ~awaddr_valid & icache_awvalid & icache_awready),
		.dout(awaddr_valid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) calculate_wdata_valid(
		.clock(clock),
		.reset(reset),
		.din(wdata_valid & ~(icache_bvalid & icache_bready) | ~wdata_valid & icache_wvalid & icache_wready),
		.dout(awaddr_valid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) calculate_icache_bvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_bvalid & ~icache_bready | ~icache_bvalid & (awaddr_valid & wdata_valid)),
		.dout(icache_bvalid),
		.wen(1)
	);

	assign icache_bresp = 0;

	always @(posedge clock) begin
		if (reset) icache_valid <= 16'b0;
		else if (wdata_valid & awaddr_valid) icache_valid[write_index] <= 1'b1;
	end

	always @(posedge clock) begin
		if (~reset & wdata_valid & awaddr_valid) icache_data[write_index] <= wdata_reg;
	end

	always @(posedge clock) begin
		if (~reset & wdata_valid & awaddr_valid) icache_tag[write_index] <= write_tag;
	end

endmodule
