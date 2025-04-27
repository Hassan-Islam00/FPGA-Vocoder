
// File: acdinterface.sv
// Description: interfaces with ADC ltc2308
// Author: Hassan Islam
// Date: 2024-02-11

module adcinterface(
 input logic clk, reset_n, // clock and reset
 input logic [2:0] chan, // ADC channel to sample
 output logic [11:0] result, // ADC result
 output logic data_valid, //indicates data recieved is valid /*ADDED SIGNAL @2024-03-11*/
 
 // ltc2308 signals
 output logic ADC_CONVST, ADC_SCK, ADC_SDI,
 input logic ADC_SDO
);

logic [4:0] count; // used to track states /*CHANGED FROM 15 to 4 @2024-03-11*//*CHANGED FROM 4 to 3 @2024-03-13*/
logic [5:0] SDI_WORD; // The word to be sent to SDI
//logic [11:0] result_buffer = 0; //value is loaded into this and then after 12 cycles into result
logic ADC_CONVST_NEXT; 


// Pulse ADC_CONVST for one cycle, then have it off for another to begin the sequence. 
always_ff @(negedge clk, negedge reset_n) begin 

    if(!reset_n) 
        ADC_CONVST <= 0;
    else 
        ADC_CONVST <= ADC_CONVST_NEXT; 
end 

//Send 6-bit config data 
always_ff @(negedge clk) begin 
    //implement a shift register 
    if(count >= 3 && count <=8) 
        ADC_SDI <= SDI_WORD[count - 3];
    else 
        ADC_SDI <= 0; 
end 

// Recieve 12-bit data from ADC
always_ff @(posedge clk)  begin   
    if(count >= 3 && count <= 14)
        result[14 - count] <= ADC_SDO; // MSB is recieved first
    else 
        result <= result; 
end 


// data valid is asserted when the full word is sent 
always_ff @(posedge clk) begin 
    if(count == 14)
			data_valid <= 1'b1;
	 else 
			data_valid <= 1'b0;
end


// increment count to track cycles 
always_ff @(posedge clk, negedge reset_n) begin
    if(!reset_n)
        count = 0;
    else 
        count <= count + 1;
end
 

assign SDI_WORD = {1'b0, 1'b1, chan[1], chan[2], chan[0], 1'b1}; 

assign ADC_SCK = (count >= 4) ? clk : 1'b0; // send ADC_SCK signal after ADC_convst is pulsed

assign ADC_CONVST_NEXT = (count == 1) ? 1'b1 : 1'b0; // pulse ADC_convst 


endmodule 