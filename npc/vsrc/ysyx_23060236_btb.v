module ysyx_23060236_btb(
	input clock,
	input reset,

	input  [31:0] btb_araddr,
	output [31:0] btb_rdata,

	input  btb_wvalid,
	input  [31:0] btb_awaddr,
	input  [31:0] btb_wdata
);

	//此处ADDR_LEN减7与sdram地址范围匹配
	localparam ADDR_LEN   = 32 - 7;
	localparam DATA_LEN   = 32;
	localparam OFFSET_LEN = 2;
	localparam INDEX_LEN  = 1;
	localparam TAG_LEN    = ADDR_LEN - OFFSET_LEN - INDEX_LEN;

	reg [DATA_LEN-1:0]     btb_data [2**INDEX_LEN-1 : 0];
	reg [TAG_LEN-1:0]      btb_tag  [2**INDEX_LEN-1 : 0];
	reg [2**INDEX_LEN-1:0] btb_valid;

	wire btb_hit;
	wire [INDEX_LEN-1:0]  read_index;
	wire [TAG_LEN-1:0]    read_tag;
	wire [OFFSET_LEN-1:0] read_offset;
	wire [INDEX_LEN-1:0]  write_index;
	wire [TAG_LEN-1:0]    write_tag;
	wire [OFFSET_LEN-1:0] write_offset;

	assign read_tag     = btb_araddr[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign read_index   = btb_araddr[OFFSET_LEN+INDEX_LEN-1 : OFFSET_LEN];
	assign read_offset  = btb_araddr[OFFSET_LEN-1 : 0];
	assign write_tag    = btb_awaddr[ADDR_LEN-1 : OFFSET_LEN+INDEX_LEN];
	assign write_index  = btb_awaddr[OFFSET_LEN+INDEX_LEN-1 : OFFSET_LEN];
	assign write_offset = btb_awaddr[OFFSET_LEN-1 : 0];
	assign btb_hit      = btb_valid[read_index] & (btb_tag[read_index] == read_tag);
	assign btb_rdata    = btb_hit ? btb_data[read_index] : (btb_araddr + 4);

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
