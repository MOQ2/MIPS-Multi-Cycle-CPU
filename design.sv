module full_cpu (reset, clk) ;
  input reset ;
  input clk ;
  
    
  
  

  
  
  // wires 
  
  wire [15:0] pc_add_to_inst_mem ;
  wire [15:0] inst_mem_inst_reg ;
   wire [15:0] mem_out_data_reg ;
  wire [0:15] inst_data; // change
  wire high ;
  wire low ;
  assign high = 1;
  assign low = 0 ;
  ////
  ////
  wire [15:0] bus_A ;
  wire [15:0] bus_B ;
  wire [15:0] reg_file_bus_B ;
  wire [15:0] reg_file_bus_A ;
  wire [2:0] A_add ;
  wire [2:0] B_add ;
  wire [2:0] W_add ;
  reg [15:0] two = 1;
  wire [15:0] next_pc;
	wire [15:0]	alu_out_reg_data ;
wire [15:0] B_adder_res;
  wire [15:0] write_back_data;
  wire [15:0] write_back_data_reg;
  
  wire [15:0] alu_mux_out ; 
  wire [15:0] mem_address_data ; 
  wire [15:0] mem_data_in ; 
    wire [15:0] mem_out_data;
    wire [15:0] extend_1_out;
    wire [15:0] extend_2_out;
    wire [15:0] extend_3_out;
    wire [15:0] alu_out  ;
  wire z , n , o,  RegWr, MemWr, MemRd, PCEN, IREN ,bus_en ;
    wire [15:0] pc_2 ;
    wire ext1 , ext2 ,ext3 , aluSrc , AddressSel,DataInSel;
  wire [1:0] RegSel1, RegSel2 , DestReg ;
  wire [4:0] state ;
      wire [1:0] ALUop ; 
  wire [1:0] PCsrc,WBSel;
  
  //register file  Register_File (RA, RB, RW, clk, RegWr, BusA, BusB, BusW);
  Register_File RF (.RA(A_add), .RB(B_add), .RW(W_add), .clk(clk), .RegWr(RegWr), .BusA(reg_file_bus_A), .BusB(reg_file_bus_B), .BusW(write_back_data) );
  

  
  // registers  ( outputt, clk, Enable, inputt, reset );
  Register pc (.outputt(pc_add_to_inst_mem) , .clk(clk) , .Enable(PCEN) , .inputt(next_pc) , .reset(reset) );
  Register inst( .outputt(inst_data) , .clk(clk) , .Enable(IREN) , .inputt(inst_mem_inst_reg) , .reset(reset) );
  
  Register A_reg ( .outputt(bus_A) , .clk(clk) , .Enable(bus_en) , .inputt(reg_file_bus_A) , .reset(reset)  ) ; 
  Register B_reg ( .outputt(bus_B) , .clk(clk) , .Enable(bus_en) , .inputt(reg_file_bus_B) , .reset(reset)  ) ; 
  
  Register mem_out_reg ( .outputt(mem_out_data_reg) , .clk(clk) , .Enable(high) , .inputt(mem_out_data) , .reset(reset)  );
  
  
  Register alu_out_reg ( .outputt(alu_out_reg_data) , .clk(clk) , .Enable(high) , .inputt(alu_out) , .reset(reset)  ) ; 
  
  
