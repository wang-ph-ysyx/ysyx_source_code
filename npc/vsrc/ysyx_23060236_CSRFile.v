module ysyx_23060236_CSRFile #(DATA_WIDTH = 1) (
	input  clock,
	input  reset,
	input  [11:0] imm,
	input  [DATA_WIDTH-1:0] wdata,
	output [DATA_WIDTH-1:0] rdata,
	input  enable,
	input  inst_ecall,
	input  [31:0] epc,
	output [31:0] jump,
	input  inst_mret,
	input  valid
);

	wire [2:0] addr;
	reg [DATA_WIDTH-1:0] csr [5:0];

	localparam ADDR_MEPC      = 3'd0;
	localparam ADDR_MCAUSE    = 3'd1;
	localparam ADDR_MSTATUS   = 3'd2;
	localparam ADDR_MTVEC     = 3'd3;
	localparam ADDR_MVENDORID = 3'd4;
	localparam ADDR_MARCHID   = 3'd5;

	ysyx_23060236_MuxKeyInternal #(6, 12, 3, 1) choose_addr(
		.out(addr),
		.key(imm),
		.default_out(3'b000),
		.lut({
			12'h341, ADDR_MEPC      ,
			12'h342, ADDR_MCAUSE    ,
			12'h300, ADDR_MSTATUS   ,
			12'h305, ADDR_MTVEC     ,
			12'hf11, ADDR_MVENDORID ,
			12'hf12, ADDR_MARCHID   
		})
	);

	always @(posedge clock) begin
		if (reset) begin
			csr[ADDR_MSTATUS]   <= 32'h1800;
			csr[ADDR_MVENDORID] <= 32'h79737978;
			csr[ADDR_MARCHID]   <= 32'h015fdf0c;
		end
		else if (valid) begin
			if (enable) begin
				csr[addr] <= wdata;
				csr[ADDR_MVENDORID] <= 32'h79737978;
				csr[ADDR_MARCHID]   <= 32'h015fdf0c;
			end
			else if (inst_ecall) begin
				csr[ADDR_MEPC]   <= epc;
				csr[ADDR_MCAUSE] <= 32'd11;
			end
		end
	end

	assign rdata = {32{enable}} & csr[addr];
	assign jump = {32{inst_ecall}} & csr[ADDR_MTVEC] | {32{inst_mret}} & csr[ADDR_MEPC];

endmodule
