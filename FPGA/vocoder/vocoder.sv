// File: vocoder.sv
// Author(s): Hassan Islam, Riley Olfert
// Date: 2024-03-11

/* Description: 	ELEX 7660 Top level module for vocoder project
_________________ A Vocoder, short for vocal encoder, modifies the frequency content of a carrier signal based on the
						frequency content of another modulator signal. The carrier is usually a musical sound, derived from a guitar
						or synthesizer, and the modulator signal is usually a human voice but can be any audio signal. The vocoder
						will analyze the envelope and formants of the modulator signal by use of a DIT FFT algorithm and apply it
						to the carrier signal. The output results in a synthesized audio signal at the carrier’s frequency with the tonal
						qualities of the input signal.
*/


module vocoder ( input logic CLOCK_50, 	 	// 50 MHz clock
                 output logic [2:0] GPIO_0, // Outputs to DAC

					  /*ADC1 pins*/
					  output logic ADC_CS_N, ADC_SCLK, ADC_DIN,
					  input logic ADC_DOUT
					);  
					
	localparam fftSize = 1024;         		// specifies size of fft and ifft modules
				
	/* clock signals */ 
	localparam clock_division = 3; 			// parameter for clock division
	logic [15:0] clk_div_count = 0; 		// count used to divide clock

	/* ADC signals */
	logic ADC_data_valid; 					// control signal indicates that data from ADC is valid  
	logic [2:0] chan = 3'b000; 				// ADC analog channel select
	logic [11:0] result; 			 		// ADC conversion result
	logic reset_n = 1;						// reset signal
	
	/*envelope_mod signals*/
    logic [2:0]  validIn = 0; 			// counts up when both ADC channels conversions are complete
    logic reset = 0;					// reset signal 
    logic clk_enable = 1;				// assert to enable envelope modulation operation
    logic ce_out;						// signal is output when clk_enable is asserted
    logic [11:0] tMod_re; 				// modulation signal real component
    logic [11:0] tMod_im = 12'b0; 		// modulation signal imaginary component
    logic [11:0] tCarr_re;				// carrier signal real component
    logic [11:0] tCarr_im = 12'b0;		// carrier signal imaginary component
    logic signed [25:0] yOut_re;  		// envelope_modulation result output real component
    logic signed [25:0] yOut_im;  		// envelope_modulation result output imaginary component
    logic validOut;
	
	/* DAC signals */
	logic [15:0] dac_out;					// value that is sent out to DAC 
	
	
	/* ram signals*/  
	logic [15:0] q, q2;											      	// ram output
	logic [$clog2(fftSize) - 1 : 0]  waddr = 0, waddr2= 0, 				// ram write address 
												raddr = 0, raddr2 =0;   // read read address 
	logic [15:0] addressCount = 0; 										// address counter used to track states 
	
	
	/* module instances */
  
	ad7908AdcInterface ADC_0  (
									  .clk(clk_div_count[clock_division]),
									  .reset_n, 
									  .result(result), 
									  .chan, 
									  .ADC_CONVST(ADC_CS_N),
									  .ADC_SCK(ADC_SCLK), 
									  .ADC_SDI(ADC_DIN),
									  .ADC_SDO(ADC_DOUT), 
									  .data_valid(ADC_data_valid)
									);
									
	
	envelopeModulation_fixpt envelopeMod_0 (.*, .validIn(validIn[1]), .clk(clk_div_count[clock_division])); 
	
	
	two_port_ram ram1 (.clock(clk_div_count[clock_division]), .data(yOut_re[15:0]), .rdaddress(raddr), .wraddress(waddr), .wren(validOut), .q, .rden(1'b1));
	two_port_ram ram2 (.clock(clk_div_count[clock_division]), .data(q), .rdaddress(raddr2), .wraddress(waddr2), .wren(~validOut), .q(q2), .rden(1'b1));
																																																							
															
	dacinterface dac (.clk(clk_div_count[clock_division]), .d(dac_out), .clk_out(GPIO_0[0]), .cs(GPIO_0[1]), .din(GPIO_0[2]));
	
	
	// output DAC is a 16 bit dac, while adc is 12 bit.
	assign dac_out = {q2[11:0], 4'b0};

	
	// store carrier and modulator ADC results 																	 
	always_ff@(posedge clk_div_count[clock_division]) begin 
		tCarr_re <= chan == 3'b111 && ADC_CS_N ? result : tCarr_re ;
		tMod_re <= chan == 3'b000 && ADC_CS_N ? result : tMod_re ;		
	end 
	
	// ADC channel toggles every second assertion of ADC_data_valid 
	always_ff@(posedge ADC_CS_N)
		chan <= validIn & 1 ? ~chan : chan ; 
			
			
	// validIn increments everytime ADC_data_valid is asserted
	always_ff@(posedge clk_div_count[clock_division]) 
		validIn <= validIn < 3'b10 ? (validIn + ADC_data_valid) : 0 ; 
	
																								
	// address counter is used to control ram write and read addresses 
	always_ff @(posedge clk_div_count[clock_division]) 
		addressCount <= validOut || addressCount ? addressCount + 1 : addressCount; 
		
		
	// ram address pointers	
	always_comb begin 
		
		/* output from envelopeModulation is bit-reversed indexed so it 
		   must be reversed again to be stored in ram in the proper order */
		waddr = validOut ? {
			addressCount[0], addressCount[1], addressCount[2], 
			addressCount[3], addressCount[4], addressCount[5],
			addressCount[6], addressCount[7], addressCount[8],
			addressCount[9]
			} : 0;
				
		/* address from ram 1 is read sequentially to be loaded into
			ram 2 after the write operation is done */
		raddr  = !waddr ? addressCount & 1023 : waddr; 

		/* A second ram is written to and read from sequencially in order to 
			avoid conflict with the first ram where new data is written in bit-reveresed order */
		waddr2 = raddr; 	

		/* An ADC conversion takes 64 cycles, therefore the read address for ram 2 stays on 
			an address for 2^6 = 64 cycles in order to ensure dataflow is continous */
		raddr2 = (addressCount >> 6) - 15; // '-15' is an offset 
	end

 														
	// clock divider 
   always_ff @(posedge CLOCK_50) 
			  clk_div_count <= clk_div_count + 1'b1 ;
	  

endmodule
													
