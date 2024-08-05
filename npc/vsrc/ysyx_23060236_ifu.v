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
	input  [31:0] icache_rdata,
	input         icache_hit,
	input         icache_rvalid,

	output [31:0] icache_awaddr,
	output [31:0] icache_wdata,
	output        icache_wvalid,
	input         icache_bvalid,


	input         wb_valid,
	input         jump_wrong,
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
	wire last;
	wire jump_wrong_state;
	wire [31:0] pc_tmp;

	assign ifu_rready    = 1;
	assign pc_in_sdram   = (pc >= 32'ha0000000) & (pc < 32'ha2000000);
	assign icache_araddr = pc;
	assign ifu_araddr    = ~pc_in_sdram ? pc : pc & ~32'hf; //与icache的块大小一致
	assign ifu_arburst   = ~pc_in_sdram ? 2'b0 : 2'b01;
	assign ifu_arlen     = ~pc_in_sdram ? 4'b0 : 4'b0011; //与icache的块大小一致
	//与icache的块大小一致
	assign inst_tmp = (ifu_rvalid & ifu_rready & ((pc[3:2] == icache_awaddr[3:2]) | ~pc_in_sdram)) ? ifu_rdata : 
		                (icache_rvalid & icache_hit) ? icache_rdata : 
										inst;
	assign ifu_over = (icache_rvalid & icache_hit | icache_bvalid & last | ifu_rvalid & ifu_rready & ~pc_in_sdram);
	assign icache_awaddr_tmp = (icache_rvalid & ~icache_hit) ? (pc & ~32'hf) : 
														 (icache_bvalid & ~last) ? (icache_awaddr + 4) : 
														 icache_awaddr;
	assign pc_tmp = (idu_valid & idu_ready) ? (pc + 4) : 
									((jump_wrong | jump_wrong_state) & (idu_valid | ifu_over)) ? jump_addr : 
									pc;

	ysyx_23060236_Reg #(1, 0) reg_last(
		.clock(clock),
		.reset(reset),
		.din(ifu_rlast),
		.dout(last),
		.wen(ifu_rvalid & ifu_rready)
	);

	ysyx_23060236_Reg #(1, 1) reg_ifu_valid(
		.clock(clock),
		.reset(reset),
		.din(~ifu_valid & (idu_valid & idu_ready | (jump_wrong | jump_wrong_state) & (idu_valid | ifu_over))),
		.dout(ifu_valid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 32'h30000000) pc_adder(
		.clock(clock),
		.reset(reset),
		.din(pc_tmp),
		.dout(pc),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_arvalid(
		.clock(clock),
		.reset(reset),
		.din(~icache_arvalid & ifu_valid & pc_in_sdram),
		.dout(icache_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_icache_wvalid(
		.clock(clock),
		.reset(reset),
		.din(~icache_wvalid & ifu_rvalid & ifu_rready & pc_in_sdram),
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
		.din(ifu_arvalid & ~ifu_arready | ~ifu_arvalid & (icache_rvalid & ~icache_hit | ifu_valid & ~pc_in_sdram)),
		.dout(ifu_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_icache_wdata(
		.clock(clock),
		.reset(reset),
		.din(ifu_rdata),
		.dout(icache_wdata),
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
		.din(~idu_valid & ifu_over & ~jump_wrong & ~jump_wrong_state | idu_valid & ~idu_ready & ~jump_wrong),
		.dout(idu_valid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_jump_wrong_state(
		.clock(clock),
		.reset(reset),
		.din(jump_wrong_state & ~ifu_over | ~jump_wrong_state & jump_wrong & ~ifu_over & ~idu_valid),
		.dout(jump_wrong_state),
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
		else if (ifu_valid) ifu_reading <= 1;
		else if (ifu_over) ifu_reading <= 0;

		if (~reset & ifu_reading) add_ifu_readingcycle();

		if (icache_rvalid) begin
			if (~icache_hit) add_miss_icache();
			else add_hit_icache();
		end

		if (reset) ifu_miss_icache <= 0;
		else if (icache_rvalid & ~icache_hit) ifu_miss_icache <= 1;
		else if (ifu_over) ifu_miss_icache <= 0;

		if (ifu_miss_icache) add_tmt();
	end
*/
endmodule