//   Register write_Back_out_reg ( .outputt(write_back_data_reg) , .clk(clk) , .Enable(high) , .inputt(write_back_data) , .reset(reset)  );
  
  
  
    //change
  always @(posedge clk) begin 
    $display("enable before finishing %d" , RegWr);
    $display("enable after delay %d" , RegWr);
    $display("Time: %d | PC: %h | Instruction: %h | ALU Out: %h | Mem Out: %h | Write Back: %h",
      $time, pc_add_to_inst_mem, inst_data, alu_out, mem_out_data, write_back_data);
    $display("time :%d , Registers - A: %h, B: %h, W: %h",$time, reg_file_bus_A, reg_file_bus_B, write_back_data);
    
  $display("Time: %0t | PC Register - Input: %h, Output: %h", $time, next_pc, pc_add_to_inst_mem);
    $display("Time: %0t | Instruction Register - Input: %h, Output: %h", $time, inst_mem_inst_reg, inst_data);
    $display("Time: %0t | A Register - Input: %h, Output: %h", $time, reg_file_bus_A, bus_A);
    $display("Time: %0t | B Register - Input: %h, Output: %h", $time, reg_file_bus_B, bus_B);
    $display("Time: %0t | Memory Output Register - Input: %h, Output: %h", $time, mem_out_data, mem_out_data_reg);
    $display("Time: %0t | ALU Output Register - Input: %h, Output: %h", $time, alu_out, alu_out_reg_data);
    $display("Time: %0t | Write Back Register - Input: %h, Output: %h", $time, write_back_data, write_back_data);
    $display("Time: %0t | Register File - A Addr: %h, B Addr: %h, W Addr: %h, Bus A: %h, Bus B: %h, Bus W: %h , enable : %d", 
      $time, A_add, B_add, W_add, reg_file_bus_A, reg_file_bus_B, write_back_data , RegWr);  
    
    $display(" selection : %d  address - A    A: %h, B: %h, C: %h, D: %h  en : %d",RegSel1 , inst_data[8:10] ,{low,low,low} , inst_data[7:9],{high , high , high} , bus_en );
 
  end
  // Mux_2_to_1 (A, B, sel, outputt)
  


  Mux_2_to_1 alu_in_mux (.A(bus_B), .B(extend_1_out), .sel(aluSrc), .outputt(alu_mux_out));
  Mux_2_to_1 mem_address_in_mux (.A(bus_B), .B(alu_out_reg_data), .sel(AddressSel), .outputt(mem_address_data));
  Mux_2_to_1 mem_data_in_mux (.A(bus_B), .B(extend_2_out), .sel(DataInSel), .outputt(mem_data_in));
  
  
  // Mux_4_to_1 (A, B, C, D, sel, outp utt)
  // 3 bit
  mux4to1_3bit Reg_file_A_in_mux (.A(inst_data[8:10]), .B({low,low,low}), .C(inst_data[7:9]), .D({high , high , high}), .sel(RegSel1), .outputt(A_add));
  
  mux4to1_3bit Reg_file_B_in_mux (.A(inst_data[10:12]), .B(inst_data[5:7]), .C(inst_data[4:6]), .D({high , high , high}) ,.sel(RegSel2), .outputt(B_add));
  
  mux4to1_3bit Reg_file_W_in_mux (.A(inst_data[4:6]), .B(inst_data[5:7]), .C({high,high,high}),.D({high , high , high}) , .sel(DestReg), .outputt(W_add));
  // 15 bit
 
 // wire [15:0] next_pc;
 // wire [15:0] write_back_data;
 // wire [15:0] B_adder_res;
  Mux_4_to_1 mem_out_mux (.A(alu_out_reg_data), .B(mem_out_data_reg), .C(extend_3_out), .D(pc_2), .sel(WBSel), .outputt(write_back_data));
  
  
  Mux_4_to_1 pc_in_mux (.A(pc_2), .B(bus_B), .C(B_adder_res), .D({pc_add_to_inst_mem[15:12] , inst_data[4:15] }), .sel(PCsrc), .outputt(next_pc));

  
  // mem 
  // inst mem
  instructionMemory inst_mem (.Address(pc_add_to_inst_mem), .Instruction(inst_mem_inst_reg), .clk(clk) ) ;
  
  

  // data mem Data_Memory ( clk, MemWr, MemRd, Address,  Data_in, Output);
  Data_Memory data_mem ( .clk(clk), .MemWr(MemWr), .MemRd(MemRd), .Address(mem_address_data),  .Data_in(mem_data_in), .Output(mem_out_data) );
  
  
  // extender 
  

  //extender_5_to_16 (inputt, Extsign, outputt);
  extender_5_to_16 extender_1 ( .inputt(inst_data[11:15]), .Extsign(ext1), .outputt(extend_1_out) );

  //extender_9_to_16 (inputt, Extsign, outputt);
  extender_9_to_16 extender_2 ( .inputt(inst_data[7:15]), .Extsign(ext2), .outputt(extend_2_out) );
  

  //extender_8_to_16 (inputt, Extsign, outputt);
  extender_8_to_16 extender_3 ( .inputt(mem_out_data_reg[7:0]), .Extsign(ext3), .outputt(extend_3_out) );
  ///////
  
  // adder 
  // alu Alu (Rs, Rt, op ,res, zero, negative,  overflow)

  Alu alu (.Rs(alu_mux_out), .Rt(bus_A), .op(ALUop) ,.res(alu_out), .zero(z), .negative(n),  .overflow(o) );
  
  // 16-bit adder for branches module Adder (A,B,result)
  Adder branches_adder (.A(extend_1_out),.B(pc_add_to_inst_mem),.result(B_adder_res));
  
  // 16 bit adder for  next inst make input +2 

  Adder next_pc_adder  (.A(two),.B(pc_add_to_inst_mem),.result(pc_2));
  
  //contorl units 
  
  
  // main contorl module Main_Control ( opcode,input mode,input clk,input reset,output reg [1:0] Ext1, Ext2, Ext3, AluSrc, AddressSel, DataInSel, WBSel,
 	//output reg RegSel1, RegSel2, DestReg, MEMR, MEMW, RegW, PCEN, IREN,
  	//output reg [4:0] state
	//);

  
  //  RegWr, MemWr, MemRd
  
  Main_Control main_cont (
    .opcode(inst_data[0:3]),
    .mode(inst_data[4]),
    .clk(clk),
    .reset(reset),
    .Ext1(ext1) , .Ext2(ext2) , .Ext3(ext3), .AluSrc(aluSrc), .AddressSel(AddressSel), .DataInSel(DataInSel), .WBSel(WBSel),
    .RegSel1(RegSel1), .RegSel2(RegSel2) , .DestReg(DestReg) , .MEMR(MemRd) , .MEMW(MemWr) , .RegW(RegWr), .PCEN(PCEN), .IREN(IREN), .bus_en(bus_en),
    .state(state)
);
  

  // alu contro  ALU_Control (opcode, ALUop);
  ALU_Control alu_cont (.opcode(inst_data[0:3]) , .ALUop(ALUop) );
  
  
  // pc contorl PC_Control (opcode, PCsrc, Z, N, V);

  PC_Control aa ( .opcode(inst_data[0:3]), .PCsrc(PCsrc), .Z(z), .N(n), .V(o) );
  
  /////
  
  
  
