module uart #(SERIAL_PORT = 32'ha00003f8) (
	input  clock,
	input  reset,

	input  [31:0] raddr,
	output [31:0] rdata,
	input  rvalid,

	input  [31:0] waddr,
	input  [31:0] wdata,
	input  wvalid,

	input  rx,
	output reg tx
);

reg [7:0] rfifo [63:0];
reg [7:0] tfifo [63:0];
reg [5:0] rh_ptr, rt_ptr;
reg [5:0] th_ptr, tt_ptr;
reg [7:0] rcdata, tdata;
wire nextrdata, rempty, rfull;
wire nexttdata, tempty, tfull;

// divisor
reg [3:0] divisor;
always @(posedge clock) begin
	if (reset) divisor <= 15;
	else if (divisor != 0) divisor <= divisor - 1;
	else divisor <= 15;
end

// fifo
always @(posedge clock) begin
	if (reset) begin
		rh_ptr <= 0; rt_ptr <= 0;
		th_ptr <= 0; tt_ptr <= 0;
	end
	else if (nextrdata & ~rempty) begin
		rh_ptr <= rh_ptr + 1;
	end
end

// rx
reg [3:0] rcount;
always @(posedge clock) begin
	if (reset) rcount <= 0;
	else if (divisor == 0) begin
		if (rcount == 0) begin
			if (~rx)
				rcount <= rcount + 1;
		end
		else if ((rcount >= 1) & (rcount <= 8))begin
			rcdata <= {rx, rcdata[7:1]};
			rcount <= rcount + 1;
		end
		else if (rcount == 9) begin
			if (~rfull) begin
				rfifo[rt_ptr] <= rcdata;
				rt_ptr <= rt_ptr + 1;
			end
			rcount <= 0;
		end
	end
end

// read
assign rempty = (rh_ptr == rt_ptr);
assign rfull  = (rh_ptr == rt_ptr + 1);
assign rdata  = rempty ? 32'b0 : {24'b0, rfifo[rh_ptr]};
assign nextrdata = (raddr == SERIAL_PORT) & rvalid;


// tx
reg [3:0] tcount;
always @(posedge clock) begin
	if (reset) begin
		tx <= 1;
		tcount <= 0;
	end
	else if (divisor == 0) begin
		if (tcount == 0) begin
			if (~tempty) begin
				tcount <= tcount + 1;
				tx <= 0;
			end
		end
		else if ((tcount >= 1) & (tcount <= 8))begin
			tx <= tdata[tcount - 1];
			tcount <= tcount + 1;
		end
		else if (tcount == 9) begin
			th_ptr <= th_ptr + 1;
			tcount <= 0;
			tx <= 1;
		end
	end
end

// write
assign tempty = (th_ptr == tt_ptr);
assign tfull  = (th_ptr == tt_ptr + 1);
assign tdata  = tfifo[th_ptr];
assign nexttdata = (waddr == SERIAL_PORT) & wvalid;
always @(posedge clock) begin
	if (nexttdata & ~tfull) begin
		tfifo[tt_ptr] <= wdata[7:0];
		tt_ptr <= tt_ptr + 1;
	end
end

endmodule
