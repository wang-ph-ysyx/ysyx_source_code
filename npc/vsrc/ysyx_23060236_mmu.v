module ysyx_23060236_mmu(
	input clock,
	input reset,

	input mmu_on,


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


	output        v_io_master_awready,
	input         v_io_master_awvalid,
	input  [31:0] v_io_master_awaddr,
	input  [3:0]  v_io_master_awid,
	input  [7:0]  v_io_master_awlen,
	input  [2:0]  v_io_master_awsize,
	input  [1:0]  v_io_master_awburst,

	output        v_io_master_wready,
	input         v_io_master_wvalid,
	input  [31:0] v_io_master_wdata,
	input  [3:0]  v_io_master_wstrb,
	input         v_io_master_wlast,

	input         v_io_master_bready,
	output        v_io_master_bvalid,
	output [1:0]  v_io_master_bresp,
	output [3:0]  v_io_master_bid,

	output        v_io_master_arready,
	input         v_io_master_arvalid,
	input  [31:0] v_io_master_araddr,
	input  [3:0]  v_io_master_arid,
	input  [7:0]  v_io_master_arlen,
	input  [2:0]  v_io_master_arsize,
	input  [1:0]  v_io_master_arburst,

	input         v_io_master_rready,
	output        v_io_master_rvalid,
	output [1:0]  v_io_master_rresp,
	output [31:0] v_io_master_rdata,
	output        v_io_master_rlast,
	output [3:0]  v_io_master_rid
);

	assign v_io_master_awready =   io_master_awready;
	assign   io_master_awvalid = v_io_master_awvalid;
	assign   io_master_awaddr  = v_io_master_awaddr;
	assign   io_master_awid    = v_io_master_awid;
	assign   io_master_awlen   = v_io_master_awlen;
	assign   io_master_awsize  = v_io_master_awsize;
	assign   io_master_awburst = v_io_master_awburst;

	assign v_io_master_wready  =   io_master_wready;
	assign   io_master_wvalid  = v_io_master_wvalid;
	assign   io_master_wdata   = v_io_master_wdata;
	assign   io_master_wstrb   = v_io_master_wstrb;
	assign   io_master_wlast   = v_io_master_wlast;

	assign   io_master_bready  = v_io_master_bready;
	assign v_io_master_bvalid  =   io_master_bvalid;
	assign v_io_master_bresp   =   io_master_bresp;
	assign v_io_master_bid     =   io_master_bid;

	assign v_io_master_arready =   io_master_arready;
	assign   io_master_arvalid = v_io_master_arvalid;
	assign   io_master_araddr  = v_io_master_araddr;
	assign   io_master_arid    = v_io_master_arid;
	assign   io_master_arlen   = v_io_master_arlen;
	assign   io_master_arsize  = v_io_master_arsize;
	assign   io_master_arburst = v_io_master_arburst;

	assign   io_master_rready  = v_io_master_rready;
	assign v_io_master_rvalid  =   io_master_rvalid;
	assign v_io_master_rresp   =   io_master_rresp;
	assign v_io_master_rdata   =   io_master_rdata;
	assign v_io_master_rlast   =   io_master_rlast;
	assign v_io_master_rid     =   io_master_rid;

endmodule
