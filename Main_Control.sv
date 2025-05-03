module Main_Control (
  input [3:0] opcode,
  input mode,
  input clk,
  input reset,
  output reg  Ext1, Ext2, Ext3, AluSrc, AddressSel, DataInSel, PCEN, IREN,
  output reg [1:0] RegSel1, RegSel2, DestReg, MEMR, MEMW, RegW, ,WBSel,
  output reg [4:0] state
);

  wire IsAndi;

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
	
  always @(posedge clk or negedge reset) begin
    if (!reset)
      state <= FetchStage;
    else begin
      case (state)  
        FetchStage: state <= DecodeStage;
        DecodeStage: begin
          case (opcode)
            AND, ADD, SUB: state <= ALUcomputeRT;   
            LW, SW, LBu, LBs: state <= ComputeAddress; 
            BEQ, BNE, BGT, BLT, BEQZ, BNEZ, BGTZ, BLTZ: begin
              if (mode) state <= BranchM1;
              else state <= BranchM2;    
            end
            JMP: state <= FetchStage; 
            ANDI, ADDI: state <= ALUcomputeIT;
            CALL: state <= CallInstruction;
            RET: state <= RETInstruction;
            SV: state <= SVGetAddress;
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
  end
	
  always @(*) begin
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

    case (state) 
      FetchStage: begin
        PCEN = 1;
        IREN = 1;
      end
      DecodeStage: begin
        MEMR = 0; 
        MEMW = 0;
        RegW = 0;
      end
      ComputeAddress: begin
        RegSel1 = 2'b10;
        RegSel2 = 2'b01;
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
        RegSel1 = 2'b00;
        RegSel2 = 2'b00;
        AluSrc = 0;
      end
      RTResStore: begin
        DestReg = 2'b00;
        WBSel = 2'b00;
        RegW = 1;
      end
      ALUcomputeIT: begin
        RegSel1 = 2'b10;
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
      RETInstruction: begin
        RegSel1 = 2'b11;
      end
      SVGetAddress: begin
        RegSel2 = 2'b10;
        Ext2 = 1;
      end
      SVMemAccess: begin
        AddressSel = 0;
        DataInSel = 1;
        MEMR = 0; 
        MEMW = 1;
      end
      BranchM1: begin
        RegSel1 = 2'b10;
        RegSel2 = 2'b01;
        Ext1 = 1;
        AluSrc = 0;
      end
      BranchM2: begin
        RegSel1 = 2'b01;
        RegSel2 = 2'b01;
        Ext1 = 1;
        AluSrc = 0;
      end
    endcase
  end
endmodule
