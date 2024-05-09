module exu(
	input [6:0] opcode,
	input [31:0] src1,
	input [31:0] src2,
	input [31:0] imm,
	input [2:0] funct3,
	input [6:0] funct7,
	input [31:0] pc,
	output [31:0] val,
	output [31:0] jump,
	input [31:0] csr_val,
	output [31:0] csr_wdata,
	output [7:0] wmask);

	wire [31:0] val0;
	wire [31:0]	val1;
	wire [31:0] val2;

	wire [31:0] jump1;
	wire [31:0] jump2;

	wire [31:0] compare;

	reg [31:0] rdata;

	MuxKeyInternal #(3, 7, 32, 1) calculate_val0(
		.out(val0),
		.key(opcode),
		.default_out(32'b0),
		.lut({
			7'b0110111, imm,       //lui
			7'b0010111, pc + imm,  //auipc
			7'b1101111, pc + 4     //jal
		})
	);

	MuxKeyInternal #(6, 10, 32, 1) calculate_val1(
		.out(val1),
		.key({funct3, opcode}),
		.default_out(32'b0),
		.lut({
			10'b0000010011, src1 + imm,             //addi
			10'b0110010011, {31'b0, {src1 < imm}},  //sltiu
			10'b1000010011, src1 ^ imm,             //xori
			10'b1100010011, src1 | imm,             //ori
			10'b1110010011, src1 & imm,             //andi
			10'b0001100111, pc + 4                  //jalr
		})
	);

	MuxKeyInternal #(13, 17, 32, 1) calculate_val2(
		.out(val2),
		.key({funct7, funct3, opcode}),
		.default_out(32'b0),
		.lut({
			17'b00000000010010011, src1 << imm,             //slli
			17'b00000001010010011, src1 >> imm,             //srli
			17'b01000001010010011, ($signed(src1)) >>> (imm & 32'h1f), //srai
			17'b00000000000110011, src1 + src2,             //add
			17'b01000000000110011, src1 - src2,             //sub
			17'b00000000010110011, src1 << (0'h1f & src2),  //sll
			17'b00000000100110011, {31'b0, {(src1[31] & ~src2[31]) | ~(src1[31] ^ src2[31]) & compare[31]}},  //slt
			17'b00000000110110011, {31'b0, {src1 < src2}},  //sltu
			17'b00000001000110011, src1 ^ src2,             //xor
			17'b00000001010110011, src1 >> (src2 & 32'h1f), //srl
			17'b01000001010110011, ($signed(src1)) >>> (src2 & 32'h1f), //sra
			17'b00000001100110011, src1 | src2,             //or
			17'b00000001110110011, src1 & src2              //and
		})
	);


	MuxKeyInternal #(1, 7, 32, 1) calculate_jump1(
		.out(jump1),
		.key(opcode),
		.default_out(32'b0),
		.lut({
			7'b1101111, pc + imm  //jal
		})
	);

	MuxKeyInternal #(7, 10, 32, 1) calculate_jump2(
		.out(jump2),
		.key({funct3, opcode}),
		.default_out(32'b0),
		.lut({
			10'b0001100111, (src1 + imm) & (~32'b1),          //jalr
			10'b0001100011, (pc + imm) & (~{32{|compare}}),   //beq
			10'b0011100011, (pc + imm) & {32{|compare}},      //bne
			10'b1001100011, (pc + imm) & {32{(src1[31] & ~src2[31]) | ~(src1[31] ^ src2[31]) & compare[31]}},      //blt
			10'b1011100011, (pc + imm) & {32{(~src1[31] & src2[31]) | ~(src1[31] ^ src2[31]) & ~compare[31]}},      //bge
			10'b1101100011, (pc + imm) & {32{src1 < src2}},   //bltu
			10'b1111100011, (pc + imm) & {32{src1 >= src2}}   //bgeu
		})
	);

	MuxKeyInternal #(3, 10, 8, 1) calculate_wmask(
		.out(wmask),
		.key({funct3, opcode}),
		.default_out(8'b0),
		.lut({
			10'b0000100011, 8'h1, //sb
			10'b0010100011, 8'h3, //sh
			10'b0100100011, 8'hf  //sw
		})
	);

	MuxKeyInternal #(2, 10, 32, 1) calculate_csr_wdata(
		.out(csr_wdata),
		.key({funct3, opcode}),
		.default_out(32'b0),
		.lut({
			10'b0101110011, src1 | csr_val, //csrrs
			10'b0011110011, src1            //csrrw
		})
	);

	assign val = val0 | val1 | val2;
	assign jump = jump1 | jump2;
	assign compare = src1 - src2;

endmodule
