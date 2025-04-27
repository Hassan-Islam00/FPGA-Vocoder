// FFT_tb.sv
// Testbench to apply stimulus (Test vector from MATLAB) to FFT and IFFT modules
// Author: Hassan Islam
// Date: 2024-02-27

`timescale 1 ns / 1 ns

module FFT_tb();

int yIn_data; // variable used to read data from yIn_re.dat

int cycles = 0; // used to track how many cycles the program has run for

// output result files 
int re_data_result_IFFT, re_data_result_FFT,
    im_data_result_IFFT, im_data_result_FFT,
    validOut_result_IFFT;

logic signed [15:0] data_rd; // data imported from yIn_data

logic clk = 0; // clock signal 
logic clk_enable = 0; // clock enable for IFFT and FFT modules

logic reset; // active high reset signal to restart IFFT and FFT modules 

logic [15:0] yIn_re; // real inputs values of FFT /* sfix32_En24 */
logic [15:0] yIn_im;  // real input values of IFFT  /* sfix32_En24 */
logic validIn = 0; // indicates input stream to FFT is valid data

logic signed [26:0] yOut_re;  // real output values of FFT, also inputs to IFFT /* sfix39_En24 */
logic signed [26:0] yOut_im;  // imaginary output values of FFT, also inputs to IFFT /* sfix39_En24 */

logic signed [23:0] Ifft_yOut_re;  // real output values of IFFT /* sfix39_En24 */
logic signed [23:0] Ifft_yOut_im;  // imaginary output values of IFFT /* sfix39_En24 */

logic [3:0] count, // count used to track states 
next_count; // next count is used to add an extra clock delay 

logic validOut_FFT, validOut_IFFT; // signals indicate outputs of IFFT and FFT are valid 

logic ce_out; // clock enable out signal from FFT
logic IFFT_ce_out; // clock enable out signal from IFFT

logic [9:0] waddr = 10'b0, raddr = 10'h3FF; // read address is initialized at an one address below write address
logic [13:0] addr_counter = 0;              // counter used to increment through ram write and read addresses
logic [26:0] q;                             // ram output


/* IFFT and FFT module instantiation */
FFT1024_fixpt dut_1 (
                      .clk,
                      .reset, 
                      .clk_enable, 
                      .yIn_re,
                      .yIn_im, 
                      .validIn, 
                      .ce_out , 
                      .yOut_im, 
                      .yOut_re, 
                      .validOut(validOut_FFT)
                      );
I_IFFT1024_fixpt dut_2 (
                      .clk, 
                      .reset, 
                      .clk_enable, 
                      .yIn_re(yOut_re), 
                      .yIn_im(yOut_im), 
                      .validIn(validOut_FFT), 
                      .ce_out(IFFT_ce_out), 
                      .yOut_im(Ifft_yOut_im), 
                      .yOut_re(Ifft_yOut_re), 
                      .validOut(validOut_IFFT)
                      );
/* ram instantiation */		
mixed_width_ram 
                #(
                  .WORDS(1024),  
                  .RW(27), 
                  .WW(27) 
                ) 
		        ram 
                (
                  .we(validOut_IFFT), 
                  .clk,
                  .waddr, 
                  .wdata(Ifft_yOut_re), 
                  .raddr, 
                  .q
                );

initial begin

  // active high reset for FFT and IFFT modules
  reset = 1;
  repeat(3)@(posedge clk);
  reset = 0;
  
  // no imaginary input
  yIn_im = 16'b0;

  re_data_result_FFT = $fopen("./yResult_re_FFT.dat","w"); // open file to write results from FFT
  im_data_result_FFT = $fopen("./yResult_im_FFT.dat","w"); // open file to write results from FFT

  re_data_result_IFFT = $fopen("./yResult_re_IFFT.dat","w"); // open file to write results from IFFT
  im_data_result_IFFT = $fopen("./yResult_im_IFFT.dat","w"); // open file to write results from IFFT

  validOut_result_IFFT = $fopen("./yResult_ValidOut.dat","w"); // open file to write valid out result from IFFT

  yIn_data = $fopen("./yHDLtestVector.dat","r"); // open file to read input data from MATLAB input test vector

  // wait for first sample to be read from file before enabling FFT module, this ensures all of b'128-data frame is captured. 
  repeat(10) @(posedge clk);

  clk_enable = 1; // enable clocks for FFT and IFFT

end

// counter 
always_ff @(posedge clk, posedge reset) begin 
      // do not count until clk_enable is asserted 
      if(reset || !clk_enable) begin 
          next_count <= 0;
          count <= next_count; 
      end
      else begin 
          next_count <= next_count + 1;
          count <= next_count;
      end 
end

// ram write address pointer
always_ff @(posedge clk) 
	  if(validOut_IFFT)
			waddr <= waddr + 1'b1;
	
// ram read address pointer
always_ff @(posedge clk) 
			raddr <= (addr_counter >> 4) - 1;  	
	
// counter for addresses 
always_ff @(posedge clk) begin 
	  if(validOut_IFFT || addr_counter) begin
			  addr_counter <= addr_counter + 1; 
    end
end 
	    							
// assign data from input file to FFT input
always_comb begin
   if(count == 15) 
        validIn = 1; 
   else 
        validIn = 0;
   yIn_re[count] = data_rd[count] ;
end 

// write output data from IFFT to file
always @(posedge clk) begin 
      $fwrite(re_data_result_IFFT, "%d\n", Ifft_yOut_re); 
      $fwrite(im_data_result_IFFT, "%d\n", Ifft_yOut_im);
      $fwrite(validOut_result_IFFT, "%b\n", validOut_IFFT );
end

// write output data from FFT to file
always @(posedge clk) begin 
      $fwrite(re_data_result_FFT, "%d\n", yOut_re);
      $fwrite(im_data_result_FFT, "%d\n", yOut_im);
end 

// file handling 
always begin 

  repeat(3) @(posedge clk); // delay allows for files to be opened properly before proceeding 

  if(!yIn_data ||  !re_data_result_IFFT || !im_data_result_IFFT) // !im_data_result_FFT || !re_data_result_FFT || // check if file has been opened correctly
    $error("Files did not open");
  else begin 
    $display("File opened Succesfully");
    wait(clk_enable); // wait for FFT clock enable before loading in values
    while(!$feof(yIn_data)) begin 
      @(posedge clk) 
          $fscanf(yIn_data, "%h", data_rd);// read data synced to clock. This will simulate taking input value from ADC 
          repeat(15) @(posedge clk); // repeat to allow all bits of data_rd to be streamed to the input of the FFT
    end 

    $fclose(yIn_data); //close input file

    //wait for validOUT of FFT to be deasserted before ending simulation and closing FFT output files
    @(negedge validOut_FFT)
        $fclose(re_data_result_FFT);
        $fclose(im_data_result_FFT);

    //wait for validOUT of IFFT to be deasserted before ending simulation and closing IFFT output files
    @(negedge validOut_IFFT) 
        $fclose(re_data_result_IFFT);
        $fclose(im_data_result_IFFT);

    $stop;
  end

end
			
always @(posedge clk) // used to count the number of clock cycles 
    cycles <= cycles + 1; 

always // clock signal generation, consider speeding the clock up. 
  #10ns clk = ~clk;



endmodule 