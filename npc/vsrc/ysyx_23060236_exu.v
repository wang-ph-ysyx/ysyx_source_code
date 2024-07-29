module ysyx_23060236_exu(
	input  [6:0]  opcode,
	input  [31:0] src1,
	input  [31:0] src2,
	input  [31:0] imm,
	input  [2:0]  Type,
	input  [2:0]  funct3,
	input  [6:0]  funct7,
	input  [31:0] pc,
	output [31:0] val,
	output [31:0] jump,
	input  [31:0] csr_val,
	output [31:0] csr_wdata,
	output [3:0]  wmask
);

	parameter TYPE_R = 3'd0;
	parameter TYPE_I = 3'd1;
	parameter TYPE_S = 3'd2;
	parameter TYPE_B = 3'd3;
	parameter TYPE_U = 3'd4;
	parameter TYPE_J = 3'd5; 

	wire [31:0] compare;
	wire overflow;
	wire less;
	wire unequal;
	wire uless;

	wire [31:0] op_compare;
	wire op_overflow;
	wire op_less;
	wire op_uless;

	wire [31:0] loperand;
	wire [31:0] roperand;
	wire [3:0] operator;
	wire [3:0] operator1;
	wire [3:0] operator2;
	wire [3:0] operator3;
	wire [3:0] operator4;
	wire [31:0] jloperand;
	wire [31:0] jroperand;
	wire jump_cond;
	wire jump_en;

	//exu_val
	assign loperand = (opcode == 7'b0110111) ? 32'b0 : 
										(opcode == 7'b0010111) ? pc :
										(opcode == 7'b1101111) ? pc :
										(opcode == 7'b1100111) ? pc :
										(opcode == 7'b0010011) ? src1 :
										(opcode == 7'b0110011) ? src1 : 
										32'b0;

	assign roperand = (opcode == 7'b0110111) ? imm :
										(opcode == 7'b0010111) ? imm :
										(opcode == 7'b1101111) ? 32'd4 :
										(opcode == 7'b1100111) ? 32'd4 :
										(opcode == 7'b0010011) ? imm :
										(opcode == 7'b0110011) ? src2 :
										32'd0;

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
	assign operator = ((Type == TYPE_I) | (Type == TYPE_R)) ? operator1 : OP_ADD;

	assign operator1 = (funct3 == 3'b000) ? operator2 :
										 (funct3 == 3'b001) ? OP_SLL : 
										 (funct3 == 3'b010) ? OP_LESS :
										 (funct3 == 3'b011) ? OP_ULESS :
										 (funct3 == 3'b100) ? OP_XOR :
										 (funct3 == 3'b101) ? operator3 :
										 (funct3 == 3'b110) ? OP_OR :
										 (funct3 == 3'b111) ? OP_AND :
										 OP_ADD;

	assign operator2 = (Type == TYPE_R & funct7[5]) ? OP_SUB : OP_ADD;
	assign operator3 = funct7[5] ? OP_SRA : OP_SRL;

	assign {op_overflow, op_compare} = loperand - roperand;
	assign op_less = {(loperand[31] & ~roperand[31]) | ~(loperand[31] ^ roperand[31]) & op_compare[31]};
	assign op_uless = op_overflow;
	ysyx_23060236_MuxKeyInternal #(10, 4, 32, 1) calculate_val(
		.out(val),
		.key(operator),
		.default_out(32'b0),
		.lut({
			OP_ADD,   loperand + roperand,
			OP_SUB,   op_compare,
			OP_AND,   loperand & roperand,
			OP_XOR,   loperand ^ roperand,
			OP_OR,    loperand | roperand,
			OP_SRL,   loperand >> (roperand & 32'h1f),
			OP_SRA,   ($signed(loperand)) >>> (roperand & 32'h1f),
			OP_SLL,   loperand << (roperand & 32'h1f),
			OP_LESS,  {31'b0, op_less},
			OP_ULESS, {31'b0, op_uless}
		})
	);


	//jump
	assign jloperand = (Type == TYPE_I) ? src1 : pc;
	assign jroperand = imm;
	assign jump = {jloperand + jroperand} & {32{jump_en}};
	assign jump_en = (Type == TYPE_J) | (opcode == 7'b1100111) | (Type == TYPE_B) & jump_cond;
	assign {overflow, compare} = src1 - src2;
	assign less = (src1[31] & ~src2[31]) | ~(src1[31] ^ src2[31]) & compare[31];
	assign unequal = |compare;
	assign uless = overflow;

	ysyx_23060236_MuxKeyInternal #(6, 3, 1, 1) calculate_jump_cond(
		.out(jump_cond),
		.key(funct3),
		.default_out(1'b0),
		.lut({
			3'b000, ~unequal,  //beq
			3'b001, unequal,   //bne
			3'b100, less,      //blt
			3'b101, ~less,     //bge
			3'b110, uless,     //bltu
			3'b111, ~uless     //bgeu
		})
	);


	//write
	ysyx_23060236_MuxKeyInternal #(3, 2, 4, 1) calculate_wmask(
		.out(wmask),
		.key(funct3[1:0]),
		.default_out(4'b0),
		.lut({
			2'b00, 4'h1, //sb
			2'b01, 4'h3, //sh
			2'b10, 4'hf  //sw
		})
	);

	ysyx_23060236_MuxKeyInternal #(2, 3, 32, 1) calculate_csr_wdata(
		.out(csr_wdata),
		.key(funct3),
		.default_out(32'b0),
		.lut({
			3'b010, src1 | csr_val, //csrrs
			3'b001, src1            //csrrw
		})
	);

endmodule
