module extender_5_to_16 (inputt, Extsign, outputt);

  
  input [4:0] inputt; 
	input Extsign; 
  output reg [15:0] outputt;
	always @* begin 
      if (Extsign && inputt[4])
          outputt = {11'b11111111111, inputt};
		else 
          outputt = {11'b00000000000, inputt};
	end
	
endmodule
