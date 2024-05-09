module ifu(
	input clk,
	input reset,
	input [31:0] pc,
	output [31:0] inst,
	output valid
);

	reg rvalid;
	reg [31:0] inst_reg;

	initial begin
		rvalid = 0;
	end

	always @(posedge clk) begin
		if (!reset) begin
			if (rvalid) begin
				inst_reg <= pmem_read(pc);
			end
			else inst_reg <= inst_reg;
			rvalid <= ~rvalid;
		end
		else inst_reg <= 0;
	end

	assign inst = inst_reg;
	assign valid = ~rvalid;

endmodule
