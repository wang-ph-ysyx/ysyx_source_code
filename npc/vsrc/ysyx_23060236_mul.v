module ysyx_23060236_mul(
	input  clock,
	input  reset,

	input  mul_valid,
	output mul_ready,

	input  [1:0] mul_sign,
	input  [31:0] mul1,
	input  [31:0] mul2,

	output [31:0] mul_high,
	output [31:0] mul_low,
	output reg mul_outvalid
);

reg  sign;
reg  [5:0] count;
reg  [31:0] mul1_reg;
reg  [63:0] res;
reg  mul_busy;
wire [32:0] res_tmp;
assign res_tmp = res[0] ? res[63:32] + mul1_reg : {1'b0, res[63:32]};
assign mul_high = res[63:32];
assign mul_low  = res[31:0];
assign mul_ready = ~mul_busy;

wire sign2 = mul_sign[0] & mul2[31];
wire sign1 = mul_sign[1] & mul1[31];
wire [31:0] mul1_unsign = sign1 ? ~mul1 + 1 : mul1;
wire [31:0] mul2_unsign = sign2 ? ~mul2 + 1 : mul2;
wire [63:0] res_unsign = {res_tmp[32:0], res[31:1]};

// control signal register
always @(posedge clock) begin
	if (reset) mul_busy <= 0;
	else if (mul_valid & mul_ready) mul_busy <= 1;
	else if (count[5]) mul_busy <= 0;

	if (reset) mul_outvalid <= 0;
	else if (count[5]) mul_outvalid <= 1;
	else if (mul_outvalid) mul_outvalid <= 0;
end

// data register
always @(posedge clock) begin
	if (mul_valid & mul_ready) begin
		sign  <= sign1 ^ sign2;
		count <= 0;
		res   <= {32'b0, mul2_unsign[31:0]};
		mul1_reg <= mul1_unsign;
	end

	if (~count[5] & mul_busy) begin
		res   <= res_unsign;
		count <= count + 1;
	end

	if (count[5] & mul_busy) begin
		res <= sign ? ~res + 1 : res;
		count <= 0;
	end
end

endmodule
