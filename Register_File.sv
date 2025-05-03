// Code your design here
module Register_File (RA, RB, RW, clk, RegWr, BusA, BusB, BusW);
  
  input [2:0] RA, RB, RW;
  input clk, RegWr;
  output reg [15:0] BusA, BusB; 
  input [15:0] BusW;   
  
  
  reg [15:0] my_registers [0:7];
  
  initial begin 
  
    for(int i=1;i<8;i++)begin
       
      my_registers[i] = $random;
    
    
    end
  
  
  end
  
  
  always @(posedge clk)begin 
  
    if (RegWr == 1 && RW != 0)begin 
    
      my_registers[RW] <= BusW;
    
    end
  
  end
  
  
  always @(*) begin 
  
    BusA = my_registers[RA];
    BusB = my_registers[RB];
  
  end
  
  
  
  
  
  
endmodule
  