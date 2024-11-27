`include "ysyx_23060236_defines.v"
module ysyx_23060236_exu(
	input  clock,
	input  reset,

	input  [9:0]  opcode_type,
	input  [4:0]  rd,
	input  [31:0] src1,
	input  [31:0] src2,
	input  [31:0] imm,
	input  [2:0]  funct3,
	input  [1:0]  funct7_50,
	input  [31:0] pc,
	input  [31:0] dnpc,
	input  reg_wen,
	input  csr_jump_en,
	input  [31:0] csr_jump,
	input  [31:0] csr_val,
	input  inst_fencei,

	output reg [2:0]  funct3_reg,
	output reg [4:0]  rd_next,
	output reg [31:0] pc_next,
	output reg reg_wen_next,
	output reg [31:0] jump_addr,
	output jump_wrong,
	output btb_wvalid,

	output [31:0] val,
	output lsu_ren,
	output lsu_wen,
	output [31:0] csr_wdata,
	output csr_enable,
	output inst_muldiv,
	output muldiv_outvalid,
	output [31:0] muldiv_val,

	input  exu_valid,
	output exu_ready,
	input  lsu_over,

	input time_intr
);

	wire [31:0] jump_addr_tmp;
	wire [31:0] alu_val;
	wire [31:0] snpc;
	wire [31:0] mul_val;
	wire [31:0] div_val;
	wire [31:0] mul_high;
	wire [31:0] mul_low;
	wire [31:0] div_res;
	wire [31:0] div_rem;
	wire [1:0]  mul_sign;
	wire div_sign;
	wire jump_en;
	wire jal_enable;
	wire inst_mul;
	wire inst_div;
	wire mul_ready;
	wire div_ready;
	wire mul_outvalid;
	wire div_outvalid;
	reg  need_btb;
	reg  jump_wrong_tmp;
	reg  inst_fencei_tmp;
	reg  exu_ready_reg;
	wire handshake;

	assign handshake = exu_valid & exu_ready & ~time_intr;
	assign inst_muldiv = opcode_type[INST_ADD] & funct7_50[0];
	assign inst_mul = inst_muldiv & ~funct3[2];
	assign inst_div = inst_muldiv & funct3[2];
	assign muldiv_outvalid = mul_outvalid | div_outvalid;
	assign btb_wvalid = jump_wrong & need_btb;
	assign snpc = pc + 4;
	assign csr_enable = opcode_type[INST_CSR] & (funct3 != 3'b0);
	assign jal_enable = opcode_type[INST_JAL] | opcode_type[INST_JALR];
	assign lsu_ren = opcode_type[INST_LW];
	assign lsu_wen = opcode_type[INST_SW];
	assign jump_wrong = inst_fencei_tmp | jump_wrong_tmp;
	assign exu_ready = exu_ready_reg & ~jump_wrong;
	assign muldiv_val = mul_outvalid ? mul_val : 
											div_outvalid ? div_val : 
											32'b0;
	assign mul_sign = (funct3[1:0] == 2'b11) ? 2'b00 : 
										(funct3[1:0] == 2'b10) ? 2'b10 : 
										2'b11;
	assign div_sign = ~funct3[0];
	assign mul_val = (funct3_reg[1:0] == 2'b00) ? mul_low : mul_high;
	assign div_val = funct3_reg[1] ? div_rem : div_res;

	// control signal register
	always @(posedge clock) begin
		if (reset) exu_ready_reg <= 1;
		else if (lsu_over) exu_ready_reg <= 1;
		else if (handshake) exu_ready_reg <= 0;
	end

	// data register
	always @(posedge clock) begin
		if (handshake) begin
			funct3_reg      <= funct3;
			rd_next         <= rd;
			reg_wen_next    <= reg_wen;
			pc_next         <= pc[31:0];
			need_btb        <= opcode_type[INST_BEQ] & imm[31] | opcode_type[INST_JAL];
			inst_fencei_tmp <= inst_fencei;
		end
		else begin
			inst_fencei_tmp <= 0;
		end

		if (exu_valid & exu_ready) begin
			jump_addr       <= jump_addr_tmp;
			jump_wrong_tmp  <= (jump_addr_tmp != dnpc);
		end
		else begin
			jump_wrong_tmp  <= 0;
		end
	end

	assign jump_addr_tmp = csr_jump_en ? csr_jump :
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

	wire [31:0] loperand;
	wire [31:0] roperand;
	wire [3:0]  operator;
	wire [3:0]  operator1;
	wire [3:0]  operator2;
	wire [3:0]  operator3;
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

	assign operator2 = (opcode_type[INST_ADD] & funct7_50[1]) ? OP_SUB : OP_ADD;
	assign operator3 = funct7_50[1] ? OP_SRA : OP_SRL;

	assign {op_overflow, op_compare} = loperand - roperand;
	assign op_sum  = loperand + roperand;
	assign op_less = {(loperand[31] & ~roperand[31]) | ~(loperand[31] ^ roperand[31]) & op_compare[31]};
	assign op_uless = op_overflow;
	assign val_sra = {{31{loperand[31]}}, loperand} >> roperand[4:0];
	assign alu_val = (operator == OP_ADD  ) ? op_sum : 
									 (operator == OP_SUB  ) ? op_compare : 
									 (operator == OP_AND  ) ? (loperand & roperand) : 
									 (operator == OP_XOR  ) ? (loperand ^ roperand) :
									 (operator == OP_OR   ) ? (loperand | roperand) : 
									 (operator == OP_SRL  ) ? (loperand >> roperand[4:0]) : 
									 (operator == OP_SRA  ) ? val_sra[31:0] :
									 (operator == OP_SLL  ) ? (loperand << roperand[4:0]) : 
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

	// mul/div
	ysyx_23060236_mul my_mul(
		.clock(clock),
		.reset(reset),
		.mul_valid(handshake & inst_mul),
		.mul_ready(mul_ready),
		.mul_sign(mul_sign),
		.mul1(src1),
		.mul2(src2),
		.mul_high(mul_high),
		.mul_low(mul_low),
		.mul_outvalid(mul_outvalid)
	);

	ysyx_23060236_div my_div(
		.clock(clock),
		.reset(reset),
		.div_valid(handshake & inst_div),
		.div_ready(div_ready),
		.div_sign(div_sign),
		.div1(src1),
		.div2(src2),
		.res(div_res),
		.rem(div_rem),
		.div_outvalid(div_outvalid)
	);

`ifndef SYN
import "DPI-C" function void add_div_cycle();
import "DPI-C" function void add_mul_cycle();

reg div_doing;
reg mul_doing;
always @(posedge clock) begin
	if (reset) mul_doing <= 0;
	else if (handshake & inst_mul & mul_ready) mul_doing <= 1;
	else if (mul_outvalid) mul_doing <= 0;

	if (reset) div_doing <= 0;
	else if (handshake & inst_div & div_ready) div_doing <= 1;
	else if (div_outvalid) div_doing <= 0;

	if (div_doing) add_div_cycle();
	if (mul_doing) add_mul_cycle();
end
`endif

endmodule
