module ysyx_23060236_xbar(
	input         clock,
	input         reset,

	input  [31:0] ifu_araddr,
	input         ifu_arvalid,
	output        ifu_arready,

	output [63:0] ifu_rdata,
	output [1:0]  ifu_rresp,
	output        ifu_rvalid,
	input         ifu_rready,

	input  [31:0] lsu_araddr,
	input         lsu_arvalid,
	input  [2:0]  lsu_arsize,
	output        lsu_arready,

	output [63:0] lsu_rdata,
	output [1:0]  lsu_rresp,
	output        lsu_rvalid,
	input         lsu_rready,

	input  [31:0] lsu_awaddr,
	input         lsu_awvalid,
	input  [2:0]  lsu_awsize,
	output        lsu_awready,

	input  [63:0] lsu_wdata,
	input  [7:0]  lsu_wstrb,
	input         lsu_wvalid,
	output        lsu_wready,

	output [1:0]  lsu_bresp,
	output        lsu_bvalid,
	input         lsu_bready,


	input         io_master_awready,
	output        io_master_awvalid,
	output [31:0] io_master_awaddr,
	output [3:0]  io_master_awid,
	output [7:0]  io_master_awlen,
	output [2:0]  io_master_awsize,
	output [1:0]  io_master_awburst,
	
	input         io_master_wready,
	output        io_master_wvalid,
	output [63:0] io_master_wdata,
	output [7:0]  io_master_wstrb,
	output        io_master_wlast,
	
	output        io_master_bready,
	input         io_master_bvalid,
	input  [1:0]  io_master_bresp,
	input  [3:0]  io_master_bid,
	
	input         io_master_arready,
	output        io_master_arvalid,
	output [31:0] io_master_araddr,
	output [3:0]  io_master_arid,
	output [7:0]  io_master_arlen,
	output [2:0]  io_master_arsize,
	output [1:0]  io_master_arburst,
	
	output        io_master_rready,
	input         io_master_rvalid,
	input  [1:0]  io_master_rresp,
	input  [63:0] io_master_rdata,
	input         io_master_rlast,
	input  [3:0]  io_master_rid,


	output [31:0] clint_araddr,
	output        clint_arvalid,
	input         clint_arready,

	input  [31:0] clint_rdata,
	input  [1:0]  clint_rresp,
	input         clint_rvalid,
	output        clint_rready,


	output [31:0] icache_araddr,
	output        icache_arvalid,
	input         icache_arready,

	input  [31:0] icache_rdata,
	input  [1:0]  icache_rresp,
	input         icache_rvalid,
	output        icache_rready,

	output [31:0] icache_awaddr,
	output        icache_awvalid,
	input         icache_awready,

	output [31:0] icache_wdata,
	output [7:0]  icache_wstrb,
	output        icache_wvalid,
	input         icache_wready,

	input  [1:0]  icache_bresp,
	input         icache_bvalid,
	output        icache_bready
);

	localparam STATE_IDLE = 3'd0, STATE_IFU_READING_CACHE = 3'd1, STATE_IFU_READING = 3'd2, STATE_IFU_REPLY = 3'd3, STATE_CACHE_WRITING = 3'd4, STATE_LSU_READING = 3'd5, STATE_LSU_REPLY = 3'd6;

	reg [2:0] state;
	reg [2:0] next_state;

	always @(posedge clock) begin
		if (reset) state <= STATE_IDLE;
		else state <= next_state;
	end

	always @(*) begin
		case (state)
			STATE_IDLE: 
				if (ifu_arvalid) begin
					if (~need_icache) next_state = STATE_IFU_READING;
					else next_state = STATE_IFU_READING_CACHE;
				end
				else if (lsu_arvalid) next_state = STATE_LSU_READING;
				else next_state = STATE_IDLE;
			STATE_IFU_READING_CACHE: 
				if (~(icache_rvalid & icache_rready)) next_state = STATE_IFU_READING_CACHE;
				else if (icache_rresp[1]) next_state = STATE_IFU_READING;
				else next_state = STATE_IFU_REPLY;
			STATE_IFU_READING:
				if (~(io_master_rvalid & io_master_rready)) next_state = STATE_IFU_READING;
				else if (~reg_need_icache) next_state = STATE_IFU_REPLY;
				else next_state = STATE_CACHE_WRITING;
			STATE_IFU_REPLY:
				if (~(ifu_rvalid & ifu_rready)) next_state = STATE_IFU_REPLY;
				else next_state = STATE_IDLE;
			STATE_CACHE_WRITING:
				if (~(icache_bvalid & icache_bready)) next_state = STATE_CACHE_WRITING;
				else next_state = STATE_IFU_REPLY;
			STATE_LSU_READING:
				if (~(io_master_rvalid & io_master_rready) & ~(clint_rvalid & clint_rready)) next_state = STATE_LSU_READING;
				else next_state = STATE_LSU_REPLY;
			STATE_LSU_REPLY:
				if (~(lsu_rvalid & lsu_rready)) next_state = STATE_LSU_REPLY;
				else next_state = STATE_IDLE;
			default: next_state = STATE_IDLE;
		endcase
	end

	wire reg_addr_in_flash = (ifu_addr >= 32'h30000000) & (ifu_addr < 32'h40000000);
	wire reg_addr_in_psram = (ifu_addr >= 32'h80000000) & (ifu_addr < 32'ha0000000);
	wire reg_addr_in_sdram = (ifu_addr >= 32'ha0000000) & (ifu_addr < 32'hc0000000);
	wire addr_in_flash = (ifu_araddr >= 32'h30000000) & (ifu_araddr < 32'h40000000);
	wire addr_in_param = (ifu_araddr >= 32'h80000000) & (ifu_araddr < 32'ha0000000);
	wire addr_in_sdram = (ifu_araddr >= 32'ha0000000) & (ifu_araddr < 32'hc0000000);
	wire reg_need_icache = reg_addr_in_flash | reg_addr_in_psram | reg_addr_in_sdram;
	wire need_icache = addr_in_flash | addr_in_param | addr_in_sdram;
	wire soc_reading, clint_reading;
	wire master_arvalid;
	wire [31:0] araddr;
	wire [31:0] ifu_addr;
	wire [31:0] lsu_addr;
	wire [2:0]  lsu_size;
	wire [63:0] master_rdata_reg;
	wire [63:0] master_rdata;
	wire [1:0]  master_rresp_reg;
	wire [31:0] clint_rdata_reg;
	wire [1:0]  clint_rresp_reg;

	assign soc_reading = ~clint_reading;
	assign clint_reading = (lsu_addr >= 32'h02000000) & (lsu_addr <= 32'h0200ffff);

	ysyx_23060236_Reg #(1, 0) calculate_ifu_arready(
		.clock(clock),
		.reset(reset),
		.din(ifu_arready & ~ifu_arvalid | ~ifu_arready & (state == STATE_IDLE) & ifu_arvalid),
		.dout(ifu_arready),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) calculate_lsu_arready(
		.clock(clock),
		.reset(reset),
		.din(lsu_arready & ~lsu_arvalid | ~lsu_arready & (state == STATE_IDLE) & lsu_arvalid & ~ifu_arvalid),
		.dout(lsu_arready),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) calculate_ifu_addr(
		.clock(clock),
		.reset(reset),
		.din(ifu_araddr),
		.dout(ifu_addr),
		.wen(ifu_arvalid & ifu_arready)
	);

	ysyx_23060236_Reg #(32, 0) calculate_lsu_addr(
		.clock(clock),
		.reset(reset),
		.din(lsu_araddr),
		.dout(lsu_addr),
		.wen(lsu_arvalid & lsu_arready)
	);

	ysyx_23060236_Reg #(3, 0) calculate_lsu_size(
		.clock(clock),
		.reset(reset),
		.din(lsu_arsize),
		.dout(lsu_size),
		.wen(lsu_arvalid & lsu_arready)
	);

	ysyx_23060236_Reg #(1, 0) calculate_icache_arvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_arvalid & ~icache_arready | ~icache_arvalid & ifu_arvalid & ifu_arready & need_icache),
		.dout(icache_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) calculate_icache_awvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_awvalid & ~icache_awready | ~icache_awvalid & (state == STATE_IFU_READING) & io_master_rvalid & io_master_rready & reg_need_icache),
		.dout(icache_awvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) calculate_icache_wdata(
		.clock(clock),
		.reset(reset),
		.din(io_master_rdata[31:0]),
		.dout(icache_wdata),
		.wen((state == STATE_IFU_READING) & io_master_rvalid & io_master_rready)
	);

	ysyx_23060236_Reg #(1, 0) calculate_icache_wvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_wvalid & ~icache_wready | ~icache_wvalid & (state == STATE_IFU_READING) & io_master_rvalid & io_master_rready & reg_need_icache),
		.dout(icache_wvalid),
		.wen(1)
	);

	assign master_rdata  = {64{io_master_rvalid & io_master_rready}} & io_master_rdata | {64{icache_rvalid & icache_rready}} & {32'b0, icache_rdata};
	assign icache_wstrb  = 8'h0f;
	assign icache_araddr = ifu_addr;
	assign icache_awaddr = ifu_addr;
	assign icache_rready = 1;
	assign icache_bready = 1;

	ysyx_23060236_Reg #(1, 0) calculate_master_arvalid(
		.clock(clock),
		.reset(reset),
		.din(io_master_arvalid & ~io_master_arready | ~io_master_arvalid & ((state == STATE_IFU_READING_CACHE) & icache_rvalid & icache_rready & icache_rresp[1] | (state == STATE_LSU_READING) & lsu_arvalid & lsu_arready | (state == STATE_IFU_READING) & ifu_arvalid & ifu_arready)),
		.dout(master_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(64, 0) calculate_master_rdata_reg(
		.clock(clock),
		.reset(reset),
		.din(master_rdata),
		.dout(master_rdata_reg),
		.wen(io_master_rvalid & io_master_rready | icache_rvalid & icache_rready)
	);

	ysyx_23060236_Reg #(2, 0) calculate_master_rresp_reg(
		.clock(clock),
		.reset(reset),
		.din(io_master_rresp),
		.dout(master_rresp_reg),
		.wen(io_master_rvalid & io_master_rready)
	);

	ysyx_23060236_Reg #(32, 0) calculate_clint_rdata_reg(
		.clock(clock),
		.reset(reset),
		.din(clint_rdata),
		.dout(clint_rdata_reg),
		.wen(clint_rvalid & clint_rready)
	);

	ysyx_23060236_Reg #(2, 0) calculate_clint_rresp_reg(
		.clock(clock),
		.reset(reset),
		.din(clint_rresp),
		.dout(clint_rresp_reg),
		.wen(clint_rvalid & clint_rready)
	);

	ysyx_23060236_Reg #(1, 0) calculate_ifu_rvalid(
		.clock(clock),
		.reset(reset),
		.din(ifu_rvalid & ~ifu_rready | ~ifu_rvalid & ((state == STATE_CACHE_WRITING) & icache_bvalid & icache_bready | (state == STATE_IFU_READING_CACHE) & icache_rvalid & icache_rready & ~icache_rresp[1] | (state == STATE_IFU_READING) & io_master_rvalid & io_master_rready & ~reg_need_icache)),
		.dout(ifu_rvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) calculate_lsu_rvalid(
		.clock(clock),
		.reset(reset),
		.din(lsu_rvalid & ~lsu_rready | ~lsu_rvalid & (state == STATE_LSU_READING) & (io_master_rvalid & io_master_rready | clint_rvalid & clint_rready)),
		.dout(lsu_rvalid),
		.wen(1)
	);

	assign io_master_arvalid = ((state == STATE_IFU_READING) | (state == STATE_LSU_READING) & soc_reading) & master_arvalid;
	assign io_master_araddr  = {32{state == STATE_IFU_READING}} & ifu_addr | {32{state == STATE_LSU_READING}} & lsu_addr;
	assign io_master_arid    = 0;
	assign io_master_arlen   = 0;
	assign io_master_arsize  = {3{state == STATE_IFU_READING}} & 3'b010 | {3{state == STATE_LSU_READING}} & lsu_arsize;
	assign io_master_arburst = 0;
	assign io_master_rready  = (state == STATE_LSU_READING) | (state == STATE_IFU_READING);

	assign clint_arvalid     = (state == STATE_LSU_READING) & clint_reading & master_arvalid;
	assign clint_araddr      = {32{state == STATE_LSU_READING}} & lsu_addr;
	assign clint_rready      = (state == STATE_LSU_READING);

	assign ifu_rresp         = {2{state == STATE_IFU_REPLY}} & master_rresp_reg;
	assign lsu_rresp         = {2{state == STATE_LSU_REPLY}} & ({2{soc_reading}} & master_rresp_reg | {2{clint_reading}} & clint_rresp_reg);
	assign ifu_rdata         = {64{state == STATE_IFU_REPLY}} & master_rdata_reg;
	assign lsu_rdata         = {64{state == STATE_LSU_REPLY}} & ({64{soc_reading}} & master_rdata_reg | {64{clint_reading}} & {32'b0, clint_rdata_reg});


	assign lsu_awready       = io_master_awready;
	assign io_master_awvalid = lsu_awvalid;
	assign io_master_awaddr  = lsu_awaddr;
	assign io_master_awid    = 0;
	assign io_master_awlen   = 0;
	assign io_master_awsize  = lsu_awsize;
	assign io_master_awburst = 0;

	assign lsu_wready        = io_master_wready;
	assign io_master_wvalid  = lsu_wvalid;
	assign io_master_wdata   = lsu_wdata;
	assign io_master_wstrb   = lsu_wstrb;
	assign io_master_wlast   = io_master_wvalid;

	assign io_master_bready  = lsu_bready;
	assign lsu_bvalid        = io_master_bvalid;
	assign lsu_bresp         = io_master_bresp;
/*
import "DPI-C" function void add_lsu_readingcycle();
import "DPI-C" function void add_ifu_readingcycle();
import "DPI-C" function void add_miss_icache();
import "DPI-C" function void add_hit_icache();

	always @(posedge clock) begin
		if ((state == STATE_LSU_READING) | (state == STATE_LSU_REPLY)) add_lsu_readingcycle();
		if ((state == STATE_IFU_READING) | (state == STATE_IFU_READING_CACHE) | (state == STATE_IFU_REPLY) | (state == STATE_CACHE_WRITING)) add_ifu_readingcycle();
		if (icache_rvalid & icache_rready) begin
			if (icache_rresp[1]) add_miss_icache();
			else add_hit_icache();
		end
	end
*/
endmodule
