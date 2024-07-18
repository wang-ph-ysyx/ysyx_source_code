module ysyx_23060236(
	input  clock,
	input  reset,
	input  io_interrupt,

	input         io_master_awready,
	output        io_master_awvalid,
	output [31:0] io_master_awaddr,
	output [3:0]  io_master_awid,
	output [7:0]  io_master_awlen,
	output [2:0]  io_master_awsize,
	output [1:0]  io_master_awburst,

	input         io_master_wready,
	output        io_master_wvalid,
	output [63:0] io_master_wdata,
	output [7:0]  io_master_wstrb,
	output        io_master_wlast,

	output        io_master_bready,
	input         io_master_bvalid,
	input  [1:0]  io_master_bresp,
	input  [3:0]  io_master_bid,

	input         io_master_arready,
	output        io_master_arvalid,
	output [31:0] io_master_araddr,
	output [3:0]  io_master_arid,
	output [7:0]  io_master_arlen,
	output [2:0]  io_master_arsize,
	output [1:0]  io_master_arburst,

	output        io_master_rready,
	input         io_master_rvalid,
	input  [1:0]  io_master_rresp,
	input  [63:0] io_master_rdata,
	input         io_master_rlast,
	input  [3:0]  io_master_rid,

	output        io_slave_awready,
	input         io_slave_awvalid,
	input  [31:0] io_slave_awaddr,
	input  [3:0]  io_slave_awid,
	input  [7:0]  io_slave_awlen,
	input  [2:0]  io_slave_awsize,
	input  [1:0]  io_slave_awburst,

	output        io_slave_wready,
	input         io_slave_wvalid,
	input  [63:0] io_slave_wdata,
	input  [7:0]  io_slave_wstrb,
	input         io_slave_wlast,

	input         io_slave_bready,
	output        io_slave_bvalid,
	output [1:0]  io_slave_bresp,
	output [3:0]  io_slave_bid,

	output        io_slave_arready,
	input         io_slave_arvalid,
	input  [31:0] io_slave_araddr,
	input  [3:0]  io_slave_arid,
	input  [7:0]  io_slave_arlen,
	input  [2:0]  io_slave_arsize,
	input  [1:0]  io_slave_arburst,

	input         io_slave_rready,
	output        io_slave_rvalid,
	output [1:0]  io_slave_rresp,
	output [63:0] io_slave_rdata,
	output        io_slave_rlast,
	output [3:0]  io_slave_rid     
);

	wire [31:0] pc;
	wire wb_valid;

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
	wire [7:0] wmask;

	wire ifu_arvalid;
	wire [31:0] ifu_araddr;
	wire [63:0] ifu_rdata;
	wire ifu_arready;
	wire ifu_rvalid;
	wire [1:0] ifu_rresp;
	wire ifu_rready;
	wire lsu_arvalid;
	wire lsu_arready;
	wire [63:0] lsu_rdata;
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
	wire [2:0] lsu_arsize;
	wire [2:0] lsu_awsize;
	wire [7:0] lsu_wstrb;
	wire [31:0] lsu_awaddr;
	wire [31:0] lsu_araddr;
	wire [63:0] lsu_wdata;
	wire lsu_aligned_64;
	wire lsu_aligned_32;
	wire ifu_aligned;

	wire [31:0] clint_araddr;
	wire clint_arvalid;
	wire clint_arready;
	wire [31:0] clint_rdata;
	wire [1:0]  clint_rresp;
	wire clint_rvalid;
	wire clint_rready;

	parameter TYPE_R = 3'd0,  TYPE_I = 3'd1, TYPE_S = 3'd2, TYPE_B = 3'd3, TYPE_U = 3'd4, TYPE_J = 3'd5;

	wire [31:0] csr_jump;
	wire [31:0] exu_jump;
	wire [31:0] jump;
	wire [31:0] dnpc;
	wire [31:0] snpc;
	wire error;
	assign error = (|ifu_rresp) | (|lsu_rresp) | (|lsu_bresp);
	assign snpc = pc + 4;
	assign dnpc = (({32{|jump}} & jump) | (~{32{|jump}} & snpc)) & {32{~error}};

	ysyx_23060236_Reg #(32, 32'h30000000) pc_adder(
		.clock(clock),
		.reset(reset),
		.din(dnpc),
		.dout(pc),
		.wen(wb_valid)
	);

	ysyx_23060236_xbar my_xbar(
		.clock(clock),
		.reset(reset),
		.ifu_araddr(ifu_araddr),
		.ifu_arvalid(ifu_arvalid),
		.ifu_arready(ifu_arready),
		.ifu_rdata(ifu_rdata),
		.ifu_rresp(ifu_rresp),
		.ifu_rvalid(ifu_rvalid),
		.ifu_rready(ifu_rready),
		.lsu_araddr(lsu_araddr),
		.lsu_arvalid(lsu_arvalid),
		.lsu_arready(lsu_arready),
		.lsu_rdata(lsu_rdata),
		.lsu_rresp(lsu_rresp),
		.lsu_rvalid(lsu_rvalid),
		.lsu_rready(lsu_rready),
		.lsu_awaddr(lsu_awaddr),
		.lsu_awvalid(lsu_awvalid),
		.lsu_awready(lsu_awready),
		.lsu_wdata(lsu_wdata),
		.lsu_wstrb(lsu_wstrb),
		.lsu_wvalid(lsu_wvalid),
		.lsu_wready(lsu_wready),
		.lsu_bresp(lsu_bresp),
		.lsu_bvalid(lsu_bvalid),
		.lsu_bready(lsu_bready),
		.lsu_arsize(lsu_arsize),
		.lsu_awsize(lsu_awsize),
		.io_master_awready(io_master_awready),
    .io_master_awvalid(io_master_awvalid),
    .io_master_awaddr(io_master_awaddr),
    .io_master_awid(io_master_awid),
    .io_master_awlen(io_master_awlen),
    .io_master_awsize(io_master_awsize),
    .io_master_awburst(io_master_awburst),
    .io_master_wready(io_master_wready),
    .io_master_wvalid(io_master_wvalid),
    .io_master_wdata(io_master_wdata),
    .io_master_wstrb(io_master_wstrb),
    .io_master_wlast(io_master_wlast),
    .io_master_bready(io_master_bready),
    .io_master_bvalid(io_master_bvalid),
    .io_master_bresp(io_master_bresp),
    .io_master_bid(io_master_bid),
    .io_master_arready(io_master_arready),
    .io_master_arvalid(io_master_arvalid),
    .io_master_araddr(io_master_araddr),
    .io_master_arid(io_master_arid),
    .io_master_arlen(io_master_arlen),
    .io_master_arsize(io_master_arsize),
    .io_master_arburst(io_master_arburst),
    .io_master_rready(io_master_rready),
    .io_master_rvalid(io_master_rvalid),
    .io_master_rresp(io_master_rresp),
    .io_master_rdata(io_master_rdata),
    .io_master_rlast(io_master_rlast),
    .io_master_rid(io_master_rid),
		.clint_araddr(clint_araddr),
		.clint_arvalid(clint_arvalid),
		.clint_arready(clint_arready),
		.clint_rdata(clint_rdata),
		.clint_rresp(clint_rresp),
		.clint_rvalid(clint_rvalid),
		.clint_rready(clint_rready)
	);

	ysyx_23060236_clint my_clint(
		.clock(clock),
		.reset(reset),
		.araddr(clint_araddr),
		.arvalid(clint_arvalid),
		.arready(clint_arready),
		.rdata(clint_rdata),
		.rresp(clint_rresp),
		.rvalid(clint_rvalid),
		.rready(clint_rready)
	);

	ysyx_23060236_ifu my_ifu(
		.clock(clock),
		.reset(reset),
		.ifu_araddr(ifu_araddr),
		.ifu_arvalid(ifu_arvalid),
		.ifu_arready(ifu_arready),
		.ifu_rdata(ifu_rdata),
		.ifu_rresp(ifu_rresp),
		.ifu_rvalid(ifu_rvalid),
		.ifu_rready(ifu_rready),
		.wb_valid(wb_valid),
		.pc(pc),
		.inst(inst),
		.ifu_aligned(ifu_aligned),
		.idu_valid(idu_valid)
	);

	ysyx_23060236_idu my_idu(
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

	ysyx_23060236_exu my_exu(
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

	ysyx_23060236_lsu my_lsu(
		.clock(clock),
		.reset(reset),
		.lsu_araddr(lsu_araddr),
		.lsu_arvalid(lsu_arvalid),
		.lsu_arready(lsu_arready),
		.lsu_rdata(lsu_rdata),
		.lsu_rresp(lsu_rresp),
		.lsu_rvalid(lsu_rvalid),
		.lsu_rready(lsu_rready),
		.lsu_awaddr(lsu_awaddr),
		.lsu_awvalid(lsu_awvalid),
		.lsu_awready(lsu_awready),
		.lsu_wdata(lsu_wdata),
		.lsu_wstrb(lsu_wstrb),
		.lsu_wvalid(lsu_wvalid),
		.lsu_wready(lsu_wready),
		.lsu_bresp(lsu_bresp),
		.lsu_bvalid(lsu_bvalid),
		.lsu_bready(lsu_bready),
		.lsu_arsize(lsu_arsize),
		.lsu_awsize(lsu_awsize),
		.opcode(opcode),
		.funct3(funct3),
		.src1(src1),
		.src2(src2),
		.imm(imm),
		.wmask(wmask),
		.wb_valid(wb_valid),
		.lsu_ren(lsu_ren),
		.lsu_wen(lsu_wen),
		.lsu_aligned_64(lsu_aligned_64),
		.lsu_aligned_32(lsu_aligned_32),
		.lsu_val(lsu_val)
	);

	ysyx_23060236_RegisterFile #(5, 32) my_reg(
		.clock(clock),
		.wdata(val),
		.waddr(rd),
		.rdata1(src1),
		.rdata2(src2),
		.raddr1(rs1),
		.raddr2(rs2),
		.wen(reg_wen),
		.cause(cause),
		.valid(wb_valid)
	);

	ysyx_23060236_CSRFile #(32) my_CSRreg(
		.clock(clock),
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

	assign inst_ecall = (inst == 32'h00000073);
	assign inst_mret = (inst == 32'h30200073);
	assign reg_wen = ((Type == TYPE_I) & {funct3, opcode} != 10'b0001110011) || (Type == TYPE_U) || (Type == TYPE_J) || (Type == TYPE_R);
	assign val = (exu_val | csr_val | lsu_val);
	assign csr_enable = (opcode == 7'b1110011) & (funct3 != 3'b000);
	assign jump = exu_jump | csr_jump;

	ysyx_23060236_Reg #(1, 0) reg_wb_valid(
		.clock(clock),
		.reset(reset),
		.din(~wb_valid & (lsu_rvalid & lsu_rready | lsu_bvalid & lsu_bready | idu_valid & (opcode != 7'b0000011) & (opcode != 7'b0100011))),
		.dout(wb_valid),
		.wen(1)
	);

	assign io_slave_awready = 0;
	assign io_slave_wready  = 0;
	assign io_slave_bvalid  = 0;
	assign io_slave_bresp   = 0;
	assign io_slave_bid     = 0;
	assign io_slave_arready = 0;
	assign io_slave_rvalid  = 0;
	assign io_slave_rresp   = 0;
	assign io_slave_rdata   = 0;
	assign io_slave_rlast   = 0;
	assign io_slave_rid     = 0;

import "DPI-C" function void add_total_inst();
import "DPI-C" function void add_total_cycle();
import "DPI-C" function void add_lsu_getdata();
import "DPI-C" function void add_ifu_getinst();
/*
	always @(posedge clock) begin
		add_total_cycle();
		if (ifu_rvalid & ifu_rready) add_ifu_getinst();
		if (wb_valid) add_total_inst();
		if (lsu_rvalid & lsu_rready) add_lsu_getdata();
	end
*/
endmodule
