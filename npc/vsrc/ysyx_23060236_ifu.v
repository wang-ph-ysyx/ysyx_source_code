module ysyx_23060236_ifu(
	input  clock,
	input  reset,

	output [31:0] ifu_araddr,
	output        ifu_arvalid,
	input         ifu_arready,
	input  [31:0] ifu_rdata,
	input  [1:0]  ifu_rresp,
	input         ifu_rvalid,
	output        ifu_rready,

	output [31:0] icache_araddr,
	output        icache_arvalid,
	input         icache_arready,
	input  [31:0] icache_rdata,
	input  [1:0]  icache_rresp,
	input         icache_rvalid,
	output        icache_rready,

	output        icache_awvalid,
	output [31:0] icache_awaddr,
	input         icache_awready,
	output [31:0] icache_wdata,
	output [3:0]  icache_wstrb,
	output        icache_wvalid,
	input         icache_wready,
	input  [1:0]  icache_bresp,
	input         icache_bvalid,
	output        icache_bready,


	input         wb_valid,
	input  [31:0] pc,
	output [31:0] inst,
	output        idu_valid
);

	wire ifu_valid;
	wire ifu_over;
	wire pc_in_sram;
	wire [31:0] inst_tmp;
	wire [31:0] inst_icache_tmp;
	wire [31:0] inst_ifu_tmp;

	assign pc_in_sram    = (pc >= 32'h0f000000) & (pc < 32'h0f002000);
	assign icache_rready = 1;
	assign icache_araddr = pc;
	assign icache_awaddr = pc;
	assign icache_wdata  = inst;
	assign icache_wstrb  = 4'hf;
	assign icache_bready = 1;
	assign ifu_rready    = 1;
	assign ifu_araddr    = pc;
	assign inst_ifu_tmp  = ifu_rdata & {32{ifu_rvalid & ifu_rready}};
	assign inst_icache_tmp = icache_rdata & {32{icache_rvalid & icache_rready & ~icache_rresp[1]}};
	assign inst_tmp = inst_ifu_tmp | inst_icache_tmp;
	assign ifu_over = (icache_rvalid & icache_rready & ~icache_rresp[1] | icache_bvalid & icache_bready | ifu_rvalid & ifu_rready & pc_in_sram);

	ysyx_23060236_Reg #(1, 1) reg_ifu_valid(
		.clock(clock),
		.reset(reset),
		.din(~ifu_valid & wb_valid),
		.dout(ifu_valid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_arvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_arvalid & ~icache_arready | ~icache_arvalid & ifu_valid & ~pc_in_sram),
		.dout(icache_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_awvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_awvalid & ~icache_awready | ~icache_awvalid & icache_rvalid & icache_rready & icache_rresp[1] & ~pc_in_sram),
		.dout(icache_awvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_wvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_wvalid & ~icache_wready | ~icache_wvalid & ifu_rvalid & ifu_rready & ~pc_in_sram),
		.dout(icache_wvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_ifu_arvalid(
		.clock(clock),
		.reset(reset),
		.din(ifu_arvalid & ~ifu_arready | ~ifu_arvalid & (icache_rvalid & icache_rready & icache_rresp[1] | ifu_valid & pc_in_sram)),
		.dout(ifu_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_inst(
		.clock(clock),
		.reset(reset),
		.din(inst_tmp),
		.dout(inst),
		.wen(ifu_rvalid & ifu_rready | icache_rvalid & icache_rready & ~icache_rresp[1])
	);

	ysyx_23060236_Reg #(1, 0) reg_idu_valid(
		.clock(clock),
		.reset(reset),
		.din(~idu_valid & ifu_over),
		.dout(idu_valid),
		.wen(1)
	);

	import "DPI-C" function void add_ifu_readingcycle();
	import "DPI-C" function void add_miss_icache();
	import "DPI-C" function void add_hit_icache();

	reg ifu_reading;

	always @(posedge clock) begin
		if (wb_valid) ifu_reading <= 1;
		else if (ifu_over) ifu_reading <= 0;
		if (ifu_reading) add_ifu_readingcycle();
		if (icache_rvalid & icache_rready) begin
			if (icache_rresp[1]) add_miss_icache();
			else add_hit_icache();
		end
	end

endmodule
