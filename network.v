module network #(
		parameter BITS_IN = 8,
		parameter BITS_OUT = 16,
		parameter N_NEURONS = 50,
		parameter ACC_BITS = 32,
		parameter T = 128
	)(
		input wire clk,
		input wire rst,
		input wire [BITS_IN-1:0] x,
		input wire [BITS_IN-1:0] y,

		output wire signed [ACC_BITS-1:0] out_value,
		output wire valid
	);

	integer j;

	reg signed [BITS_OUT-1:0] I [0:N_NEURONS];
	reg signed [BITS_IN-1:0] W_x [0:N_NEURONS];
	reg signed [BITS_IN-1:0] W_y [0:N_NEURONS];


	wire [N_NEURONS-1:0] spike_hidden;

	(* rom_style = "M9K" *) reg [BITS_IN-1:0] memw1 [0 : N_NEURONS];
	(* rom_style = "M9K" *) reg [BITS_IN-1:0] memw2 [0 : N_NEURONS];
	 (* rom_style = "M9K" *) reg [BITS_OUT-1:0] memb [0 : N_NEURONS];

	initial begin 

		$readmemb("peso1.mem",memw1);
		$readmemb("peso2.mem",memw2);
		$readmemb("bias.mem", memb);

	end

	always @(*) begin
    for (j = 0; j < N_NEURONS; j = j + 1) begin
        W_x[j] = memw1[j];
        W_y[j] = memw2[j];
        I[j]   = ($signed(W_x[j]) * $signed({1'b0, x})) + 
                 ($signed(W_y[j]) * $signed({1'b0, y})) - 
                 $signed(memb[j]);
    end
end


	genvar k;
	generate
		for (k = 0; k < N_NEURONS; k = k + 1) begin : NEURONS
			neuron #(
				.BITS(BITS_OUT)
			) n (
				.clk(clk),
				.rst(rst),
				.input_current(I[k]),
				.V(),
				.spike(spike_hidden[k])
			);
		end
	endgenerate


	readout_rate_code #(
		.BITS(BITS_OUT),
		.N_NEURONS(N_NEURONS),
		.ACC_BITS(ACC_BITS),
		.T(T)
	) readout (
		.clk(clk),
		.rst(rst),
		.spike(spike_hidden),
		.out_value(out_value),
		.valid(valid)
	);
	
endmodule