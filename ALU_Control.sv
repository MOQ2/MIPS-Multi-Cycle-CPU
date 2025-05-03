

module ALU_Control (opcode, ALUop);
  
  input [3:0] opcode;
  output reg [1:0] ALUop;
  
  parameter ANDOP = 2'b00;
  parameter ADDOP = 2'b01;
  parameter	SUBOP = 2'b10;
  
  parameter BGT   = 4'b1000;
  parameter BLT   = 4'b1001;
  parameter BEQ   = 4'b1010;
  parameter BNE   = 4'b1011;
  parameter AND   = 4'b0000;
  parameter ADD   = 4'b0001;
  parameter SUB   = 4'b0010;
  parameter ADDI  = 4'b0011;
  parameter ANDI  = 4'b0100;
  parameter LW    = 4'b0101;
  parameter LBu   = 4'b0110;
  parameter LBs   = 4'b0110;
  parameter SW    = 4'b0111;
  
  
  always @* begin 
    case (opcode) begin 
      
      BGT, BLT, BEQ, BNE, SUB: ALUop = SUBOP; 
      AND, ANDI: ALUop = ANDOP; 
      default: ALUop = ADDOP;
            
    endcase 
   
  end
  
  
endmodule