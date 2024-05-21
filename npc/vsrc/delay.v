module delay #(DELAY = 10) (
	input  clk,
	input  reset,
	input  data_in,
	output data_out
);

	reg [DELAY-1:0] data_buf;

	always @(posedge clk) begin
		if (reset) begin
			data_buf <= 0;
		end
		else begin
			data_buf <= {DELAY{data_in}} & {data_buf[DELAY-2:0], data_in};
		end
	end

	assign data_out = data_buf[DELAY-1];

endmodule
