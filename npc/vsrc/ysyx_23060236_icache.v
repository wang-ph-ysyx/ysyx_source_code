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
	input  [3:0]  icache_wstrb,
	input         icache_wvalid,
	output        icache_wready,

	output [1:0]  icache_bresp,
	output        icache_bvalid,
	input         icache_bready
);

	localparam ADDR_LEN   = 32;
	localparam OFFSET_LEN = 4;
	localparam INDEX_LEN  = 2;
	localparam TAG_LEN    = ADDR_LEN - OFFSET_LEN - INDEX_LEN;
	localparam BLOCK_SIZE = 2**(OFFSET_LEN-2);

	reg [ADDR_LEN-1:0]     icache_data [2**INDEX_LEN-1:0][BLOCK_SIZE-1:0];
	reg [TAG_LEN-1:0]      icache_tag  [2**INDEX_LEN-1:0];
	reg [2**INDEX_LEN-1:0] icache_valid;

	wire hit_icache;
	wire [INDEX_LEN-1:0]  read_index;
	wire [TAG_LEN-1:0]    read_tag;
	wire [OFFSET_LEN-3:0] read_offset;
	wire [INDEX_LEN-1:0]  write_index;
	wire [TAG_LEN-1:0]    write_tag;
	wire [OFFSET_LEN-3:0] write_offset;
	wire [ADDR_LEN-1:0]   awaddr_reg;

	assign read_tag     = icache_araddr[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign read_index   = icache_araddr[OFFSET_LEN+INDEX_LEN-1 : OFFSET_LEN];
	assign read_offset  = icache_araddr[OFFSET_LEN-1 : 2];
	assign write_tag    = awaddr_reg   [ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign write_index  = awaddr_reg   [OFFSET_LEN+INDEX_LEN-1 : OFFSET_LEN];
	assign write_offset = awaddr_reg   [OFFSET_LEN-1 : 2];
	assign hit_icache  = icache_valid[read_index] & (icache_tag[read_index] == read_tag);

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
		.din(icache_data[read_index][read_offset[OFFSET_LEN-3:0]]),
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
		.din(icache_wready & ~icache_wvalid | ~icache_wready & icache_awvalid & icache_awready),
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

	ysyx_23060236_Reg #(1, 0) calculate_icache_bvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_bvalid & ~icache_bready | ~icache_bvalid & (icache_wvalid & icache_wready)),
		.dout(icache_bvalid),
		.wen(1)
	);

	assign icache_bresp = 0;

	always @(posedge clock) begin
		if (reset) icache_valid <= 0;
		else if (icache_wvalid & icache_wready) icache_valid[write_index] <= 1'b1;
	end

	always @(posedge clock) begin
		if (icache_wvalid & icache_wready) icache_data[write_index][write_offset[OFFSET_LEN-3:0]] <= icache_wdata;
	end

	always @(posedge clock) begin
		if (icache_wvalid & icache_wready) icache_tag[write_index] <= write_tag;
	end

endmodule
