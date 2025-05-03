module Mux_4_to_1 (A, B, C, D, sel, outputt);
  input [15:0] A,B,C,D;
  input [1:0] sel;
  output reg [15:0] outputt;	
	always @* begin 
	
      case (sel) 
			2'b00 : outputt = A;
			2'b01 : outputt = B;
			2'b10 : outputt = C;
			2'b11 : outputt = D;
		endcase
end


endmodule
