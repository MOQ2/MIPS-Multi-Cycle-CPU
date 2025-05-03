module Data_Memory (
  input clk,
  input MemWr,
  input MemRd,
  input [15:0] Address,
  input [15:0] Data_in,
  output reg [15:0] Output
);

  reg [15:0] My_Data_Memory [0:1023];

  initial begin
    $readmemh("DataMemory.dat", My_Data_Memory);
  end

  always @(posedge clk) begin
    if (MemWr) begin
      My_Data_Memory[Address] <= Data_in;
    end
    else if (MemRd) begin
      Output <= My_Data_Memory[Address];
    end
  end

endmodule