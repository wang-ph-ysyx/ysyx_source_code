module ysyx_23060236_CSRFile #(DATA_WIDTH = 1) (
	input clock,
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

	wire [31:0] rdata_tmp;
	reg [DATA_WIDTH-1:0] mepc;
	reg [DATA_WIDTH-1:0] mcause;
	reg [DATA_WIDTH-1:0] mstatus;
	reg [DATA_WIDTH-1:0] mtvec;

	ysyx_23060236_MuxKeyInternal #(6, 12, 32, 1) calculate_rdata_tmp(
		.out(rdata_tmp),
		.key(imm),
		.default_out(32'b0),
		.lut({
			12'h341, mepc,
			12'h342, mcause,
			12'h300, mstatus,
			12'h305, mtvec,
			12'hf11, 32'h79737978,
			12'hf12, 32'h015fdf0c
		})
	);

	always @(posedge clock) begin
		if (valid) begin
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

	assign rdata = enable ? rdata_tmp : 32'b0;
	assign jump = {32{inst_ecall}} & mtvec | {32{inst_mret}} & mepc;

endmodule
