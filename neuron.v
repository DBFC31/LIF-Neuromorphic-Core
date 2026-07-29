module neuron #(
	parameter BITS = 16,
	parameter V_INITIAL = 16'd0,
	parameter V_TH = 16'sd1000,
	parameter LEAK_SHIFT = 4 // pra ser mais eficiente em hardware, o leak é calculado como V/2^LEAK_SHIFT
)(
	input wire clk,
	input wire rst,
	input wire signed [BITS-1:0]input_current,
	output reg signed [BITS-1:0]V,
	output reg spike
);

	wire signed [BITS-1:0]leak;
	wire signed [BITS-1:0] V_next;
	assign leak = $signed(V) >>> LEAK_SHIFT;
	assign V_next = V + input_current - leak;

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			V <= V_INITIAL;
			spike <= 1'b0;
		end
		else begin
			spike <= 1'b0;

			if (V_next >= V_TH) begin
				spike <= 1'b1;
				V <= V_INITIAL;
			end else begin
				V <= V_next;
			end
		end
	end
	

endmodule