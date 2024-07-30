module ysyx_23060236_idu(
	input  [31:0] in,
	output [6:0]  opcode,
	output [2:0]  funct3,
	output [6:0]  funct7,
	output [3:0]  rd,
	output [3:0]  rs1,
	output [3:0]  rs2,
	output [31:0] imm,
	output [5:0]  inst_type,
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
	assign reg_wen = (inst_type[TYPE_I] & ({funct3, opcode} != 10'b0001110011)) | inst_type[TYPE_U] | inst_type[TYPE_J] | (inst_type[TYPE_R]);
	assign csr_enable = (opcode == 7'b1110011) & (funct3 != 3'b000);

	parameter TYPE_R = 0;
	parameter TYPE_I = 1;
	parameter TYPE_S = 2;
	parameter TYPE_B = 3;
	parameter TYPE_U = 4;
	parameter TYPE_J = 5; 

	assign inst_type[TYPE_U] = (opcode == 7'b0110111) | (opcode == 7'b0010111);
	assign inst_type[TYPE_J] = (opcode == 7'b1101111);
	assign inst_type[TYPE_I] = (opcode == 7'b1100111) | (opcode == 7'b0000011) | (opcode == 7'b0010011) | (opcode == 7'b1110011);
	assign inst_type[TYPE_B] = (opcode == 7'b1100011);
	assign inst_type[TYPE_S] = (opcode == 7'b0100011);
	assign inst_type[TYPE_R] = (opcode == 7'b0110011);

	assign imm = (inst_type[TYPE_I]) ? {{20{in[31]}}, in[31:20]} :
	             (inst_type[TYPE_U]) ? {in[31:12], 12'b0} :
	             (inst_type[TYPE_S]) ? {{20{in[31]}}, in[31:25], in[11:7]} :
	             (inst_type[TYPE_J]) ? {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0} :
	             (inst_type[TYPE_B]) ? {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0} :
							 32'b0;

endmodule