endmodule 




module mux4to1_3bit (A, B, C, D, sel, outputt);
  input [2:0] A,B,C,D;
  input [1:0] sel;
  output reg [2:0] outputt;	
	always @* begin 
	
      case (sel) 
			2'b00 : outputt = A;
			2'b01 : outputt = B;
			2'b10 : outputt = C;
			2'b11 : outputt = D;
		endcase
end


endmodule






module Main_Control (
  input [3:0] opcode,
  input mode,
  input clk,
  input reset,
  output reg  Ext1, Ext2, Ext3, AluSrc, AddressSel, DataInSel, PCEN, IREN , bus_en 
  ,MEMR, MEMW, RegW,
  output reg [1:0] RegSel1, RegSel2, DestReg, WBSel,
  output reg [4:0] state
  
);

  wire IsAndi;
  reg [4:0] next_state ;
  parameter FetchStage = 5'd0; 
  parameter DecodeStage = 5'd1; 
  parameter ComputeAddress = 5'd2; 
  parameter LoadMEMAccess = 5'd3; 
  parameter StoreMEMAccess = 5'd4;
  parameter LBStoreStage = 5'd5;
  parameter LWStoreStage = 5'd6;
  parameter ALUcomputeRT = 5'd7;
  parameter RTResStore = 5'd8;
  parameter ALUcomputeIT = 5'd9;
  parameter ITResStore = 5'd10;
  parameter CallInstruction = 5'd11;
  parameter RETInstruction = 5'd12;
  parameter SVGetAddress = 5'd13;
  parameter SVMemAccess = 5'd14;
  parameter BranchM1 = 5'd15;
  parameter BranchM2 = 5'd16;

  parameter BGT = 4'b1000;
  parameter BLT = 4'b1001;
  parameter BEQ = 4'b1010;
  parameter BNE = 4'b1011;
  parameter BGTZ = 4'b1000;
  parameter BLTZ = 4'b1001;
  parameter BEQZ = 4'b1010;
  parameter BNEZ = 4'b1011; 
  parameter AND = 4'b0000;
  parameter ADD = 4'b0001;
  parameter SUB = 4'b0010;
  parameter ADDI = 4'b0011;
  parameter ANDI = 4'b0100;
  parameter LW = 4'b0101;
  parameter LBu = 4'b0110;
  parameter LBs = 4'b0110;
  parameter SW = 4'b0111;
  parameter SV = 4'b1111; 
  parameter CALL = 4'b1101;
  parameter JMP = 4'b1100;
  parameter RET = 4'b1110;

  assign IsAndi = (opcode == ANDI); 
	
  initial begin 
    state <= FetchStage;
  end
  
  
  
  always @(posedge clk or negedge reset) begin
    if (!reset)
      state <= FetchStage;
    else begin
      
      case (state)  
        FetchStage:begin 
          state <= DecodeStage;
          
        
        end
          
        DecodeStage: begin
          
        
          case (opcode) 
            
            AND, ADD, SUB:
              begin
                state <= ALUcomputeRT;
                next_state = ALUcomputeRT ;
            
              end
            
            
            LW, SW, LBu, LBs:
              begin
              
                state <= ComputeAddress; 
                next_state = ComputeAddress;
              end
              
            BEQ, BNE, BGT, BLT, BEQZ, BNEZ, BGTZ, BLTZ: begin
              if (mode) 
                begin 
                state <= BranchM1;
                next_state = BranchM1;
                end
              
              
              else 
                begin 
                
                  state <= BranchM2;    
              	
                  next_state = BranchM2;
                end
              
            end
            
            
            JMP: begin 
              next_state =  FetchStage;
              state <= FetchStage; 
            end
            
            
            ANDI, ADDI: 
              begin

                state <= ALUcomputeIT;
                next_state =  ALUcomputeIT;
            end
            CALL:begin
              state <= CallInstruction;
              next_state =  CallInstruction;
            end
              
            RET: begin
              state <= RETInstruction;
              next_state =  RETInstruction;
            end
              
            SV:begin
            
              state <= SVGetAddress;
              next_state =  SVGetAddress;
            end
            
          endcase
        end
        ALUcomputeRT: state <= RTResStore;
        ComputeAddress: begin
          case (opcode) 
            LW: state <= LoadMEMAccess; 
            SW: state <= StoreMEMAccess;
          endcase
        end
        LoadMEMAccess: begin
          case (opcode) 
            LW: state <= LWStoreStage;
            LBu, LBs: state <= LBStoreStage;
          endcase
        end
        ALUcomputeIT: state <= ITResStore;
        SVGetAddress: state <= SVMemAccess;
        StoreMEMAccess, LWStoreStage, LBStoreStage, RTResStore, CallInstruction, BranchM1, BranchM2, RETInstruction, SVMemAccess, ITResStore:
          state <= FetchStage;
      endcase
    end
    
     $display ("decode stage!!");
     $display ("state : %d , next_state : %d " , state , next_state );
     $display ("decode stage!!");
        	
  end 
	
  always @* begin
    RegSel1 = 0;
    RegSel2 = 0;
    DestReg = 0;
    Ext1 = 0;
    Ext2 = 0;
    Ext3 = 0;
    AluSrc = 0;
    AddressSel = 0;
    DataInSel = 0;
    WBSel = 0;
    MEMR = 0; 
    MEMW = 0;
    RegW = 0;
    PCEN = 0;
    IREN = 0; 
    bus_en = 0 ;
    
    
    case (state) 
      FetchStage: begin
        PCEN = 1;
        IREN = 1;
      end
      DecodeStage: begin
        MEMR = 0; 
        MEMW = 0;
        RegW = 0;
        bus_en = 1 ;
        if (next_state == ComputeAddress )
          begin 
            RegSel1 = 2'b00;
            //RegSel2 = 2'b01;
          end
        else if (next_state == ALUcomputeRT)
          begin
        
            RegSel1 = 2'b10; // changed from 0
            RegSel2 = 2'b00;
            
          end
        else if (next_state == ALUcomputeIT)
          begin
              
            RegSel1 = 2'b10;

          end
        
        else if (next_state == RETInstruction)
          begin
            RegSel1 = 2'b11;

          end
        
        else if (next_state == SVGetAddress)
          begin
                RegSel2 = 2'b10;

          end
        else if (next_state == BranchM1)
          begin
         
            RegSel1 = 2'b10;
            RegSel2 = 2'b01;
          end
        
        else if (next_state == BranchM2)
          begin
                
            RegSel1 = 2'b01;
            RegSel2 = 2'b01;
          end
        
		               
        //bus_en = 1 ;

      end
      ComputeAddress: begin
        Ext1 = 1;
        AluSrc = 1;
      end
      LoadMEMAccess: begin
        AddressSel = 1;
        MEMR = 1; 
        MEMW = 0;
      end
      StoreMEMAccess: begin
        AddressSel = 1;
        MEMR = 0; 
        MEMW = 1;
        DataInSel = 0;
      end
      LBStoreStage: begin
        DestReg = 2'b01;
        Ext3 = !mode;
        WBSel = 2'b10;
        RegW = 1;
      end
      	LWStoreStage: begin
        DestReg = 2'b01;
        WBSel = 2'b01;
        RegW = 1;
          
        end
      ALUcomputeRT: begin
        
        AluSrc = 0;
      end
      RTResStore: begin
        DestReg = 2'b00;
        WBSel = 2'b00;
        RegW = 1;
      end
      ALUcomputeIT: begin
        Ext1 = !IsAndi;
        AluSrc = 1;
      end
      ITResStore: begin
        DestReg = 2'b01;
        RegW = 1;
      end
      CallInstruction: begin
        DestReg = 2'b10;
        WBSel = 2'b11;
        RegW = 1;

      end
      SVGetAddress: begin
        Ext2 = 1;
      end
      SVMemAccess: begin
        AddressSel = 0;
        DataInSel = 1;
        MEMR = 0; 
        MEMW = 1;
      end
      BranchM1: begin
       
        Ext1 = 1;
        AluSrc = 0;
      end
      BranchM2: begin

        Ext1 = 1;
        AluSrc = 0;
      end
    endcase
  end
	 
