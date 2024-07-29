module ysyx_23060236_lsu(
	input  clock,
	input  reset,

	output [31:0] lsu_araddr,
	output        lsu_arvalid,
	output [2:0]  lsu_arsize,
	input         lsu_arready,
	input  [31:0] lsu_rdata,
	input  [1:0]  lsu_rresp,
	input         lsu_rvalid,
	output        lsu_rready,

	output [31:0] lsu_awaddr,
	output        lsu_awvalid,
	output [2:0]  lsu_awsize,
	input         lsu_awready,
	output [31:0] lsu_wdata,
	output [3:0]  lsu_wstrb,
	output        lsu_wvalid,
	input         lsu_wready,
	input  [1:0]  lsu_bresp,
	input         lsu_bvalid,
	output        lsu_bready,

	input  [6:0]  opcode,
	input  [2:0]  funct3,
	input  [31:0] src1,
	input  [31:0] src2,
	input  [31:0] imm,
	input  [3:0]  wmask,
	input         wb_valid,
	input         lsu_ren,
	input         lsu_wen,
	output [31:0] lsu_val
);

	wire [31:0] lsu_val_tmp;
	wire [31:0] lsu_val_shift;

	assign lsu_arsize = {1'b0, funct3[1:0]};
	assign lsu_awsize = {1'b0, funct3[1:0]};
	assign lsu_rready = 1;
	assign lsu_bready = 1;
	assign lsu_araddr = src1 + imm;
	assign lsu_awaddr = lsu_araddr;
	assign lsu_wstrb = wmask << lsu_awaddr[1:0];
	assign lsu_wdata = src2 << {lsu_awaddr[1:0], 3'b0};
	assign lsu_val_shift = lsu_rdata >> {lsu_araddr[1:0], 3'b0};

	assign lsu_val_tmp = (funct3 == 3'b000) ? (lsu_val_shift & 32'hff) | {{24{lsu_val_shift[7]}}, 8'h0} :     //lb  
                       (funct3 == 3'b001) ? (lsu_val_shift & 32'hffff) | {{16{lsu_val_shift[15]}}, 16'h0} : //lh
                       (funct3 == 3'b010) ? lsu_val_shift :                                                 //lw
                       (funct3 == 3'b100) ? lsu_val_shift & 32'hff :                                        //lbu
                       (funct3 == 3'b101) ? lsu_val_shift & 32'hffff :                                      //lhu
											 32'b0;

	ysyx_23060236_Reg #(1, 0) reg_lsu_arvalid(
		.clock(clock),
		.reset(reset),
		.din(lsu_arvalid & ~lsu_arready | ~lsu_arvalid & lsu_ren),
		.dout(lsu_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_lsu_awvalid(
		.clock(clock),
		.reset(reset),
		.din(lsu_awvalid & ~lsu_awready | ~lsu_awvalid & lsu_wen),
		.dout(lsu_awvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_lsu_wvalid(
		.clock(clock),
		.reset(reset),
		.din(lsu_wvalid & ~lsu_wready | ~lsu_wvalid & lsu_wen),
		.dout(lsu_wvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(32, 0) reg_lsu_val(
		.clock(clock),
		.reset(reset),
		.din(lsu_val_tmp & {32{~wb_valid}}),
		.dout(lsu_val),
		.wen(lsu_rvalid & lsu_rready | wb_valid)
	);

endmodule
