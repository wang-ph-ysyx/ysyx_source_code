import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(
	  input int waddr, input int wdata, input byte wmask);
module top(
	input clk,
	input reset,
	output [31:0] pc,
	output finished,
	output [31:0] halt_ret,
	output wb_valid
);

	wire [31:0] inst;
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
	wire ifu_arvalid;
	wire [7:0] wmask;

	wire [31:0] ifu_rdata;
	wire ifu_arready;
	wire ifu_rvalid;
	wire [1:0] ifu_rresp;
	wire ifu_rready;
	wire lsu_arvalid;
	wire lsu_arready;
	wire [31:0] lsu_rdata;
	wire [1:0] lsu_rresp;
	wire lsu_rvalid;
	wire lsu_rready;
	wire lsu_awvalid;
	wire lsu_awready;
	wire lsu_wvalid;
	wire lsu_wready;
	wire [1:0] lsu_bresp;
	wire lsu_bvalid;
	wire lsu_bready;

	wire [31:0] araddr;
	wire arvalid;
	wire arready;
	wire [31:0] rdata;
	wire [1:0]  rresp;
	wire rvalid;
	wire rready;
	wire [31:0] awaddr;
	wire awvalid;
	wire awready;
	wire [31:0] wdata;
	wire [3:0]  wstrb;
	wire wvalid;
	wire wready;
	wire [1:0] bresp;
	wire bvalid;
	wire bready;

	parameter TYPE_R = 3'd0,  TYPE_I = 3'd1, TYPE_S = 3'd2, TYPE_B = 3'd3, TYPE_U = 3'd4, TYPE_J = 3'd5;

	wire [31:0] csr_jump;
	wire [31:0] exu_jump;
	wire [31:0] jump;
	wire [31:0] dnpc;
	wire [31:0] snpc;
	assign snpc = pc + 4;
	assign dnpc = ({32{|jump}} & jump) | (~{32{|jump}} & snpc);

	Reg #(32, 32'h80000000) pc_adder(
		.clk(clk),
		.rst(reset),
		.din(dnpc),
		.dout(pc),
		.wen(wb_valid)
	);

	wire [7:0] random;
	lfsr gen_random(
		.clk(clk),
		.reset(reset),
		.enable(wb_valid),
		.random(random)
	);

	xbar my_xbar(
		.clk(clk),
		.reset(reset),
		.ifu_araddr(pc),
		.ifu_arvalid(ifu_arvalid),
		.ifu_arready(ifu_arready),
		.ifu_rdata(ifu_rdata),
		.ifu_rresp(ifu_rresp),
		.ifu_rvalid(ifu_rvalid),
		.ifu_rready(ifu_rready),
		.lsu_araddr(src1 + imm),
		.lsu_arvalid(lsu_arvalid),
		.lsu_arready(lsu_arready),
		.lsu_rdata(lsu_rdata),
		.lsu_rresp(lsu_rresp),
		.lsu_rvalid(lsu_rvalid),
		.lsu_rready(lsu_rready),
		.lsu_awaddr(src1 + imm),
		.lsu_awvalid(lsu_awvalid),
		.lsu_awready(lsu_awready),
		.lsu_wdata(src2),
		.lsu_wstrb(wmask[3:0]),
		.lsu_wvalid(lsu_wvalid),
		.lsu_wready(lsu_wready),
		.lsu_bresp(lsu_bresp),
		.lsu_bvalid(lsu_bvalid),
		.lsu_bready(lsu_bready),
		.araddr(araddr),
		.arvalid(arvalid),
		.arready(arready),
		.rdata(rdata),
		.rresp(rresp),
		.rvalid(rvalid),
		.rready(rready),
		.awaddr(awaddr),
		.awvalid(awvalid),
		.awready(awready),
		.wdata(wdata),
		.wstrb(wstrb),
		.wvalid(wvalid),
		.wready(wready),
		.bresp(bresp),
		.bvalid(bvalid),
		.bready(bready)
	);

	sram my_sram(
		.clk(clk),
		.reset(reset),
		.araddr(araddr),
		.arvalid(arvalid),
		.arready(arready),
		.rdata(rdata),
		.rresp(rresp),
		.rvalid(rvalid),
		.rready(rready),
		.awaddr(awaddr),
		.awvalid(awvalid),
		.awready(awready),
		.wdata(wdata),
		.wstrb(wstrb),
		.wvalid(wvalid),
		.wready(wready),
		.bresp(bresp),
		.bvalid(bvalid),
		.bready(bready),
		.random(random)
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

	MuxKeyInternal #(5, 10, 32, 1) caculate_lsu_val(
		.out(lsu_val),
		.key({funct3, opcode}),
		.default_out(32'b0),
		.lut({
			10'b0000000011, (lsu_rdata & 32'hff) | {{24{lsu_rdata[7]}}, 8'h0},     //lb
			10'b0010000011, (lsu_rdata & 32'hffff) | {{16{lsu_rdata[15]}}, 16'h0}, //lh
			10'b0100000011, lsu_rdata,                                             //lw
			10'b1000000011, lsu_rdata & 32'hff,                                    //lbu
			10'b1010000011, lsu_rdata & 32'hffff                                   //lhu
		})
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
	assign ifu_rready = 1;
	assign lsu_rready = 1;
	assign lsu_bready = 1;

	Reg #(32, 0) reg_inst(
		.clk(clk),
		.rst(reset),
		.din(ifu_rdata),
		.dout(inst),
		.wen(ifu_rvalid & ifu_rready)
	);

	Reg #(1, 0) reg_idu_valid(
		.clk(clk),
		.rst(reset),
		.din(~idu_valid & ifu_rvalid & ifu_rready),
		.dout(idu_valid),
		.wen(1)
	);

	Reg #(1, 0) reg_lsu_arvalid(
		.clk(clk),
		.rst(reset),
		.din(lsu_arvalid & ~lsu_arready | ~lsu_arvalid & lsu_ren),
		.dout(lsu_arvalid),
		.wen(1)
	);

	Reg #(1, 0) reg_lsu_awvalid(
		.clk(clk),
		.rst(reset),
		.din(lsu_awvalid & ~lsu_awready | ~lsu_awvalid & lsu_wen),
		.dout(lsu_awvalid),
		.wen(1)
	);

	Reg #(1, 0) reg_lsu_wvalid(
		.clk(clk),
		.rst(reset),
		.din(lsu_wvalid & ~lsu_wready | ~lsu_wvalid & lsu_wen),
		.dout(lsu_wvalid),
		.wen(1)
	);

	Reg #(1, 0) reg_wb_valid(
		.clk(clk),
		.rst(reset),
		.din(~wb_valid & (lsu_rvalid & lsu_rready | lsu_bvalid & lsu_bready | idu_valid & (opcode != 7'b0000011) & (opcode != 7'b0100011))),
		.dout(wb_valid),
		.wen(1)
	);

	Reg #(1, 1) reg_ifu_arvalid(
		.clk(clk),
		.rst(reset),
		.din(ifu_arvalid & ~ifu_arready | ~ifu_arvalid & wb_valid),
		.dout(ifu_arvalid),
		.wen(1)
	);

endmodule
