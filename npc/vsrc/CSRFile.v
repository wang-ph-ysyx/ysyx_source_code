module CSRFile #(DATA_WIDTH = 1) (
	input clk,
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

	wire [1:0] addr;
	reg [DATA_WIDTH-1:0] csr [3:0];//0:mepc  1:mcause  2:mstatus  3:mtvec

	MuxKeyInternal #(4, 12, 2, 1) choose_addr(
		.out(addr),
		.key(imm),
		.default_out(2'b00),
		.lut({
			12'h341, 2'b00, //mepc
			12'h342, 2'b01,	//mcause
			12'h300, 2'b10, //mstatus
			12'h305, 2'b11  //mtvec
		})
	);

	always @(posedge clk) begin
		if (valid) begin
			if (enable) begin
				csr[addr] <= wdata;
			end
			else if (inst_ecall) begin
				csr[0] <= epc + 4;
				csr[1] <= cause;
			end
		end
	end

	assign rdata = {32{enable}} & csr[addr];
	assign jump = {32{inst_ecall}} & csr[3] | {32{inst_mret}} & csr[0];

endmodule
