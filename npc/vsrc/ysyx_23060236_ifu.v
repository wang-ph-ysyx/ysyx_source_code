module ysyx_23060236_ifu(
	input  clock,
	input  reset,

	output [31:0] ifu_araddr,
	output        ifu_arvalid,
	input         ifu_arready,
	input  [63:0] ifu_rdata,
	input  [1:0]  ifu_rresp,
	input         ifu_rvalid,
	output        ifu_rready,

	input         wb_valid,
	input  [31:0] pc,
	output [31:0] inst,
	output        ifu_aligned,
	output        idu_valid
);

	wire [31:0] inst_tmp;

	assign ifu_rready  = 1;
	assign ifu_araddr  = pc;
	assign ifu_aligned = (ifu_araddr >= 32'h0f000000) & (ifu_araddr < 32'h0f002000);
	assign inst_tmp    = {32{~ifu_aligned}} & ifu_rdata[31:0] | {32{ifu_aligned}} & ({32{pc[2]}} & ifu_rdata[63:32] | {32{~pc[2]}} & ifu_rdata[31:0]);

	ysyx_23060236_Reg #(1, 1) reg_ifu_arvalid(
		.clock(clock),
		.reset(reset),
		.din(ifu_arvalid & ~ifu_arready | ~ifu_arvalid & wb_valid),
		.dout(ifu_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_inst(
		.clock(clock),
		.reset(reset),
		.din(inst_tmp),
		.dout(inst),
		.wen(ifu_rvalid & ifu_rready)
	);

	ysyx_23060236_Reg #(1, 0) reg_idu_valid(
		.clock(clock),
		.reset(reset),
		.din(~idu_valid & ifu_rvalid & ifu_rready),
		.dout(idu_valid),
		.wen(1)
	);

endmodule
