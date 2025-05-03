module extender_8_to_16 (inputt, Extsign, outputt);

  
  input [7:0] inputt; 
  input Extsign; 
  output reg [15:0] outputt;
	always @* begin 
      if (Extsign && inputt[7])
        outputt = {8'b11111111, inputt};
		else 
          outputt = {8'b00000000, inputt};
	end
	
endmodule