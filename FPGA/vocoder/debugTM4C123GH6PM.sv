// File: debugTM4C123GH6PM.sv
// Description: interfaces with TM4C123GH6PM to be used as a debugging tool. See ..\vocoder\TM4C123GH6PM\dataReadFPGA. 
//				The microcontroller prints data on a virtual serial comm port. 
// Author: Hassan Islam
// Date: 2024-03-11


module debugTM4C123GH6PM 
    #( parameter int 
       NUM_OF_SAMPLES = 1024,
       SIZE_OF_SAMPLE = 16 )
(
   input logic data_valid, clk,
	input logic [SIZE_OF_SAMPLE - 1 : 0] data,
	output logic valid_out, clk_out, data_out	
);

  logic [$clog2(SIZE_OF_SAMPLE*NUM_OF_SAMPLES) - 1 : 0] count = 0; // index for data vector 
  
  always_ff @(posedge clk) begin
	if((data_valid || count) && count < (SIZE_OF_SAMPLE*NUM_OF_SAMPLES - 1)) 
       count <= count+ 1'b1;
	else 
	    count <= 0; 
  end

  /* Data must be sent on the negative edge of the clock, this allows for the data to be stable before it is read
     by the TIVA board. Data is sent out with the MSB first */
  always_ff @(negedge clk) 
			data_out <= data[ (SIZE_OF_SAMPLE - 1) - (count % SIZE_OF_SAMPLE) ]; // MSB is sent out first PIN_AF20 // fix this, this is wrong... 

			
  /* clk_out signal is sent to the TIVA board, this allows for data to be read in sync*/		
  assign clk_out = clk; 
  
  /* signal is used to tell TIVA board that the incoming data is valid and should be sampled.*/
  always_ff @(negedge clk) begin 
  
    if((data_valid || count) && (count < SIZE_OF_SAMPLE*NUM_OF_SAMPLES))
        valid_out <= 1'b1;
    else  
        valid_out <= 1'b0; 
  end 

  
endmodule 