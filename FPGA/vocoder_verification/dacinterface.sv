module dacinterface (input logic clk,
                input logic [15:0] d,
                output logic clk_out, cs, din);
                     
logic [5:0] count = 0;

assign clk_out = ~cs ? clk : 0 ;
always_ff @(negedge clk) cs <= count < 16 ? 0 : 1;

always_ff @(posedge clk) count <= count - 1;
always_ff @(negedge clk) din <= count < 16 ? d[count] : din;


endmodule