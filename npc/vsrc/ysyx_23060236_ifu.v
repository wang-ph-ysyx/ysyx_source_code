module ysyx_23060236_ifu(
	input  clock,
	input  reset,

	output [31:0] ifu_araddr,
	output        ifu_arvalid,
	input         ifu_arready,
	output [1:0]  ifu_arburst,
	output [3:0]  ifu_arlen,
	input  [31:0] ifu_rdata,
	input  [1:0]  ifu_rresp,
	input         ifu_rlast,
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
	output [31:0] pc,
	input  [31:0] jump_addr,
	output [31:0] inst,
	output        idu_valid,
	input         idu_ready
);

	wire ifu_valid;
	wire ifu_over;
	wire pc_in_sdram;
	wire [31:0] inst_tmp;
	wire [31:0] inst_icache_tmp;
	wire [31:0] inst_ifu_tmp;
	wire [31:0] icache_awaddr_tmp;
	wire [2:0]  count;
	wire [31:0] ifu_rdata_reg;

	assign pc_in_sdram   = (pc >= 32'ha0000000) & (pc < 32'ha2000000);
	assign icache_rready = 1;
	assign icache_araddr = pc;
	assign icache_wdata  = ifu_rdata_reg;
	assign icache_wstrb  = 4'hf;
	assign icache_bready = 1;
	assign ifu_araddr    = ~pc_in_sdram ? pc : pc & ~32'hf; //与icache的块大小一致
	assign ifu_arburst   = ~pc_in_sdram ? 2'b0 : 2'b01;
	assign ifu_arlen     = ~pc_in_sdram ? 4'b0 : 4'b0011; //与icache的块大小一致
	//与icache的块大小一致
	assign inst_tmp = (ifu_rvalid & ifu_rready & ((pc[3:2] == icache_awaddr[3:2]) | ~pc_in_sdram)) ? ifu_rdata : 
		                (icache_rvalid & icache_rready & ~icache_rresp[1]) ? icache_rdata : 
										inst;
	assign ifu_over = (icache_rvalid & icache_rready & ~icache_rresp[1] | icache_bvalid & icache_bready & ~(|count) | ifu_rvalid & ifu_rready & ~pc_in_sdram);
	assign icache_awaddr_tmp = (icache_rvalid & icache_rready & icache_rresp[1]) ? (pc & ~32'hf) : 
														 (icache_bvalid & icache_bready & |count) ? (icache_awaddr + 4) : 
														 icache_awaddr;

	ysyx_23060236_Reg #(3, 4) reg_count(
		.clock(clock),
		.reset(ifu_arvalid & ifu_arready & pc_in_sdram),
		.din(count-1),
		.dout(count),
		.wen(ifu_rvalid & ifu_rready & pc_in_sdram)
	);

	ysyx_23060236_Reg #(1, 1) reg_ifu_valid(
		.clock(clock),
		.reset(reset),
		.din(~ifu_valid & wb_valid),
		.dout(ifu_valid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 32'h30000000) pc_adder(
		.clock(clock),
		.reset(reset),
		.din(jump_addr),
		.dout(pc),
		.wen(wb_valid)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_arvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_arvalid & ~icache_arready | ~icache_arvalid & ifu_valid & pc_in_sdram),
		.dout(icache_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_awvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_awvalid & ~icache_awready | ~icache_awvalid & (icache_rvalid & icache_rready & icache_rresp[1] | icache_bvalid & icache_bready & |count) & pc_in_sdram),
		.dout(icache_awvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_wvalid(
		.clock(clock),
		.reset(reset),
		.din(icache_wvalid & ~icache_wready | ~icache_wvalid & ifu_rvalid & ifu_rready & pc_in_sdram),
		.dout(icache_wvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_icache_awaddr(
		.clock(clock),
		.reset(reset),
		.din(icache_awaddr_tmp),
		.dout(icache_awaddr),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_ifu_arvalid(
		.clock(clock),
		.reset(reset),
		.din(ifu_arvalid & ~ifu_arready | ~ifu_arvalid & (icache_rvalid & icache_rready & icache_rresp[1] | ifu_valid & ~pc_in_sdram)),
		.dout(ifu_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 1) reg_ifu_rready(
		.clock(clock),
		.reset(reset),
		.din(ifu_rready & ~ifu_rvalid | ~ifu_rready & (icache_bvalid & icache_bready | ~pc_in_sdram)),
		.dout(ifu_rready),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_ifu_rdata(
		.clock(clock),
		.reset(reset),
		.din(ifu_rdata),
		.dout(ifu_rdata_reg),
		.wen(ifu_rvalid & ifu_rready)
	);

	ysyx_23060236_Reg #(32, 0) reg_inst(
		.clock(clock),
		.reset(reset),
		.din(inst_tmp),
		.dout(inst),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_idu_valid(
		.clock(clock),
		.reset(reset),
		.din(~idu_valid & ifu_over | idu_valid & ~idu_ready),
		.dout(idu_valid),
		.wen(1)
	);
/*
	import "DPI-C" function void add_ifu_readingcycle();
	import "DPI-C" function void add_miss_icache();
	import "DPI-C" function void add_hit_icache();
	import "DPI-C" function void add_tmt();

	reg ifu_reading;
	reg ifu_miss_icache;

	always @(posedge clock) begin
		if (reset) ifu_reading <= 1;
		else if (wb_valid) ifu_reading <= 1;
		else if (ifu_over) ifu_reading <= 0;

		if (~reset & ifu_reading) add_ifu_readingcycle();

		if (icache_rvalid & icache_rready) begin
			if (icache_rresp[1]) add_miss_icache();
			else add_hit_icache();
		end

		if (reset) ifu_miss_icache <= 0;
		else if (icache_rvalid & icache_rready & icache_rresp[1]) ifu_miss_icache <= 1;
		else if (ifu_over) ifu_miss_icache <= 0;

		if (ifu_miss_icache) add_tmt();
	end
*/
endmodule
