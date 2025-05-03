




module PC_Control (opcode, PCsrc, Z, N, V);
    input [3:0] opcode;
    input Z,N,V;
    output reg [1:0] PCsrc;
    parameter BGT   = 4'b1000;
    parameter BLT   = 4'b1001;
    parameter BEQ   = 4'b1010;
    parameter BNE   = 4'b1011;
    parameter JMP   = 4'b1100;
    parameter CALL  = 4'b1101;
    parameter RET   = 4'b1110;
  
  
  always @* begin 
  
    if ( ( (opcode == BEQ) && Z )||( (opcode ==BGT) && (!Z || (N != V)) ) ||    ((opcode == BLT) && ((N != V)) ) ||  ( (opcode == BNE) && !Z )) 
    begin 
        
        PCsrc = 2'b10;
    
    end
    else if ((opcode == JMP) ||  (opcode == CALL)) begin 
    
        PCsrc = 2'b11;
    
    end
    else if (opcode == RET) begin 
    
     PCsrc = 2'b01;
    
    end
    else begin 
    
      PCsrc = 2'b00;
    
    
    end
    
  
  
  
  end
    
  
endmodule 

 
  