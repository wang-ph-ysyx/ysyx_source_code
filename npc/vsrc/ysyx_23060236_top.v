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
	output [31:0] io_master_wdata,
	output [3:0]  io_master_wstrb,
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
	input  [31:0] io_master_rdata,
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
	input  [31:0] io_slave_wdata,
	input  [3:0]  io_slave_wstrb,
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
	output [31:0] io_slave_rdata,
	output        io_slave_rlast,
	output [3:0]  io_slave_rid     
);

	wire [31:0] ifu_pc;
	wire [31:0] idu_pc;
	wire [31:0] exu_pc;
	wire [31:0] lsu_pc;
	wire [31:0] jump_addr;
	wire idu_valid;
	wire idu_ready;
	wire exu_valid;
	wire exu_ready;
	wire lsu_valid;
	wire lsu_ready;
	wire wb_valid;
	wire jal_enable;

	wire [31:0] inst;
	wire [9:0]  opcode_type;
	wire [3:0]  rs1;
	wire [3:0]  rs2;
	wire [3:0]  idu_rd;
	wire [3:0]  exu_rd;
	wire [3:0]  lsu_rd;
	wire [2:0]  funct3;
	wire [6:0]  funct7;
	wire [31:0] imm;
	wire [31:0] src1;
	wire [31:0] wb_val;
	wire [31:0] src2;
	wire idu_reg_wen;
	wire exu_reg_wen;
	wire lsu_reg_wen;
	wire exu_csr_enable;
	wire lsu_csr_enable;
	wire idu_inst_ecall;
	wire idu_inst_mret;
	wire exu_inst_ecall;
	wire exu_inst_mret;
	wire lsu_inst_ecall;
	wire lsu_inst_mret;
	wire inst_fencei;

	wire [31:0] csr_jump;
	wire csr_jump_en;
	wire exu_jump_en;

	wire [31:0] exu_csr_wdata;
	wire [31:0] lsu_csr_wdata;
	wire [31:0] csr_val;
	wire [31:0] exu_csr_val;
	wire [31:0] exu_val;
	wire [31:0] lsu_val;
	wire csr_wen;
	wire lsu_wen;
	wire lsu_ren;
	wire [3:0] wmask;
	wire [11:0] exu_csr_imm;
	wire [11:0] lsu_csr_imm;

	wire        ifu_arvalid;
	wire [31:0] ifu_araddr;
	wire [31:0] ifu_rdata;
	wire        ifu_arready;
	wire        ifu_rvalid;
	wire [1:0]  ifu_rresp;
	wire        ifu_rready;
	wire [1:0]  ifu_arburst;
	wire [3:0]  ifu_arlen;

	wire [2:0]  exu_funct3;

	wire [31:0] lsu_data;
	wire [31:0] lsu_araddr;
	wire        lsu_arvalid;
	wire        lsu_arready;
	wire [31:0] lsu_rdata;
	wire [1:0]  lsu_rresp;
	wire        lsu_rvalid;
	wire        lsu_rready;
	wire [31:0] lsu_awaddr;
	wire        lsu_awvalid;
	wire        lsu_awready;
	wire [31:0] lsu_wdata;
	wire [3:0]  lsu_wstrb;
	wire        lsu_wvalid;
	wire        lsu_wready;
	wire [1:0]  lsu_bresp;
	wire        lsu_bvalid;
	wire        lsu_bready;
	wire [2:0]  lsu_arsize;
	wire [2:0]  lsu_awsize;

	wire [31:0] clint_araddr;
	wire        clint_arvalid;
	wire        clint_arready;
	wire [31:0] clint_rdata;
	wire [1:0]  clint_rresp;
	wire        clint_rvalid;
	wire        clint_rready;

	wire [31:0] icache_araddr;
	wire        icache_arvalid;
	wire        icache_arready;
	wire [31:0] icache_rdata;
	wire [1:0]  icache_rresp;
	wire        icache_rvalid;
	wire        icache_rready;
	wire [31:0] icache_awaddr;
	wire        icache_awvalid;
	wire        icache_awready;
	wire [31:0] icache_wdata;
	wire [3:0]  icache_wstrb;
	wire        icache_wvalid;
	wire        icache_wready;
	wire [1:0]  icache_bresp;
	wire        icache_bvalid;
	wire        icache_bready;

	ysyx_23060236_xbar my_xbar(
		.clock(clock),
		.reset(reset),
		.ifu_araddr(ifu_araddr),
		.ifu_arvalid(ifu_arvalid),
		.ifu_arready(ifu_arready),
		.ifu_arlen(ifu_arlen),
		.ifu_arburst(ifu_arburst),
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

	ysyx_23060236_icache my_icache(
		.clock(clock),
		.reset(reset),
		.icache_araddr(icache_araddr),
		.icache_arvalid(icache_arvalid),
		.icache_arready(icache_arready),
		.icache_rdata(icache_rdata),
		.icache_rresp(icache_rresp),
		.icache_rvalid(icache_rvalid),
		.icache_rready(icache_rready),
		.icache_awaddr(icache_awaddr),
		.icache_awvalid(icache_awvalid),
		.icache_awready(icache_awready),
		.icache_wdata(icache_wdata),
		.icache_wstrb(icache_wstrb),
		.icache_wvalid(icache_wvalid),
		.icache_wready(icache_wready),
		.icache_bresp(icache_bresp),
		.icache_bvalid(icache_bvalid),
		.icache_bready(icache_bready),
		.inst_fencei(inst_fencei)
	);

	ysyx_23060236_ifu my_ifu(
		.clock(clock),
		.reset(reset),
		.ifu_araddr(ifu_araddr),
		.ifu_arvalid(ifu_arvalid),
		.ifu_arready(ifu_arready),
		.ifu_arlen(ifu_arlen),
		.ifu_arburst(ifu_arburst),
		.ifu_rdata(ifu_rdata),
		.ifu_rresp(ifu_rresp),
		.ifu_rvalid(ifu_rvalid),
		.ifu_rready(ifu_rready),
		.icache_araddr(icache_araddr),
		.icache_arvalid(icache_arvalid),
		.icache_arready(icache_arready),
		.icache_rdata(icache_rdata),
		.icache_rresp(icache_rresp),
		.icache_rvalid(icache_rvalid),
		.icache_rready(icache_rready),
		.icache_awaddr(icache_awaddr),
		.icache_awvalid(icache_awvalid),
		.icache_awready(icache_awready),
		.icache_wdata(icache_wdata),
		.icache_wstrb(icache_wstrb),
		.icache_wvalid(icache_wvalid),
		.icache_wready(icache_wready),
		.icache_bresp(icache_bresp),
		.icache_bvalid(icache_bvalid),
		.icache_bready(icache_bready),
		.wb_valid(wb_valid),
		.pc(ifu_pc),
		.jump_addr(jump_addr),
		.inst(inst),
		.idu_valid(idu_valid),
		.idu_ready(idu_ready)
	);

	ysyx_23060236_idu my_idu(
		.clock(clock),
		.reset(reset),
		.in(inst),
		.pc(ifu_pc),
		.pc_next(idu_pc),
		.opcode_type(opcode_type),
		.funct3(funct3),
		.funct7(funct7),
		.rd(idu_rd),
		.rs1(rs1),
		.rs2(rs2),
		.imm(imm),
		.reg_wen(idu_reg_wen),
		.inst_ecall(idu_inst_ecall),
		.inst_mret(idu_inst_mret),
		.inst_fencei(inst_fencei),
		.idu_valid(idu_valid),
		.idu_ready(idu_ready),
		.exu_valid(exu_valid),
		.exu_ready(exu_ready)
	);

	ysyx_23060236_exu my_exu(
		.clock(clock),
		.reset(reset),
		.opcode_type(opcode_type),
		.rd(idu_rd),
		.src1(src1),
		.src2(src2),
		.imm(imm),
		.funct3(funct3),
		.funct7(funct7),
		.pc(idu_pc),
		.csr_val(csr_val),
		.reg_wen(idu_reg_wen),
		.inst_ecall(idu_inst_ecall),
		.inst_mret(idu_inst_mret),
		.csr_val_next(exu_csr_val),
		.rd_next(exu_rd),
		.pc_next(exu_pc),
		.val(exu_val),
		.jump_en(exu_jump_en),
		.csr_wdata(exu_csr_wdata),
		.wmask(wmask),
		.lsu_data(lsu_data),
		.funct3_next(exu_funct3),
		.lsu_ren(lsu_ren),
		.lsu_wen(lsu_wen),
		.csr_imm(exu_csr_imm),
		.reg_wen_next(exu_reg_wen),
		.csr_enable(exu_csr_enable),
		.jal_enable(jal_enable),
		.inst_ecall_next(exu_inst_ecall),
		.inst_mret_next(exu_inst_mret),
		.exu_valid(exu_valid),
		.exu_ready(exu_ready),
		.lsu_valid(lsu_valid),
		.lsu_ready(lsu_ready)
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
		.funct3(exu_funct3),
		.lsu_data(lsu_data),
		.wmask(wmask),
		.rd(exu_rd),
		.exu_val(exu_val),
		.csr_val(exu_csr_val),
		.lsu_ren(lsu_ren),
		.lsu_wen(lsu_wen),
		.pc(exu_pc),
		.csr_wdata(exu_csr_wdata),
		.csr_jump(csr_jump),
		.csr_imm(exu_csr_imm),
		.csr_enable(exu_csr_enable),
		.jal_enable(jal_enable),
		.reg_wen(exu_reg_wen),
		.exu_jump_en(exu_jump_en),
		.csr_jump_en(csr_jump_en),
		.inst_ecall(exu_inst_ecall),
		.inst_mret(exu_inst_mret),
		.pc_next(lsu_pc),
		.reg_wen_next(lsu_reg_wen),
		.rd_next(lsu_rd),
		.wb_val(wb_val),
		.jump_addr(jump_addr),
		.csr_enable_next(lsu_csr_enable),
		.csr_imm_next(lsu_csr_imm),
		.csr_wdata_next(lsu_csr_wdata),
		.inst_ecall_next(lsu_inst_ecall),
		.inst_mret_next(lsu_inst_mret),
		.lsu_valid(lsu_valid),
		.lsu_ready(lsu_ready),
		.wb_valid(wb_valid)
	);

	ysyx_23060236_RegisterFile #(4, 32) my_reg(
		.clock(clock),
		.reset(reset),
		.wdata(wb_val),
		.waddr(lsu_rd),
		.rdata1(src1),
		.rdata2(src2),
		.raddr1(rs1),
		.raddr2(rs2),
		.wen(lsu_reg_wen),
		.valid(wb_valid)
	);

	ysyx_23060236_CSRFile #(32) my_CSRreg(
		.clock(clock),
		.reset(reset),
		.read_imm(imm[11:0]),
		.write_imm(lsu_csr_imm),
		.wdata(lsu_csr_wdata),
		.rdata(csr_val),
		.enable(lsu_csr_enable),
		.inst_ecall(exu_inst_ecall),
		.inst_ecall_write(lsu_inst_ecall),
		.inst_mret(exu_inst_mret),
		.epc(lsu_pc),
		.jump(csr_jump),
		.jump_en(csr_jump_en),
		.valid(wb_valid)
	);
/*
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
*/
/*
import "DPI-C" function void add_total_inst();
import "DPI-C" function void add_total_cycle();
import "DPI-C" function void add_lsu_getdata();
import "DPI-C" function void add_ifu_getinst();
import "DPI-C" function void add_lsu_writedata();

	always @(posedge clock) begin
		add_total_cycle();
		if (ifu_rvalid & ifu_rready | icache_rvalid & icache_rready & ~icache_rresp[1]) add_ifu_getinst();
		if (wb_valid) add_total_inst();
		if (lsu_rvalid & lsu_rready) add_lsu_getdata();
		if (lsu_bvalid & lsu_bready) add_lsu_writedata();
	end

import "DPI-C" function void record_lsu_awaddr(input int lsu_awaddr);

	always @(posedge clock) begin
		record_lsu_awaddr(lsu_awaddr);
	end
*/
endmodule
