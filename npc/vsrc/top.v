module top(
	input clk,
	input reset,
	input [31:0] inst,
	output [31:0] pc,
	output finished
);

	wire [31:0] next_pc;
	wire [6:0] opcode;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [31:0] imm;
	wire [31:0] src1;
	wire [31:0] val;
	wire [31:0] src2;
	wire [2:0] Type;
	wire reg_wen;

	parameter TYPE_R = 3'd0,  TYPE_I = 3'd1, TYPE_S = 3'd2, TYPE_B = 3'd3, TYPE_U = 3'd4, TYPE_J = 3'd5;

	wire [31:0] jump;
	wire [31:0] dnpc;
	wire [31:0] snpc;
	assign snpc = pc + 4;

	MuxKeyInternal #(1, 32, 32, 1) calculate_dnpc(
		.out(dnpc),
		.key(jump),
		.default_out(jump),
		.lut({
			32'b0, snpc
		})
	);

	Reg #(32, 32'h80000000) pc_adder(
		.clk(clk),
		.rst(reset),
		.din(dnpc),
		.dout(pc),
		.wen(1'b1)
	);

	idu my_idu(
		.in(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.rd(rd),
		.rs1(rs1),
		.rs2(rs2),
		.imm(imm),
		.Type(Type)
	);

	exu my_exu(
		.opcode(opcode),
		.src1(src1),
		.src2(src2),
		.imm(imm),
		.funct3(funct3),
		.funct7(funct7),
		.val(val),
		.pc(pc),
		.jump(jump)
	);

	RegisterFile #(5, 32) my_reg(
		.clk(clk),
		.wdata(val),
		.waddr(rd),
		.rdata1(src1),
		.rdata2(src2),
		.raddr1(rs1),
		.raddr2(rs2),
		.wen(reg_wen)
	);

	assign finished = (inst == 32'h00100073);
	assign reg_wen = (Type == TYPE_I) || (Type == TYPE_U) || (Type == TYPE_J) || (Type == TYPE_R);

endmodule
