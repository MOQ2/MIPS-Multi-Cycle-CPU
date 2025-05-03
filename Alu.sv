module Alu (Rs, Rt, op ,res, zero, negative,  overflow);
  input signed [15:0] Rs, Rt;
  input [1:0] op;
  output signed reg [15:0] res;
  output reg zero, negative, overflow;
  
  always @(*) begin 
  
    case (op)begin 
      2'b00:
         {overflow, res} = Rs + Rt;
      2'b01:
         {overflow, res} = Rs - Rt;
      2'b10 : begin 
         res = Rs & Rt;
         overflow = 0;
      end
      
    endcase
      
    if (res == 0)begin 
       zero = 1'b1;
    end
    else begin 
       zero = 1'b0;
    end
        
     negative = res[15];
      
  end
  
   
endmodule