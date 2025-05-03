`timescale 1ns/1ps

module full_cpu_tb;

    reg reset;
    reg clk;
  
  initial begin
    
    clk =0 ;
  	forever #5 clk= ~clk ; 
  end

    // Instantiate the full_cpu module
    full_cpu dut (
      .reset(reset),
      .clk(clk)
    );

    // Clock generation
    initial begin
      
      reset = 1'b0;
      #7 
      reset = 1 ;
    end



    // Finish the simulation after a certain time
    initial begin
        #400 $finish;
    end

endmodule