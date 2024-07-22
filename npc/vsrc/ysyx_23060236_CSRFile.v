module ysyx_23060236_CSRFile #(DATA_WIDTH = 1) (
	input clock,
	input reset,
	input [11:0] imm,
	input [DATA_WIDTH-1:0] wdata,
	output [DATA_WIDTH-1:0] rdata,
	input enable,
	input inst_ecall,
	input [31:0] epc,
	input [31:0] cause,
	output [31:0] jump,
	input inst_mret,
	input valid
);

	localparam ADDR_MEPC      = 3'd0;
	localparam ADDR_MCAUSE    = 3'd1;
	localparam ADDR_MSTATUS   = 3'd2;
	localparam ADDR_MTVEC     = 3'd3;
	localparam ADDR_MVENDORID = 3'd4;
	localparam ADDR_MARCHID   = 3'd5;

	wire [31:0] rdata_tmp;
	wire [2:0]  addr;
	reg  [DATA_WIDTH-1:0] mepc;
	reg  [DATA_WIDTH-1:0] mcause;
	reg  [DATA_WIDTH-1:0] mstatus;
	reg  [DATA_WIDTH-1:0] mtvec;

	ysyx_23060236_MuxKeyInternal #(6, 12, 3, 1) calculate_addr(
		.out(addr),
		.key(imm),
		.default_out(3'b0),
		.lut({
			12'h341, ADDR_MEPC,
      12'h342, ADDR_MCAUSE,    
      12'h300, ADDR_MSTATUS,   
      12'h305, ADDR_MTVEC,
      12'hf11, ADDR_MVENDORID,
      12'hf12, ADDR_MARCHID   
		})
	);

	ysyx_23060236_MuxKeyInternal #(6, 3, 32, 1) calculate_rdata_tmp(
		.out(rdata_tmp),
		.key(addr),
		.default_out(32'b0),
		.lut({
			ADDR_MEPC     , mepc,
			ADDR_MCAUSE   , mcause,
			ADDR_MSTATUS  , mstatus,
			ADDR_MTVEC    , mtvec,
			ADDR_MVENDORID, 32'h79737978,
			ADDR_MARCHID  , 32'h015fdf0c
		})
	);

	always @(posedge clock) begin
		if (reset) begin
			mepc    <= 32'h0;
			mcause  <= 32'h0;
			mstatus <= 32'h0;
			mstatus <= 32'h1800;
		end
		else if (valid) begin
			if (enable) begin
				if (imm == 12'h341) mepc    <= wdata;
				if (imm == 12'h342) mcause  <= wdata;
				if (imm == 12'h300) mstatus <= wdata;
				if (imm == 12'h305) mtvec   <= wdata;
			end
			else if (inst_ecall) begin
				mepc   <= epc;
				mcause <= 32'd11;
			end
		end
	end

	assign rdata = {32{enable}} & rdata_tmp;
	assign jump = {32{inst_ecall}} & mtvec | {32{inst_mret}} & mepc;

endmodule
