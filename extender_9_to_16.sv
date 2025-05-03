module extender_9_to_16 (inputt, Extsign, outputt);

  
  input [8:0] inputt; 
  input Extsign; 
  output reg [15:0] outputt;
	always @* begin 
      if (Extsign && inputt[8])
        outputt = {7'b1111111, inputt};
		else 
          outputt = {7'b0000000, inputt};
	end
	
endmodule