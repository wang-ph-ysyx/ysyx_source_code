import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(
	  input int waddr, input int wdata, input byte wmask);
module top(
	input clk,
	input reset,
	output [31:0] pc,
	output finished,
	output [31:0] halt_ret,
	output reg ifu_valid
);

	reg [31:0] inst;
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
	wire csr_enable;
	wire inst_ecall;
	wire inst_mret;
	wire [31:0] cause;

	wire [31:0] csr_wdata;
	wire [31:0] csr_val;
	wire [31:0] exu_val;
	wire [31:0] lsu_val;
	wire csr_wen;
	wire lsu_wen;
	wire lsu_ren;
	wire lsu_valid;
	wire idu_valid;
	wire wb_valid;
	wire [7:0] wmask;

	parameter TYPE_R = 3'd0,  TYPE_I = 3'd1, TYPE_S = 3'd2, TYPE_B = 3'd3, TYPE_U = 3'd4, TYPE_J = 3'd5;

	wire [31:0] csr_jump;
	wire [31:0] exu_jump;
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
		.din({32{wb_valid}} & dnpc | {32{~wb_valid}} & pc),
		.dout(pc),
		.wen(1'b1)
	);

	ifu my_ifu(
		.clk(clk),
		.reset(reset),
		.pc(pc),
		.inst(inst),
		.ifu_valid(ifu_valid),
		.idu_valid(idu_valid)
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
		.Type(Type),
		.lsu_ren(lsu_ren),
		.lsu_wen(lsu_wen),
		.idu_valid(idu_valid)
	);

	exu my_exu(
		.opcode(opcode),
		.src1(src1),
		.src2(src2),
		.imm(imm),
		.funct3(funct3),
		.funct7(funct7),
		.val(exu_val),
		.pc(pc),
		.jump(exu_jump),
		.csr_val(csr_val),
		.csr_wdata(csr_wdata),
		.wmask(wmask)
	);

	lsu my_lsu(
		.clk(clk),
		.raddr(src1 + imm),
		.ren(lsu_ren),
		.val(lsu_val),
		.waddr(src1 + imm),
		.wdata(src2),
		.wen(lsu_wen),
		.wmask(wmask),
		.valid(lsu_valid),
		.opcode(opcode),
		.funct3(funct3)
	);

	RegisterFile #(5, 32) my_reg(
		.clk(clk),
		.wdata(val),
		.waddr(rd),
		.rdata1(src1),
		.rdata2(src2),
		.raddr1(rs1),
		.raddr2(rs2),
		.wen(reg_wen),
		.halt_ret(halt_ret),
		.cause(cause),
		.valid(wb_valid)
	);

	CSRFile #(32) my_CSRreg(
		.clk(clk),
		.imm(imm[11:0]),
		.wdata(csr_wdata),
		.rdata(csr_val),
		.enable(csr_enable),
		.inst_ecall(inst_ecall),
		.epc(pc),
		.cause(cause),
		.jump(csr_jump),
		.inst_mret(inst_mret),
		.valid(wb_valid)
	);

	assign finished = (inst == 32'h00100073);
	assign inst_ecall = (inst == 32'h00000073);
	assign inst_mret = (inst == 32'h30200073);
	assign reg_wen = ((Type == TYPE_I) & {funct3, opcode} != 10'b0001110011) || (Type == TYPE_U) || (Type == TYPE_J) || (Type == TYPE_R);
	assign val = (exu_val | csr_val | lsu_val);
	assign csr_enable = (opcode == 7'b1110011) & (funct3 != 3'b000);
	assign jump = exu_jump | csr_jump;
	assign wb_valid = ~ifu_valid & (~lsu_ren | lsu_valid);

	always @(posedge clk) begin
		if (wb_valid) begin
			ifu_valid <= 1;
		end else begin
			ifu_valid <= 0;
		end
	end

endmodule