endmodule







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
    case (opcode) 
      
      BGT, BLT, BEQ, BNE, SUB: ALUop = SUBOP; 
      AND, ANDI: ALUop = ANDOP; 
      default: ALUop = ADDOP;
            
    endcase 
   
  end
  
  
endmodule



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

 
  


module Adder (A,B,result);
  
  input [15:0] A, B;
  output reg [15:0] result;
  
  always @(A,B) begin 
    
     result = A + B;
    
  end
  
endmodule



module extender_8_to_16 (inputt, Extsign, outputt);

  
  input [7:0] inputt; 
  input Extsign; 
  output reg [15:0] outputt;
	always @* begin 
      if (Extsign && inputt[7])
        outputt ={8'b11111111, inputt};
		
      else 
        outputt = {8'b00000000, inputt};
	end
	
endmodule



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





module Mux_2_to_1 (A, B, sel, outputt);
  input [15:0] A,B;
  input sel;
  output reg [15:0] outputt;	
	always @* begin 
	
      case (sel) 
			1'b0 : outputt = A;
			1'b1 : outputt = B;
		endcase
end


endmodule







module Register ( outputt, clk, Enable, inputt, reset );
    input clk, Enable, reset;
    input [15:0] inputt;
    output reg [15:0] outputt;
    
	always @(posedge clk or negedge reset) begin
	
	  if (!reset)
			outputt <= 0;
		
      else if (Enable) begin 
        $display ("register write time : %d", $time);
        
        outputt <= inputt;
      end
      
	end
	
endmodule






module Mux_4_to_1 (A, B, C, D, sel, outputt);
  input [15:0] A,B,C,D;
  input [1:0] sel;
  output reg [15:0] outputt;	
	always @* begin 
	
      case (sel) 
			2'b00 : outputt = A;
			2'b01 : outputt = B;
			2'b10 : outputt = C;
			2'b11 : outputt = D;
		endcase
end


endmodule






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
      $display ("time : %d  , address: %d   data in :%d   " , $time , Address , Data_in);
    end
    else if (MemRd) begin
      
      Output <= My_Data_Memory[Address];
      $display ("time : %d  , address: %d   data out :%d   " , $time , Address ,My_Data_Memory[Address] );
    end
  end

endmodule

module Alu (Rs, Rt, op ,res, zero, negative,  overflow);
  input signed [15:0] Rs, Rt;
  input [1:0] op;
  output reg   signed [15:0] res;
  output reg zero, negative, overflow;

  initial begin
  $display("** ALU  **");
  end

  always @(Rs, Rt , op) begin 
    $display("time: %t,Alu operation is %h",$time ,op);
    case (op)

      2'b01: begin
        $display("Added oprs are %h  %h", Rs, Rt);
      {overflow, res}  = Rs + Rt;
        $display("Alu res is %h", res);
      end 
      2'b10:
      {overflow, res} = Rs - Rt;
      2'b00 : begin 
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






// module Alu (Rs, Rt, op ,res, zero, negative,  overflow);
//   input signed [15:0] Rs, Rt;
//   input [1:0] op;
//   output reg   signed [15:0] res;
//   output reg zero, negative, overflow;
  
//   always @(*) begin 
   
//     case (op)
//       2'b00:
//       {overflow, res}  = Rs + Rt;
//       2'b01:
//       {overflow, res} = Rs - Rt;
//       2'b10 : begin 
//          res = Rs & Rt;
//          overflow = 0;
//       end
      
//     endcase
      
//     if (res == 0)begin 
//        zero = 1'b1;
//     end
//     else begin 
//        zero = 1'b0;
//     end
        
//      negative = res[15];
      
//   end
  
   
// endmodule



// Code your design here
module Register_File (RA, RB, RW, clk, RegWr, BusA, BusB, BusW);
  
  input [2:0] RA, RB, RW;
  input clk, RegWr;
  output reg [15:0] BusA, BusB; 
  input [15:0] BusW;   
  
  
  reg [15:0] my_registers [0:7];
  
  initial begin 
  
      my_registers[0] = 0;
      my_registers[1] = 1;
      my_registers[2] = 2;
      my_registers[3] = 3;
      my_registers[4]= 4;
      my_registers[5]= 5;
      my_registers[6]= 6;
      my_registers[7] = 7;
    
    
   /* for(int i=1;i<8;i++)begin
       
      my_registers[i] = $random;
    
    
    end*/
  
  
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
  
  
  always @ (posedge clk) begin
    $display("Time: %0d | r0: %h | r1: %h | r2: %h | r3: %h | r4: %h | r5: %h | r6: %h | r7: %h",
      $time,
      my_registers[0],
      my_registers[1],
      my_registers[2],
      my_registers[3],
      my_registers[4],
      my_registers[5],
      my_registers[6],
      my_registers[7]
    );
  end
  
  
  
  
  
endmodule
  





//change
module instructionMemory (Address, Instruction,clk);
  
  input clk;
  input [15:0] Address;
  output reg [15:0] Instruction;


  reg [15:0] My_Instruction_Memory [0: 1024];

    initial begin 
      $readmemh("mycode.dat", My_Instruction_Memory);
    end
  
   always @ (posedge clk)begin 
  	Instruction = My_Instruction_Memory[Address];
    
    

    
  end

endmodule
