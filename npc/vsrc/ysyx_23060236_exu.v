module ysyx_23060236_exu(
	input  clock,
	input  reset,

	input  [9:0]  opcode_type,
	input  [3:0]  rd,
	input  [31:0] src1,
	input  [31:0] src2,
	input  [31:0] imm,
	input  [2:0]  funct3,
	input  [6:0]  funct7,
	input  [31:0] pc,
	input  [31:0] csr_val,
	input  reg_wen,
	input  inst_ecall,
	input  inst_mret,
	input  csr_jump_en,
	input  [31:0] csr_jump,

	output reg [31:0] csr_val_next,
	output reg [3:0]  rd_next,
	output reg [31:0] pc_next,
	output reg [31:0] val,
	output reg [31:0] csr_wdata,
	output reg [3:0]  wmask,
	output reg [31:0] lsu_data,
	output reg [2:0]  funct3_next,
	output reg [11:0] csr_imm,
	output reg reg_wen_next,
	output reg lsu_ren,
	output reg lsu_wen,
	output reg csr_enable,
	output reg jal_enable,
	output reg inst_ecall_next,
	output reg [31:0] jump_addr,
	output reg jump_wrong,

	input  exu_valid,
	output exu_ready,
	output lsu_valid,
	input  lsu_ready
);

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
	wire [31:0] jump_addr_tmp;
	wire [31:0] val_tmp;
	wire [31:0] csr_wdata_tmp;
	wire [3:0]  wmask_tmp;
	wire [31:0] lsu_data_tmp;
	wire [31:0] snpc;

	assign snpc = pc + 4;
	assign jump_wrong_tmp = (jump_addr_tmp != snpc);

	always @(posedge clock) begin
		if (exu_valid & exu_ready) begin
			csr_val_next    <= csr_val;
			pc_next         <= pc;
			rd_next         <= rd;
			val             <= val_tmp;
      csr_wdata       <= csr_wdata_tmp;
      wmask           <= wmask_tmp;
      lsu_data        <= lsu_data_tmp;
			funct3_next     <= funct3;
			csr_imm         <= imm[11:0];
			lsu_ren         <= opcode_type[INST_LW];
			lsu_wen         <= opcode_type[INST_SW];
			csr_enable      <= opcode_type[INST_CSR] & (funct3 != 3'b0);
			jal_enable      <= opcode_type[INST_JAL] | opcode_type[INST_JALR];
			reg_wen_next    <= reg_wen;
			inst_ecall_next <= inst_ecall;
			jump_addr       <= jump_addr_tmp;
			jump_wrong      <= jump_wrong_tmp;
		end
		else begin
			jump_wrong <= 0;
		end
	end

	assign jump_addr_tmp = csr_jump_en ? csr_jump :
												 jump_en ? exu_jump :
												 snpc;

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

	assign operator2 = (opcode_type[INST_ADD] & funct7[5]) ? OP_SUB : OP_ADD;
	assign operator3 = funct7[5] ? OP_SRA : OP_SRL;

	assign {op_overflow, op_compare} = loperand - roperand;
	assign op_sum  = loperand + roperand;
	assign op_less = {(loperand[31] & ~roperand[31]) | ~(loperand[31] ^ roperand[31]) & op_compare[31]};
	assign op_uless = op_overflow;
	assign val_sra = {{{31{loperand[31]}}, loperand} >> (roperand & 32'h1f)};
	assign val_tmp = (operator == OP_ADD  ) ? op_sum : 
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
	assign wmask_tmp = (funct3[1:0] == 2'b00) ? 4'h1 : 
										 (funct3[1:0] == 2'b01) ? 4'h3 :
										 (funct3[1:0] == 2'b10) ? 4'hf : 
										 4'b0;

	assign csr_wdata_tmp = (funct3 == 3'b010) ? (src1 | csr_val) : 
												 (funct3 == 3'b001) ? src1 :
												 32'b0;

	assign lsu_data_tmp = src2;

endmodule
