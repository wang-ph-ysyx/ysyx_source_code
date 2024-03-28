module exu(
	input [6:0] opcode,
	input [31:0] src1,
	input [31:0] src2,
	input [31:0] imm,
	input [2:0] funct3,
	input [6:0] funct7,
	output [31:0] val);

	MuxKeyInternal #(1, 7, 32, 0) calculate_val(
		.out(val),
		.key(opcode),
		.default_out(32'b0),
		.lut({
			7'b0010011, src1 + imm
		})
	);

endmodule
