`timescale 1ns/1ps

module neuron_TB;

	localparam BITS = 16;

	reg clk;
	reg                     rst;
	reg signed [BITS-1:0]   input_current;
	wire signed [BITS-1:0]  V;
	wire                    spike;

	neuron #(
		.BITS(BITS),
		.V_INITIAL(16'sd0),
		.V_TH(16'sd1000),
		.LEAK_SHIFT(4)
	) dut (
		.clk(clk),
		.rst(rst),
		.input_current(input_current),
		.V(V),
		.spike(spike)
	);

	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rst = 0;
		input_current = 0;

		#20;
		rst = 1;

		// integrate and spike
		input_current = 16'sd150;

		repeat (50) @(posedge clk);
            

		// leak only
		input_current = 16'sd0;

		repeat (20) @(posedge clk);
			

		// quicker integrate and spike
		input_current = 16'sd800;

		repeat (10) @(posedge clk);
		
		$finish;
	end

	integer f;

	initial f = $fopen("V_trace.txt", "w");

	always @(posedge clk) begin
		$fwrite(f, "%0t %0d %b\n", $time, V, spike);
	end

	
endmodule
