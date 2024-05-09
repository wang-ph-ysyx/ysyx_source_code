module ifu(
	input clk,
	input reset,
	input [31:0] pc,
	input ifu_valid,
	output [31:0] inst,
	output reg idu_valid
);

	reg [31:0] inst_reg;

	always @(posedge clk) begin
		if (!reset) begin
			if (ifu_valid) begin
				inst_reg <= pmem_read(pc);
				idu_valid <= 1;
			end
			else begin
				inst_reg <= inst_reg;
				idu_valid <= 0;
			end
		end
		else inst_reg <= 0;
	end

	assign inst = inst_reg;

endmodule
