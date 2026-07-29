module readout_rate_code #(
    parameter BITS = 16,
    parameter N_NEURONS = 50,
    parameter ACC_BITS = 64,
    parameter T = 128
)(
    input wire clk,
    input wire rst,
    input wire [N_NEURONS-1:0] spike,
    output reg signed [ACC_BITS-1:0] out_value,
    output reg valid
);

	localparam SHIFT = $clog2(T);

    reg signed [BITS-1:0] W_out [0:N_NEURONS];
    reg signed [ACC_BITS-1:0] acc;
	 reg signed [ACC_BITS-1:0] acc_next;
    reg [15:0] counter;

	 (* rom_style = "M9K" *) reg [BITS-1:0] memwo [0 : N_NEURONS];

	 integer j;
	 
	initial begin 
		$readmemb("peso0.mem", memwo);

		for (j = 0; j < N_NEURONS; j = j + 1) begin
			W_out[j] = memwo[j];
			//$display("wo[%0d]=%d", j, W_out[j]);
		end
	end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            acc <= 0;
            counter <= 0;
            valid <= 0;
        end else begin
            valid <= 0;
				acc_next = acc;
				
            for (j = 0; j < N_NEURONS; j = j + 1)
                if (spike[j])
                    acc_next = acc_next + W_out[j];
						  
				
            if (counter == T-1) begin
                out_value <= acc_next >>> SHIFT;
                acc <= 0;
                counter <= 0;
                valid <= 1;
					 //$display("out=%d",out_value);
            end else begin
					acc <= acc_next;
					counter <= counter + 1;
				end
				
				//$display("spike = %b", spike);
				//$display("acc = %d", acc);
				//display("out_value = %d", out_value);
        end
    end

endmodule