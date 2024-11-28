`include "ysyx_23060236_defines.v"
module ysyx_23060236_btb(
	input clock,
	input reset,

	input  [DATA_LEN-1:0] btb_araddr,
	output [DATA_LEN-1:0] btb_rdata,
	input  [DATA_LEN-1:0] btb_araddr_exu,
	output [DATA_LEN-1:0] btb_rdata_exu,

	input  btb_wvalid,
	input  [ADDR_LEN-1:0] btb_awaddr,
	input  [DATA_LEN-1:0] btb_wdata
);

	localparam ADDR_LEN   = 32;
	localparam DATA_LEN   = 32;
	localparam OFFSET_LEN = 2;
	localparam INDEX_LEN  = 1;
	localparam TAG_LEN    = ADDR_LEN - OFFSET_LEN - INDEX_LEN;

	reg [DATA_LEN-1:0]     btb_data [2**INDEX_LEN-1:0];
	reg [TAG_LEN-1:0]      btb_tag  [2**INDEX_LEN-1:0];
	reg [2**INDEX_LEN-1:0] btb_valid;

	wire btb_hit;
	wire [TAG_LEN-1:0]   read_tag;
	wire [INDEX_LEN-1:0] read_index;
	wire [TAG_LEN-1:0]   write_tag;
	wire [INDEX_LEN-1:0] write_index;
	wire btb_hit_exu;
	wire [TAG_LEN-1:0]   read_tag_exu;
	wire [INDEX_LEN-1:0] read_index_exu;

	assign read_tag     = btb_araddr[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign read_index   = btb_araddr[INDEX_LEN-1 : 0];
	assign write_tag    = btb_awaddr[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign write_index  = btb_awaddr[INDEX_LEN-1 : 0];
	assign btb_hit      = btb_valid[read_index] & (btb_tag[read_index] == read_tag);
	assign btb_rdata    = btb_hit ? btb_data[read_index] : (btb_araddr + 4);

	assign read_tag_exu   = btb_araddr_exu[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign read_index_exu = btb_araddr_exu[INDEX_LEN-1 : 0];
	assign btb_hit_exu    = btb_valid[read_index_exu] & (btb_tag[read_index_exu] == read_tag_exu);
	assign btb_rdata_exu  = btb_hit_exu ? btb_data[read_index_exu] : (btb_araddr_exu + 4);

	always @(posedge clock) begin
		if (reset) btb_valid <= 0;
		else if (btb_wvalid) btb_valid[write_index] <= 1'b1;
	end

	always @(posedge clock) begin
		if (btb_wvalid) btb_data[write_index] <= btb_wdata;
	end

	always @(posedge clock) begin
		if (btb_wvalid) btb_tag[write_index] <= write_tag;
	end

endmodule
