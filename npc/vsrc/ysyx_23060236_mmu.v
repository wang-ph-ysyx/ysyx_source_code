module ysyx_23060236_mmu(
	input clock,
	input reset,

	input mmu_on,

	output        v_io_master_awready,
	input         v_io_master_awvalid,
	input  [31:0] v_io_master_awaddr,
	output        v_io_master_arready,
	input         v_io_master_arvalid,
	input  [31:0] v_io_master_araddr,

	input         io_master_awready,
	output        io_master_awvalid,
	output [31:0] io_master_awaddr,
	input         io_master_arready,
	output        io_master_arvalid,
	output [31:0] io_master_araddr
);

	assign v_io_master_awready =   io_master_awready;
	assign   io_master_awvalid = v_io_master_awvalid;
	assign   io_master_awaddr  = v_io_master_awaddr;
	assign v_io_master_arready =   io_master_arready;
	assign   io_master_arvalid = v_io_master_arvalid;
	assign   io_master_araddr  = v_io_master_araddr;

endmodule
