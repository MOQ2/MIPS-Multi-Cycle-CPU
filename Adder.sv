module Adder (A,B,result);
  
  input [15:0] A, B;
  output reg [15:0] result;
  
  always @* begin 
    
     result = A + B;
    
  end
  
endmodule