module ysyx_23060236_CSRFile (
	input  clock,
	input  reset,
	input  [11:0] read_imm,
	input  [11:0] write_imm,
	input  [31:0] wdata,
	output [31:0] rdata,
	input  enable,
	input  inst_ecall,
	input  inst_ecall_write,
	input  inst_mret,
	input  [31:0] epc,
	output [31:0] jump,
	output        jump_en,
	input  valid
);

	reg [31:0] mepc   ;
	reg [6:0]  mcause ;
	reg [31:0] mstatus;
	reg [31:0] mtvec  ;

	always @(posedge clock) begin
		if (reset) begin
			mstatus <= 32'h1800;
		end
		else if (valid) begin
			if (enable) begin
				if (write_imm == 12'h341) mepc    <= wdata;
				if (write_imm == 12'h342) mcause  <= {wdata[31], wdata[5:0]};
				if (write_imm == 12'h300) mstatus <= wdata;
				if (write_imm == 12'h305) mtvec   <= wdata;
			end
			else if (inst_ecall_write) begin
				mepc   <= epc;
				mcause <= 7'd11;
			end
		end
	end

	assign rdata = (read_imm == 12'h341) ? mepc    :
                 (read_imm == 12'h342) ? {mcause[6], 25'b0, mcause[5:0]} :
                 (read_imm == 12'h300) ? mstatus :
                 (read_imm == 12'h305) ? mtvec   :
                 (read_imm == 12'hf11) ? 32'h79737978 :
                 (read_imm == 12'hf12) ? 32'h015fdf0c :
								 32'b0;

	assign jump = {32{inst_ecall}} & mtvec | {32{inst_mret}} & mepc;
	assign jump_en = inst_ecall | inst_mret;

endmodule
