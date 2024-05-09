module idu(
	input [31:0] in,
	output [6:0] opcode,
	output [2:0] funct3,
	output [6:0] funct7,
	output [4:0] rd,
	output [4:0] rs1,
	output [4:0] rs2,
	output [31:0] imm,
	output [2:0] Type,
	output lsu_wen,
	output lsu_ren,
	input  idu_valid);

	assign opcode = in[6:0];
	assign rs1 = in[19:15];
	assign rs2 = in[24:20];
	assign rd = in[11:7];
	assign funct3 = in[14:12];
	assign funct7 = in[31:25];
	assign lsu_ren = (opcode == 7'b0000011) & idu_valid;
	assign lsu_wen = (opcode == 7'b0100011) & idu_valid;

	parameter TYPE_R = 3'd0, TYPE_I = 3'd1, TYPE_S = 3'd2, TYPE_B = 3'd3, TYPE_U = 3'd4, TYPE_J = 3'd5; 

	MuxKeyInternal #(10, 7, 3, 1) choose_type(
		.out(Type),
		.key(opcode),
		.default_out(3'b0),
		.lut({
			7'b0110111, TYPE_U,   //lui
			7'b0010111, TYPE_U,   //auipc
			7'b0100011, TYPE_S,   //sw
			7'b1101111, TYPE_J,   //jal
			7'b0010011, TYPE_I,   //addi
			7'b1100111, TYPE_I,   //jalr
			7'b0000011, TYPE_I,   //lw
			7'b0010011, TYPE_I,   //slli
			7'b1100011, TYPE_B,   //beq
			7'b1110011, TYPE_I    //csrrs csrrw
		})
	);

	MuxKeyInternal #(5, 3, 32, 1) choose_imm(
		.out(imm),
		.key(Type),
		.default_out(32'b0),
		.lut({
			TYPE_I, {{20{in[31]}}, in[31:20]},
			TYPE_U, {in[31:12], 12'b0},
			TYPE_S, {{20{in[31]}}, in[31:25], in[11:7]},
			TYPE_J, {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0},
			TYPE_B, {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0}
		})
	);

endmodule
