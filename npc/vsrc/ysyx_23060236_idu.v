module ysyx_23060236_idu(
	input  [31:0] in,
	output [6:0]  opcode,
	output [2:0]  funct3,
	output [6:0]  funct7,
	output [3:0]  rd,
	output [3:0]  rs1,
	output [3:0]  rs2,
	output [31:0] imm,
	output [2:0]  Type,
	output lsu_wen,
	output lsu_ren,
	output reg_wen,
	output csr_enable,
	input  idu_valid);

	assign opcode  = in[6:0];
	assign rs1     = in[18:15];
	assign rs2     = in[23:20];
	assign rd      = in[10:7];
	assign funct3  = in[14:12];
	assign funct7  = in[31:25];
	assign lsu_ren = (opcode == 7'b0000011) & idu_valid;
	assign lsu_wen = (opcode == 7'b0100011) & idu_valid;
	assign reg_wen = ((Type == TYPE_I) & ({funct3, opcode} != 10'b0001110011)) || (Type == TYPE_U) || (Type == TYPE_J) || (Type == TYPE_R);
	assign csr_enable = (opcode == 7'b1110011) & (funct3 != 3'b000);

	parameter TYPE_R = 3'd0;
	parameter TYPE_I = 3'd1;
	parameter TYPE_S = 3'd2;
	parameter TYPE_B = 3'd3;
	parameter TYPE_U = 3'd4;
	parameter TYPE_J = 3'd5; 

	assign Type = (opcode == 7'b0110111) ? TYPE_U : //lui
	              (opcode == 7'b0010111) ? TYPE_U : //auipc
	              (opcode == 7'b1101111) ? TYPE_J : //jal
	              (opcode == 7'b1100111) ? TYPE_I : //jalr
	              (opcode == 7'b1100011) ? TYPE_B : //beq
	              (opcode == 7'b0000011) ? TYPE_I : //lw
	              (opcode == 7'b0100011) ? TYPE_S : //sw
	              (opcode == 7'b0010011) ? TYPE_I : //addi
	              (opcode == 7'b0110011) ? TYPE_R : //add
	              (opcode == 7'b1110011) ? TYPE_I : //csrrs csrrw
								3'd0;

	ysyx_23060236_MuxKeyInternal #(5, 3, 32, 1) choose_imm(
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
