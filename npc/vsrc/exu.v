import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);
module exu(
	input [6:0] opcode,
	input [31:0] src1,
	input [31:0] src2,
	input [31:0] imm,
	input [2:0] funct3,
	input [6:0] funct7,
	input [31:0] pc,
	output [31:0] val,
	output [31:0] jump);

	wire [31:0] val0;
	wire [31:0]	val1;
	wire [31:0] val2;

	wire [31:0] jump1;
	wire [31:0] jump2;

	wire valid, wen;
	wire [7:0] wmask;
	reg [31:0] rdata;
	always @(*) begin
		if (valid) begin
			rdata = pmem_read(src1 + imm);
			$display(rdata, '  ', src1 + imm);
			if (wen) begin
				pmem_write(src1 + imm, src2, wmask);
			end
		end
		else begin
			rdata = 0;
		end
	end

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

	MuxKeyInternal #(3, 10, 32, 1) calculate_val1(
		.out(val1),
		.key({funct3, opcode}),
		.default_out(32'b0),
		.lut({
			10'b0100000011, rdata,       //lw
			10'b0000010011, src1 + imm,  //addi
			10'b0001100111, pc + 4       //jalr
		})
	);

	MuxKeyInternal #(1, 17, 32, 1) calculate_val2(
		.out(val2),
		.key({funct7, funct3, opcode}),
		.default_out(32'b0),
		.lut({
			17'b00000000000110011, src1 + src2   //add
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

	MuxKeyInternal #(1, 10, 32, 1) calculate_jump2(
		.out(jump2),
		.key({funct3, opcode}),
		.default_out(32'b0),
		.lut({
			10'b0001100111, (src1 + imm) & (~32'b1)   //jalr
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

	assign val = val0 | val1 | val2;
	assign jump = jump1 | jump2;
	assign valid = ((opcode == 7'b0100011) || (opcode == 7'b0000011));
	assign wen = opcode == 7'b0100011;

endmodule
