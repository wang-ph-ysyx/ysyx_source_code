module ysyx_23060236_div(
	input  clock,
	input  reset,

	input  div_valid,
	output div_ready,

	input  div_sign,
	input  [31:0] div1,
	input  [31:0] div2,

	output [31:0] res,
	output [31:0] rem,
	output reg div_outvalid
);

reg [5:0] count;
reg [63:0] ans;
reg [31:0] div2_reg;
reg sign1_reg;
reg sign2_reg;
reg div_busy;
assign rem = ans[63:32];
assign res = ans[31:0];
assign div_ready = ~div_busy;

wire sign1 = div_sign & div1[31];
wire sign2 = div_sign & div2[31];
wire [31:0] div1_unsign = sign1 ? ~div1 + 1 : div1;
wire [31:0] div2_unsign = sign2 ? ~div2 + 1 : div2;
wire [32:0] diff = ans[63:31] - {1'b0, div2_reg};

// control signal register
always @(posedge clock) begin
	if (reset) div_outvalid <= 0;
	else if (count[5]) div_outvalid <= 1;
	else if (div_outvalid) div_outvalid <= 0;

	if (reset) div_busy <= 0;
	else if (div_valid & div_ready) div_busy <= 1;
	else if (count[5]) div_busy <= 0;
end

// data register
always @(posedge clock) begin
	if (div_valid & div_ready) begin
		sign1_reg <= sign1;
		sign2_reg <= sign2;
		count <= 0;
		div2_reg <= div2_unsign;
		ans <= {32'b0, div1_unsign};
	end

	if (~count[5] & div_busy) begin
		count <= count + 1;
		ans <= diff[31] ? {ans[62:0], 1'b0} : {diff[31:0], ans[30:0], 1'b1};
	end

	if (count[5] & div_busy) begin
		ans[63:32] <= sign1_reg               ? ~ans[63:32] + 1 : ans[63:32];
		ans[31:0]  <= (sign1_reg ^ sign2_reg) ? ~ans[31:0]  + 1 : ans[31:0];
		count <= 0;
	end
end

endmodule
