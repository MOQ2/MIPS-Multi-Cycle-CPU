module Register ( outputt, clk, Enable, inputt, reset );
    input clk, Enable, reset;
    input [15:0] inputt;
    output reg [15:0] outputt;
	always @(posedge clk or negedge reset) begin
	
	  if (!reset)
			outputt <= 0;
		
      else if (Enable)
			outputt <= inputt; 
	end
	
endmodule
