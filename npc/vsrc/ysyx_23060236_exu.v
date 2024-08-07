module ysyx_23060236_exu(
	input  clock,
	input  reset,

	input  [9:0]  opcode_type_in,
	input  [3:0]  rd_in,
	input  [31:0] src1_in,
	input  [31:0] src2_in,
	input  [31:0] imm_in,
	input  [2:0]  funct3_in,
	input         funct7_5_in,
	input  [31:0] pc_in,
	input  reg_wen_in,
	input  inst_ecall_in,
	input  inst_mret_in,

	input  csr_jump_en,
	input  [31:0] csr_jump,
	input  [31:0] csr_val,

	output reg [31:0] pc,
	output reg [3:0]  rd,
	output reg [2:0]  funct3,
	output reg reg_wen,
	output reg inst_ecall,
	output reg inst_mret,
	output reg exu_complete,
	output [31:0] val,
	output [31:0] lsu_data,
	output [31:0] jump_addr,
	output [31:0] csr_wdata,
	output [11:0] csr_imm,
	output lsu_ren,
	output lsu_wen,
	output jump_wrong,
	output csr_enable,

	input  exu_valid,
	output exu_ready,
	output lsu_valid,
	input  lsu_ready
);

	reg  [9:0]  opcode_type;
	reg  [31:0] src1;
	reg  [31:0] src2;
	reg  [31:0] imm;
	reg         funct7_5;

	ysyx_23060236_Reg #(1, 1) reg_exu_ready(
		.clock(clock),
		.reset(reset),
		.din(exu_ready & ~exu_valid | ~exu_ready & lsu_valid & lsu_ready),
		.dout(exu_ready),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_lsu_valid(
		.clock(clock),
		.reset(reset),
		.din(lsu_valid & ~lsu_ready | ~lsu_valid & exu_valid & exu_ready),
		.dout(lsu_valid),
		.wen(1)
	);

	wire        jump_en;
	wire        jump_wrong_tmp;
	wire        jal_enable;
	wire [31:0] snpc;

	assign csr_imm = imm[11:0];
	assign snpc = pc + 4;
	assign jump_wrong_tmp = (jump_addr != snpc);
	assign jump_wrong = jump_wrong_tmp & exu_complete;
	assign csr_enable = opcode_type[INST_CSR] & (funct3 != 3'b0);
	assign jal_enable = opcode_type[INST_JAL] | opcode_type[INST_JALR];
	assign lsu_ren = opcode_type[INST_LW];
	assign lsu_wen = opcode_type[INST_SW];

	always @(posedge clock) begin
		if (exu_valid & exu_ready) begin
			opcode_type      <= opcode_type_in;
			rd               <= rd_in;
			src1             <= src1_in;
			src2             <= src2_in;
			imm              <= imm_in;
			funct3           <= funct3_in;
			funct7_5         <= funct7_5_in;
			pc               <= pc_in;
			reg_wen          <= reg_wen_in;
			inst_ecall       <= inst_ecall_in;
			inst_mret        <= inst_mret_in;
			exu_complete <= 1;
		end
		else begin
			exu_complete <= 0;
		end
	end

	assign jump_addr = csr_jump_en ? csr_jump :
										 jump_en ? exu_jump :
										 snpc;

	assign val = jal_enable ? snpc :
							 csr_enable ? csr_val :
							 alu_val;

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

	wire [31:0] compare;
	wire overflow;
	wire less;
	wire unequal;
	wire uless;

	wire [31:0] op_compare;
	wire [31:0] op_sum;
	wire [31:0] exu_jump;
	wire op_overflow;
	wire op_less;
	wire op_uless;

	wire [31:0] alu_val;
	wire [31:0] loperand;
	wire [31:0] roperand;
	wire [3:0]  operator;
	wire [3:0]  operator1;
	wire [3:0]  operator2;
	wire [3:0]  operator3;
	wire [3:0]  operator4;
	wire [62:0] val_sra;
	wire jump_cond;

	//exu_val
	assign loperand = (opcode_type[INST_AUIPC] | opcode_type[INST_JAL] | opcode_type[INST_BEQ]) ? pc : //auipc/jal/beq
										opcode_type[INST_LUI] ? 32'b0 :   //lui
										src1;   //imm/src2/jalr/lw/sw

	assign roperand = opcode_type[INST_ADD] ? src2 :   //src2
										imm;  //lui/auipc/imm/jal/jalr/beq/lw/sw

	localparam OP_ADD   = 4'd0;
	localparam OP_SUB   = 4'd1;
	localparam OP_AND   = 4'd2;
	localparam OP_XOR   = 4'd3;
	localparam OP_OR    = 4'd4;
	localparam OP_SRL   = 4'd5;
	localparam OP_SRA   = 4'd6;
	localparam OP_SLL   = 4'd7;
	localparam OP_LESS  = 4'd8;
	localparam OP_ULESS = 4'd9;
	assign operator = (opcode_type[INST_ADDI] | opcode_type[INST_ADD]) ? operator1 : OP_ADD;

	assign operator1 = (funct3 == 3'b000) ? operator2 :
										 (funct3 == 3'b001) ? OP_SLL : 
										 (funct3 == 3'b010) ? OP_LESS :
										 (funct3 == 3'b011) ? OP_ULESS :
										 (funct3 == 3'b100) ? OP_XOR :
										 (funct3 == 3'b101) ? operator3 :
										 (funct3 == 3'b110) ? OP_OR :
										 (funct3 == 3'b111) ? OP_AND :
										 OP_ADD;

	assign operator2 = (opcode_type[INST_ADD] & funct7_5) ? OP_SUB : OP_ADD;
	assign operator3 = funct7_5 ? OP_SRA : OP_SRL;

	assign {op_overflow, op_compare} = loperand - roperand;
	assign op_sum  = loperand + roperand;
	assign op_less = {(loperand[31] & ~roperand[31]) | ~(loperand[31] ^ roperand[31]) & op_compare[31]};
	assign op_uless = op_overflow;
	assign val_sra = {{{31{loperand[31]}}, loperand} >> (roperand & 32'h1f)};
	assign alu_val = (operator == OP_ADD  ) ? op_sum : 
									 (operator == OP_SUB  ) ? op_compare : 
									 (operator == OP_AND  ) ? (loperand & roperand) : 
									 (operator == OP_XOR  ) ? (loperand ^ roperand) :
									 (operator == OP_OR   ) ? (loperand | roperand) : 
									 (operator == OP_SRL  ) ? (loperand >> (roperand & 32'h1f)) : 
									 (operator == OP_SRA  ) ? val_sra[31:0] :
									 (operator == OP_SLL  ) ? (loperand << (roperand & 32'h1f)) : 
									 (operator == OP_LESS ) ? {31'b0, op_less} : 
									 (operator == OP_ULESS) ? {31'b0, op_uless} : 
									 32'b0;

	//jump
	assign jump_en = opcode_type[INST_JAL] | opcode_type[INST_JALR] | opcode_type[INST_BEQ] & jump_cond;
	assign exu_jump = op_sum;
	assign {overflow, compare} = src1 - src2;
	assign less = (src1[31] & ~src2[31]) | ~(src1[31] ^ src2[31]) & compare[31];
	assign unequal = |compare;
	assign uless = overflow;

	assign jump_cond = (funct3 == 3'b000) ? ~unequal : 
										 (funct3 == 3'b001) ? unequal : 
										 (funct3 == 3'b100) ? less : 
										 (funct3 == 3'b101) ? ~less :
										 (funct3 == 3'b110) ? uless : 
										 (funct3 == 3'b111) ? ~uless : 
										 1'b0;


	//write
	assign csr_wdata = (funct3 == 3'b010) ? (src1 | csr_val) : 
										 (funct3 == 3'b001) ? src1 :
										 32'b0;

	assign lsu_data = src2;

endmodule
