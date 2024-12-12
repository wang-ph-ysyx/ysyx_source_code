`include "ysyx_23060236_defines.v"
module ysyx_23060236_dcache(
	input					        clock,
	input                 reset,

	input  [ADDR_LEN-1:0] dcache_araddr,
	output [DATA_LEN-1:0] dcache_rdata,
	output                dcache_hit,  

	input  [ADDR_LEN-1:0] dcache_awaddr,
	input  [DATA_LEN-1:0] dcache_wdata,
	input                 dcache_wvalid,
	input                 dirty_data,

	output                    dcache_wdt,
	output reg [TAG_LEN-1:0]  dcache_reptag,
	output reg [DATA_LEN-1:0] dcache_repdata,

	input         flush
);

	localparam ADDR_LEN   = 32;
	localparam DATA_LEN   = 32;
	localparam OFFSET_LEN = 2;
	localparam INDEX_LEN  = 4;
	localparam TAG_LEN    = ADDR_LEN - OFFSET_LEN - INDEX_LEN;

	reg [DATA_LEN-1:0]     dcache_data [2**INDEX_LEN-1:0];
	reg [TAG_LEN-1:0]      dcache_tag  [2**INDEX_LEN-1:0];
	reg [2**INDEX_LEN-1:0] dcache_valid;
	reg [2**INDEX_LEN-1:0] dcache_dirty;

	wire [INDEX_LEN-1:0]  read_index;
	wire [TAG_LEN-1:0]    read_tag;
	wire [OFFSET_LEN-3:0] read_offset;
	wire [INDEX_LEN-1:0]  write_index;
	wire [TAG_LEN-1:0]    write_tag;
	wire [OFFSET_LEN-3:0] write_offset;

	assign read_tag     = dcache_araddr[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign read_index   = dcache_araddr[OFFSET_LEN+INDEX_LEN-1 : OFFSET_LEN];
	assign read_offset  = dcache_araddr[OFFSET_LEN-1 : 2];
	assign write_tag    = dcache_awaddr[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign write_index  = dcache_awaddr[OFFSET_LEN+INDEX_LEN-1 : OFFSET_LEN];
	assign write_offset = dcache_awaddr[OFFSET_LEN-1 : 2];
	assign dcache_hit   = dcache_valid[read_index] & (dcache_tag[read_index] == read_tag);
	assign dcache_rdata = dcache_data[read_index];

	assign dcache_wdt = dcache_valid[write_index] & dcache_dirty[write_index] & 
										  (dcache_tag[write_index] != write_tag);

	always @(posedge clock) begin
		if (dcache_wvalid) begin
			dcache_reptag  <= dcache_tag[write_index];
			dcache_repdata <= dcache_data[write_index];
		end
	end

	always @(posedge clock) begin
		if (reset | flush) dcache_valid <= 0;
		else if (dcache_wvalid) dcache_valid[write_index] <= 1'b1;
	end

	always @(posedge clock) begin
		if (reset | flush) dcache_dirty <= 0;
		else if (dcache_wvalid) dcache_dirty[write_index] <= dirty_data;
	end

	always @(posedge clock) begin
		if (dcache_wvalid) dcache_data[write_index] <= dcache_wdata;
	end

	always @(posedge clock) begin
		if (dcache_wvalid) dcache_tag[write_index] <= write_tag;
	end

endmodule
