// vocoder_tb.sv
// Testbench to apply stimulus (Test vector from MATLAB) to FFT and IFFT modules
// Author: Hassan Islam
// Date: 2024-02-27
`timescale 1 ns / 1 ns

module vocoder_tb();

parameter N = 12; // Number of ADC bits (LTC2308 is a 12-bit ADC)

logic clk, reset_n;			  // clock and reset
logic [2:0] chan = 0;		  // channel to be sampled
logic [N-1:0] result = 0;     // result read by adc interface module
logic [N-1:0] adcoutput = 0;  // randomly generated ADC output
logic [N-1:0] configword = 0; // capture configuration word from adcinterface
logic data_valid;             // control signal indicates conversion is complete 
	
// ltc2308 signals
logic ADC_CONVST, ADC_SCK, ADC_SDI;
logic ADC_SDO = 0;

logic [3:0] count = 0; 
logic [2:0] leds;

logic [11:0] tMod_re;            // modulation channel real component
logic [11:0] tMod_im  = 0 ;		 // modulation channel imaginary component
logic [11:0] tCarr_re = 0;	     // carrier channel real component
logic [11:0] tCarr_im  = 0;		 // carrier channel imagianry component 

// FFT signals 
logic reset; // active high reset signarl to restart IFFT and FFT modules 
logic [2:0] validIn = 0; // indicates input stream to FFT is valid data
logic ce_out; // clock enable out signal from FFT

// IFFT signals 
logic signed [25:0] yOut_re;  // real output values of IFFT 
logic signed [25:0] yOut_im;  // imaginary output values of IFFT

logic validOut; // signals indicate outputs of IFFT and FFT are valid
logic clk_enable = 1;

logic [15:0] clk_div_count; // count used to divide clock

// RAM signals 
logic[9:0] waddr = 0, waddr2 = 0;
logic[9:0] raddr = 0, raddr2 = 0;  
logic [15:0] addressCount = 0;  
logic[15:0] q, q2; 

// DAC signals 
logic clk_out, cs, din; 
logic [15:0] dac_in;

/* module instantiation */

ad7908AdcInterface dut_0 (.*);  // ADC device under test 
envelopeModulation_fixpt dut_1 (.*,.validIn(validIn[1])); // Vocoding module under test

two_port_ram ram1 (.clock(clk), .data(yOut_re[15:0]), .rdaddress(raddr), .wraddress(waddr), .wren(validOut), .q, .rden(1));
two_port_ram ram2 (.clock(clk), .data(q), .rdaddress(raddr2), .wraddress(waddr2), .wren(!validOut), .q(q2), .rden(1));

dacinterface dut_2 (.*,.d(dac_in));

/* module instatiation end */


always_ff @(posedge clk) dac_in <= {q2, 4'b0}; //

int re_data_result_FFT, ram_out_result, ram2_out_result; // file I/O 

initial begin
	clk = 0;
	reset_n = 0;
	reset = 1;

	re_data_result_FFT = $fopen("./yResult_re_FFT.dat","w"); // open file to write results from FFT
	ram_out_result = $fopen("./ram_out_result.dat","w"); // open file to write results from FFT
	ram2_out_result = $fopen("./ram2_out_result.dat","w"); // open file to write results from FFT

	// hold in reset for two clock cycles
	repeat(2) @(posedge clk);
	
	reset_n = 1;
	reset = 0;
	
	// loop until break is prompted by user
	do begin

	// wait for conversion start signal
	@(negedge ADC_CONVST);
	
		ADC_SDO = 0; // ad7908 outputs leading 0 

		// generate a random n-bit ADC output
		adcoutput = $urandom_range('hfff, 0);

		for(int i = $size(chan)-1; i>=0 ; i--) begin
			@(negedge ADC_SCK);
			ADC_SDO = chan[i];
		end

		for (int i = N-1; i>=0; i--)	begin
			
			@(negedge ADC_SCK);
			ADC_SDO = adcoutput[i];
	
		end
		
	repeat(2) @(posedge clk);

	end while (1);

end

// tests ADC config data
always begin 

	@(negedge ADC_CONVST);

	for (int i = N-1; i>=0; i--) begin
			
		@(negedge ADC_SCK);
		configword[i] = ADC_SDI;
	
	end

end 


always_ff@(posedge clk) begin 
	tCarr_re <= chan == 3'b000 ? result : tCarr_re ;
	tMod_re <= chan == 3'b111 ? result : tMod_re ; 
end
																				
always_ff@(posedge ADC_CONVST) chan <= (data_valid === 1'bx) ? 0 : (validIn & 1 ? ~chan : chan) ; 
always_ff@(posedge clk) validIn <= (data_valid === 1'bx) ? 0 : (validIn < 3'b10 ? (validIn + data_valid) : 0);  


/* to prevent data from being overwritten during read and write cycles, data is copied from one ram to another in order to be read */

always_ff @(posedge clk) 
	addressCount <= validOut || addressCount ? addressCount + 1 : addressCount; 


logic [10:0] A_count; // simulation signal for debugging; 

always_comb begin 
	
	waddr = validOut ? {
		addressCount[0], addressCount[1], addressCount[2], 
		addressCount[3], addressCount[4], addressCount[5],
		addressCount[6], addressCount[7], addressCount[8],
		addressCount[9]
		} : waddr;

	
	A_count = validOut? A_count + 1: 0;	
																							
	raddr  = !waddr ? addressCount & 1023 : waddr; 	 // read pointer increments through ram sequentially from the first to the last element 
	waddr2 = raddr; 								 // offset accounts for delay of output from RAM block one	   		
	raddr2 = (addressCount >> 6) - 15;  		     // read pointer increments every 2^6 = 64 samples. The offset is needed for timing. 

end


// write output data to files
always @(posedge clk) begin 
	if(validOut)
      $fwrite(re_data_result_FFT, "%d\n", yOut_re);
end 

always @(posedge clk) begin  
	  $fwrite(ram_out_result, "%d\n", q);
end 

always @(negedge cs) begin  
	  $fwrite(ram2_out_result, "%d\n", q2);
end 


//simulation signal for debugging tracks the number of ADC conversions
logic [15:0] convserion_count= 0;
always_ff@(posedge clk) convserion_count <= validIn[1] + convserion_count; 

// generate clock
always
	#10ns clk = ~clk;

always
	#15ms $stop; 


	

endmodule

