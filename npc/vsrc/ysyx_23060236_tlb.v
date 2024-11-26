`include "ysyx_23060236_defines.v"
module ysyx_23060236_tlb(
	input         clock,
	input         reset,

	input  [ADDR_LEN-1:0] tlb_araddr,
	output [DATA_LEN-1:0] tlb_rdata,
	output        tlb_hit,  

	input  [ADDR_LEN-1:0] tlb_awaddr,
	input  [DATA_LEN-1:0] tlb_wdata,
	input         tlb_wvalid,

	input         tlb_flush
);

	localparam ADDR_LEN   = 20;
	localparam DATA_LEN   = 20;
	localparam INDEX_LEN  = 2;
	localparam TAG_LEN    = ADDR_LEN - INDEX_LEN;
	localparam GROUP_SIZE = 2;

	reg [DATA_LEN-1:0]   tlb_data [2**INDEX_LEN-1:0][GROUP_SIZE-1:0];
	reg [TAG_LEN-1:0]    tlb_tag  [2**INDEX_LEN-1:0][GROUP_SIZE-1:0];
	reg [GROUP_SIZE-1:0] tlb_valid[2**INDEX_LEN-1:0];
	reg [0:0]            ex_index [2**INDEX_LEN-1:0];

	wire [INDEX_LEN-1:0] read_index;
	wire [TAG_LEN-1:0]   read_tag;
	wire [INDEX_LEN-1:0] write_index;
	wire [TAG_LEN-1:0]   write_tag;
	wire tlb_hit0;
	wire tlb_hit1;

	assign read_tag     = tlb_araddr[ADDR_LEN-1 : INDEX_LEN];
	assign read_index   = tlb_araddr[INDEX_LEN-1 : 0];
	assign write_tag    = tlb_awaddr[ADDR_LEN-1 : INDEX_LEN];
	assign write_index  = tlb_awaddr[INDEX_LEN-1 : 0];
	assign tlb_hit0  = tlb_valid[read_index][0] & (tlb_tag[read_index][0] == read_tag);
	assign tlb_hit1  = tlb_valid[read_index][1] & (tlb_tag[read_index][1] == read_tag);
	assign tlb_hit   = tlb_hit0 | tlb_hit1;
	assign tlb_rdata = tlb_hit0 ? tlb_data[read_index][0] : tlb_data[read_index][1];

	always @(posedge clock) begin
		if (reset) begin
			ex_index[0] <= 0;
			ex_index[1] <= 0;
			ex_index[2] <= 0;
			ex_index[3] <= 0;
		end
		else if (tlb_wvalid) ex_index[write_index] <= ex_index[write_index] + 1;
	end

	always @(posedge clock) begin
		if (reset | tlb_flush) begin
			tlb_valid[0] <= 0;
			tlb_valid[1] <= 0;
			tlb_valid[2] <= 0;
			tlb_valid[3] <= 0;
		end
		else if (tlb_wvalid) tlb_valid[write_index][ex_index[write_index]] <= 1'b1;
	end

	always @(posedge clock) begin
		if (tlb_wvalid) tlb_data[write_index][ex_index[write_index]] <= tlb_wdata;
	end

	always @(posedge clock) begin
		if (tlb_wvalid) tlb_tag[write_index][ex_index[write_index]]  <= write_tag;
	end

endmodule
