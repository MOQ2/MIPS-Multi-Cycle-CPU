module Mux_2_to_1 (A, B, sel, outputt);
  input [15:0] A,B;
  input sel;
  output reg [15:0] outputt;	
	always @* begin 
	
      case (sel) 
			1'b0 : outputt = A;
			1'b1 : outputt = B;
		endcase
end


endmodule