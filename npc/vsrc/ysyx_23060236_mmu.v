`include "ysyx_23060236_defines.v"
module ysyx_23060236_mmu(
	input clock,
	input reset,

	input mmu_on,
	input [19:0] ppn,


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
	output [3:0]  v_io_master_rid,

	output [19:0] tlb_araddr,
	input  [19:0] tlb_rdata,
	output        tlb_rvalid,
	input         tlb_hit,
	output [19:0] tlb_awaddr,
	output [19:0] tlb_wdata,
	output reg    tlb_wvalid
);

	localparam IDLE   = 3'd0;
	localparam TLB    = 3'd1;
	localparam STAGE1 = 3'd2;
	localparam STAGE2 = 3'd3;
	localparam SEND   = 3'd4;

	wire [9:0] vpn1;
	wire [9:0] vpn0;
	wire [11:0] offset;

	assign vpn1 = reading ? v_io_master_araddr[31:22] : v_io_master_awaddr[31:22];
	assign vpn0 = reading ? v_io_master_araddr[21:12] : v_io_master_awaddr[21:12];
	assign offset = reading ? v_io_master_araddr[11:0] : v_io_master_awaddr[11:0];

	assign tlb_araddr = v_io_master_arvalid ? v_io_master_araddr[31:12] : v_io_master_awaddr[31:12];
	assign tlb_rvalid = (state == IDLE) & mmu_on & (v_io_master_arvalid | v_io_master_awvalid);

	reg  [2:0] state;
	reg  [2:0] next_state;
	reg  reading;

	reg  arvalid;
	reg  [31:0] address;

	// tlb write
	always @(posedge clock) begin
		if (reset) tlb_wvalid <= 0;
		else if ((state == STAGE2) & (io_master_rvalid & io_master_rready)) 
			tlb_wvalid <= 1;
		else tlb_wvalid <= 0;
	end

	assign tlb_awaddr = {vpn1, vpn0};
	assign tlb_wdata  = io_master_rdata[29:10];

	// state control signal register
	always @(posedge clock) begin
		if (reset) state <= IDLE;
		else state <= next_state;

		if (state == IDLE) begin
			if (v_io_master_awvalid) reading <= 0;
			else if (v_io_master_arvalid) reading <= 1;
		end
	end

	always @(*) begin
		case(state)
			IDLE:   next_state = mmu_on & (v_io_master_arvalid | v_io_master_awvalid) ? TLB : IDLE;
			TLB:    next_state = tlb_hit ? SEND : STAGE1;
			STAGE1: next_state = (io_master_rvalid & io_master_rready) ? STAGE2 : STAGE1;
			STAGE2: next_state = (io_master_rvalid & io_master_rready) ? SEND : STAGE2;
			SEND:   next_state = (io_master_rvalid & io_master_rready & io_master_rlast | 
														io_master_bvalid & io_master_bready & io_master_wlast) ? 
														IDLE : SEND;
			default: next_state = IDLE;
		endcase
	end


	// control signal register
	always @(posedge clock) begin
		if (reset) arvalid <= 0;
		else if (io_master_arvalid & io_master_arready) arvalid <= 0;
		else if ((state == TLB) & ~tlb_hit | 
						 (state == STAGE1) & io_master_rvalid & io_master_rready) arvalid <= 1;
	end

	// data register
	always @(posedge clock) begin
		if (state == TLB) begin
			if (tlb_hit) address <= {tlb_rdata, offset};
			else address <= {ppn, vpn1, 2'b0};
		end
		else if ((state == STAGE1) & io_master_rvalid & io_master_rready)
			address <= {io_master_rdata[29:10], vpn0, 2'b0};
		else if ((state == STAGE2) & io_master_rvalid & io_master_rready)
			address <= {io_master_rdata[29:10], offset};
	end

	assign v_io_master_awready = (~mmu_on | ~reading & (state == SEND)) ?   io_master_awready : 1'b0;
	assign   io_master_awvalid = (~mmu_on | ~reading & (state == SEND)) ? v_io_master_awvalid : 1'b0;
	assign   io_master_awaddr  = ~mmu_on ? v_io_master_awaddr : address;
	assign   io_master_awid    = v_io_master_awid;
	assign   io_master_awlen   = v_io_master_awlen;
	assign   io_master_awsize  = v_io_master_awsize;
	assign   io_master_awburst = v_io_master_awburst;

	assign v_io_master_wready  = (~mmu_on | ~reading & (state == SEND)) ?   io_master_wready : 1'b0;
	assign   io_master_wvalid  = (~mmu_on | ~reading & (state == SEND)) ? v_io_master_wvalid : 1'b0;
	assign   io_master_wdata   = v_io_master_wdata;
	assign   io_master_wstrb   = v_io_master_wstrb;
	assign   io_master_wlast   = v_io_master_wlast;

	assign   io_master_bready  = (~mmu_on | ~reading & (state == SEND)) ? v_io_master_bready : 1'b0;
	assign v_io_master_bvalid  = (~mmu_on | ~reading & (state == SEND)) ?   io_master_bvalid : 1'b0;
	assign v_io_master_bresp   =   io_master_bresp;
	assign v_io_master_bid     =   io_master_bid;

	assign v_io_master_arready = (~mmu_on | reading & (state == SEND)) ?   io_master_arready : 1'b0;
	assign   io_master_arvalid = (~mmu_on | reading & (state == SEND)) ? v_io_master_arvalid : arvalid;
	assign   io_master_araddr  = ~mmu_on ? v_io_master_araddr : address;
	assign   io_master_arid    = (~mmu_on | (state == SEND)) ? v_io_master_arid : 4'b0;
	assign   io_master_arlen   = (~mmu_on | (state == SEND)) ? v_io_master_arlen : 8'b0;
	assign   io_master_arsize  = (~mmu_on | (state == SEND)) ? v_io_master_arsize : 3'b010;
	assign   io_master_arburst = (~mmu_on | (state == SEND)) ? v_io_master_arburst : 2'b0;

	assign   io_master_rready  = (~mmu_on | reading & (state == SEND)) ? v_io_master_rready : 1'b1;
	assign v_io_master_rvalid  = (~mmu_on | reading & (state == SEND)) ?   io_master_rvalid : 1'b0;
	assign v_io_master_rresp   =   io_master_rresp;
	assign v_io_master_rdata   =   io_master_rdata;
	assign v_io_master_rlast   =   io_master_rlast;
	assign v_io_master_rid     =   io_master_rid;

`ifndef SYN

	import "DPI-C" function void add_hit_tlb();
	import "DPI-C" function void add_miss_tlb();
	
	always @(posedge clock) begin
		if (state == TLB) begin
			if (tlb_hit) add_hit_tlb();
			else add_miss_tlb();
		end
	end

`endif

endmodule
