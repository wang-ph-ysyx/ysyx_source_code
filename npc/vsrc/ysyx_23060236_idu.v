module ysyx_23060236_idu(
	input  clock,
	input  reset,

	input  [31:0] inst_in,
	input  [31:0] pc_in,

	input  [31:0] src1,

	input  [3:0]  exu_rd,
	input  exu_reg_wen,
	input  [3:0]  lsu_rd,
	input  lsu_reg_wen,
	input  lsu_ready,
	input  jump_wrong,

	output [3:0] rs1,
	output [3:0] rs2,
	output reg [31:0] pc,
	output [9:0]  opcode_type,
	output [2:0]  funct3,
	output [3:0]  rd,
	output [31:0] imm,
	output funct7_5,
	output reg_wen,
	output inst_fencei,
	output inst_ecall,
	output inst_mret,

	input  idu_valid,
	output idu_ready,
	output exu_valid,
	input  exu_ready
);

	reg [31:0] inst;

	wire raw_conflict;
	wire exu_valid_tmp;
	wire need_rs2;

	assign need_rs2 = opcode_type[INST_BEQ] | opcode_type[INST_SW] | opcode_type[INST_ADD];
	assign exu_valid = exu_valid_tmp & ~raw_conflict;
	assign raw_conflict = (
		~exu_ready & exu_reg_wen & (exu_rd != 4'b0) &
		((exu_rd == rs1) | (exu_rd == rs2) & need_rs2) | 
		~lsu_ready & lsu_reg_wen & (lsu_rd != 4'b0) &
		((lsu_rd == rs1) | (lsu_rd == rs2) & need_rs2)
	);

	ysyx_23060236_Reg #(1, 1) reg_idu_ready(
		.clock(clock),
		.reset(reset),
		.din((idu_ready & ~idu_valid | ~idu_ready & exu_valid & exu_ready) | jump_wrong),
		.dout(idu_ready),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_exu_valid_tmp(
		.clock(clock),
		.reset(reset),
		.din((exu_valid_tmp & ~(exu_ready & exu_valid) | ~exu_valid_tmp & idu_valid & idu_ready) & ~jump_wrong),
		.dout(exu_valid_tmp),
		.wen(1)
	);

	always @(posedge clock) begin
		if (idu_valid & idu_ready) begin
			inst <= inst_in;
			pc   <= pc_in;
		end
	end

	wire [5:0] Type;
	wire [6:0] opcode;
	wire [6:0] funct7;
	assign opcode         = inst[6:0];
	assign rs1            = inst[18:15];
	assign rs2            = inst[23:20];
	assign rd             = inst[10:7];
	assign funct3         = inst[14:12];
	assign funct7         = inst[31:25];
	assign funct7_5       = funct7[5];
	assign reg_wen        = Type[TYPE_I] & ~((funct3 == 3'b0) & opcode_type[INST_CSR]) | Type[TYPE_U] | Type[TYPE_J] | Type[TYPE_R];

	assign inst_ecall  = (inst == 32'h00000073);
	assign inst_mret   = (inst == 32'h30200073);
	assign inst_fencei = (opcode == 7'b0001111);

	parameter TYPE_R = 0;
	parameter TYPE_I = 1;
	parameter TYPE_S = 2;
	parameter TYPE_B = 3;
	parameter TYPE_U = 4;
	parameter TYPE_J = 5; 

	parameter INST_LUI   = 0;
	parameter INST_AUIPC = 1;
	parameter INST_JAL   = 2;
	parameter INST_JALR  = 3;
	parameter INST_BEQ   = 4;
	parameter INST_LW    = 5;
	parameter INST_SW    = 6;
	parameter INST_ADDI  = 7;
	parameter INST_ADD   = 8;
	parameter INST_CSR   = 9;

	assign opcode_type[INST_LUI  ] = (opcode == 7'b0110111);
	assign opcode_type[INST_AUIPC] = (opcode == 7'b0010111);
	assign opcode_type[INST_JAL  ] = (opcode == 7'b1101111);
	assign opcode_type[INST_JALR ] = (opcode == 7'b1100111);
	assign opcode_type[INST_BEQ  ] = (opcode == 7'b1100011);
	assign opcode_type[INST_LW   ] = (opcode == 7'b0000011);
	assign opcode_type[INST_SW   ] = (opcode == 7'b0100011);
	assign opcode_type[INST_ADDI ] = (opcode == 7'b0010011);
	assign opcode_type[INST_ADD  ] = (opcode == 7'b0110011);
	assign opcode_type[INST_CSR  ] = (opcode == 7'b1110011);

	assign Type[TYPE_R] = opcode_type[INST_ADD];
	assign Type[TYPE_I] = opcode_type[INST_JALR] | opcode_type[INST_LW] | opcode_type[INST_ADDI] | opcode_type[INST_CSR];
	assign Type[TYPE_S] = opcode_type[INST_SW];
	assign Type[TYPE_B] = opcode_type[INST_BEQ];
	assign Type[TYPE_U] = opcode_type[INST_LUI] | opcode_type[INST_AUIPC];
	assign Type[TYPE_J] = opcode_type[INST_JAL];

	assign imm = (Type[TYPE_I]) ? {{20{inst[31]}}, inst[31:20]} :
							 (Type[TYPE_U]) ? {inst[31:12], 12'b0} :
							 (Type[TYPE_S]) ? {{20{inst[31]}}, inst[31:25], inst[11:7]} :
							 (Type[TYPE_J]) ? {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0} :
							 (Type[TYPE_B]) ? {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0} :
							 32'b0;

endmodule
