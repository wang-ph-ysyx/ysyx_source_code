module ysyx_23060236_lsu(
	input  clock,
	input  reset,

	output [31:0] lsu_araddr,
	output        lsu_arvalid,
	output [2:0]  lsu_arsize,
	input         lsu_arready,
	input  [63:0] lsu_rdata,
	input  [1:0]  lsu_rresp,
	input         lsu_rvalid,
	output        lsu_rready,

	output [31:0] lsu_awaddr,
	output        lsu_awvalid,
	output [2:0]  lsu_awsize,
	input         lsu_awready,
	output [63:0] lsu_wdata,
	output [7:0]  lsu_wstrb,
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
	input  [7:0]  wmask,
	input         wb_valid,
	input         lsu_ren,
	input         lsu_wen,
	output        lsu_aligned_64,
	output        lsu_aligned_32,
	output [31:0] lsu_val
);

	wire [31:0] lsu_val_tmp;
	wire [31:0] lsu_val_shift_32;
	wire [31:0] lsu_val_shift_64;

	ysyx_23060236_MuxKeyInternal #(5, 10, 3, 1) caculate_lsu_arsize(
		.out(lsu_arsize),
		.key({funct3, opcode}),
		.default_out(3'b0),
		.lut({
			10'b0000000011, 3'b000,   //lb
			10'b0010000011, 3'b001,   //lh
			10'b0100000011, 3'b010,   //lw
			10'b1000000011, 3'b000,   //lbu
			10'b1010000011, 3'b001    //lhu
		})
	);

	ysyx_23060236_MuxKeyInternal #(3, 10, 3, 1) caculate_lsu_awsize(
		.out(lsu_awsize),
		.key({funct3, opcode}),
		.default_out(3'b0),
		.lut({
			10'b0000100011, 3'b000,   //sb
			10'b0010100011, 3'b001,   //sh
			10'b0100100011, 3'b010    //sw
		})
	);

	ysyx_23060236_MuxKeyInternal #(15, 12, 32, 1) caculate_lsu_val_tmp(
		.out(lsu_val_tmp),
		.key({lsu_aligned_64, lsu_aligned_32, funct3, opcode}),
		.default_out(32'b0),
		.lut({
			12'b100000000011, (lsu_val_shift_64 & 32'hff) | {{24{lsu_val_shift_64[7]}}, 8'h0},      //lb
			12'b100010000011, (lsu_val_shift_64 & 32'hffff) | {{16{lsu_val_shift_64[15]}}, 16'h0},  //lh
			12'b100100000011, lsu_val_shift_64,                                                     //lw
			12'b101000000011, lsu_val_shift_64 & 32'hff,                                            //lbu
			12'b101010000011, lsu_val_shift_64 & 32'hffff,                                          //lhu
			12'b010000000011, (lsu_val_shift_32 & 32'hff) | {{24{lsu_val_shift_32[7]}}, 8'h0},      //lb
			12'b010010000011, (lsu_val_shift_32 & 32'hffff) | {{16{lsu_val_shift_32[15]}}, 16'h0},  //lh
			12'b010100000011, lsu_val_shift_32,                                                     //lw
			12'b011000000011, lsu_val_shift_32 & 32'hff,                                            //lbu
			12'b011010000011, lsu_val_shift_32 & 32'hffff,                                          //lhu
			12'b000000000011, (lsu_rdata[31:0] & 32'hff) | {{24{lsu_rdata[31:0][7]}}, 8'h0},        //lb
			12'b000010000011, (lsu_rdata[31:0] & 32'hffff) | {{16{lsu_rdata[31:0][15]}}, 16'h0},    //lh
			12'b000100000011, lsu_rdata[31:0],                                                      //lw
			12'b001000000011, lsu_rdata[31:0] & 32'hff,                                             //lbu
			12'b001010000011, lsu_rdata[31:0] & 32'hffff                                            //lhu
		})
	);

	ysyx_23060236_MuxKeyInternal #(8, 3, 32, 1) caculate_lsu_val_shift_64(
		.out(lsu_val_shift_64),
		.key(lsu_araddr[2:0]),
		.default_out(32'b0),
		.lut({
			3'b000, lsu_rdata[31:0],
			3'b001, lsu_rdata[39:8],
			3'b010, lsu_rdata[47:16],
			3'b011, lsu_rdata[55:24],
			3'b100, lsu_rdata[63:32],
			3'b101, {8'b0, lsu_rdata[63:40]},
			3'b110, {16'b0, lsu_rdata[63:48]},
			3'b111, {24'b0, lsu_rdata[63:56]}
		})
	);

	ysyx_23060236_MuxKeyInternal #(4, 2, 32, 1) calculate_lsu_val_shift_32(
		.out(lsu_val_shift_32),
		.key(lsu_araddr[1:0]),
		.default_out(32'b0),
		.lut({
			2'b00, lsu_rdata[31:0],
			2'b01, lsu_rdata[39:8],
			2'b10, lsu_rdata[47:16],
			2'b11, lsu_rdata[55:24]
		})
	);

	ysyx_23060236_MuxKeyInternal #(8, 3, 8, 1) calculate_lsu_wstrb(
		.out(lsu_wstrb),
		.key(lsu_awaddr[2:0]),
		.default_out(8'b0),
		.lut({
			3'b000, wmask,
			3'b001, {wmask[6:0], 1'b0},
			3'b010, {wmask[5:0], 2'b0},
			3'b011, {wmask[4:0], 3'b0},
			3'b100, {wmask[3:0], 4'b0},
			3'b101, {wmask[2:0], 5'b0},
			3'b110, {wmask[1:0], 6'b0},
			3'b111, {wmask[0:0], 7'b0}
		})
	);

	ysyx_23060236_MuxKeyInternal #(8, 3, 64, 1) calculate_lsu_wdata(
		.out(lsu_wdata),
		.key(lsu_awaddr[2:0]),
		.default_out(64'b0),
		.lut({
			3'b000, {32'b0, src2},
			3'b001, {24'b0, src2, 8'b0},
			3'b010, {16'b0, src2, 16'b0},
			3'b011, {8'b0, src2, 24'b0},
			3'b100, {src2, 32'b0},
			3'b101, {src2[23:0], 40'b0},
			3'b110, {src2[15:0], 48'b0},
			3'b111, {src2[7:0], 56'b0}
		})
	);

	ysyx_23060236_Reg #(32, 0) reg_lsu_val(
		.clock(clock),
		.reset(reset),
		.din(lsu_val_tmp & {32{~wb_valid}}),
		.dout(lsu_val),
		.wen(lsu_rvalid & lsu_rready | wb_valid)
	);

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

	assign lsu_rready = 1;
	assign lsu_bready = 1;
	assign lsu_araddr = src1 + imm;
	assign lsu_awaddr = src1 + imm;
	assign lsu_aligned_64 = (lsu_araddr >= 32'h0f000000) & (lsu_araddr < 32'h0f002000);
	assign lsu_aligned_32 = (lsu_araddr >= 32'h80000000) & (lsu_araddr < 32'hc0000000);

endmodule
