`timescale 1ns/1ps
module network_TB();

	parameter BITS_IN = 8;
	parameter BITS_OUT = 16;
	parameter N_NEURONS = 200;
	parameter ACC_BITS = 32;
	parameter T = 128;
  //parameter n_interactions = 16384;
  
  // Sinais
  reg clk, rst, init;
  reg [BITS_IN-1:0] x, y;
  wire [ACC_BITS-1:0] out_value;
  wire fim;

  // DUT
	network 
	#(	.BITS_IN(BITS_IN),
		.BITS_OUT(BITS_OUT),
		.N_NEURONS(N_NEURONS),
		.ACC_BITS(ACC_BITS),
		.T(T)
  ) dut (
    .clk(clk),
    .rst(rst),
    .x(x),
    .y(y),
    .out_value(out_value),
    .valid(fim)
  );

  // Clock
  always #10 clk = ~clk;

  // Inicialização
  initial begin
    clk = 0;
    rst = 0;
    #20 rst = 1; // Libera reset
  end

  // Variáveis de controle
  integer output_file;
  integer j, k;

  

  initial begin
    
	 // Abrir arquivo
    output_file = $fopen("OUTPUT.txt", "w");
    #40
	 
	
	for (j = 1; j <= 128; j=j+1) begin
		for(k = 1; k <= 128; k=k+1) begin
			
			x = j;
			y = k;
		  
			rst = 0; #20; rst = 1;
			wait(fim == 1'b1);
			$fwrite(output_file, "%b\n", out_value);
		
		end
	end
	 

    
    $fclose(output_file);

    $stop;
  end

endmodule 