// main module
module full_cpu (
    input wire clk,             // Clock input
    input wire reset,           // Reset input
    output wire [15:0] data_out  // Data output
);


wire [15:0]  pc_mux_out , mem_data_out_buffer , mem_data_out , pc_add_out_buffer  , inst_mem_inst , bus_A , bus_B , alu_src_mux_out ,extender_1_out ,  extender_2_out , extender_3_out , data_in_mem_mux_out , address_in_mem_mux_out;  
wire  [15:0] alu_out;
wire [0:15]  inst_data;

wire [15:0] pc_2 , pc_branch , write_back_data;

wire [2:0] A_mux_A_add_buffer , B_mux_B_add_buffer , regF_in_A , regF_in_B ,write_reg_file_in;

wire we , re ,  mem_address_sel , data_memory_in_sel,  ext_1_sel , ext_2_sel , ext_3_sel , alu_src , pc_en , write_reg_file_en ,  write_reg_fileA_en , write_reg_fileB_en , mem_data_sel ;
wire [1:0]    WB_mem_sel , op  ;
wire  [1:0]  pc_mux_sel , mux_A_sel , mux_B_sel , write_reg_file_address_sel;
wire next_pc_overflow , pc_branch_overflow , o , n , z;


always @ (posedge clk )begin 
    // display for debugging what is the output of the pc buffer , the input to pc buffer , the output of the instruction memory buffer and the input to the instruction memory buffer
    // with time 
    //$display("\n");
    //$display("time %d",$time);
    //$display("opcode %h",inst_data[0:3]);
    //$display("pc_add_out_buffer %d  , pc in buffer: %d ",pc_add_out_buffer , pc_mux_out);
    //$display("selection of pc %h",pc_mux_sel);
    //$display("instruction memory %h",inst_mem_inst);
    //$display("inst_data %h",inst_data);
    //$display("alu out result of alu  %d" , alu_out);
    //$display("bus_A data  %h",bus_A);
    //$display("bus_B data  %h",bus_B);
    //$display("ALU second source data (what will be in the alu ) %h",alu_src_mux_out);
    // write back data
    //$display("write_back_data %h",write_back_data);
    // write back selection
    //$display("WB_mem_sel %h",WB_mem_sel);
    // wirte back enable
    //$display("write back enable %h",write_reg_file_en);
    //$display("end\n\n\n");



end


assign inst_data = inst_mem_inst;


stage_buffer pc_address_buffer (
    .clk(clk),
    .en( pc_en ),
    .data_in(pc_mux_out),
    .data_out(pc_add_out_buffer)
);



stage_buffer_3_bit Address_A_buffer (
    .clk(clk),
    .en( write_reg_fileA_en ),
    .data_in(A_mux_A_add_buffer),
    .data_out(regF_in_A)
);


stage_buffer_3_bit Address_B_buffer (
    .clk(clk),
    .en( write_reg_fileB_en ),
    .data_in(B_mux_B_add_buffer),
    .data_out(regF_in_B)
);



assign mem_data_out_buffer  =  mem_data_out  ;



register_file reg_file (
    .clk(clk),
    .read_reg1(regF_in_A),
    .read_reg2(regF_in_B),
    .write_reg(write_reg_file_in),
    .write_data(write_back_data),
    .reg_write( write_reg_file_en ),
    .read_data1(bus_A),
    .read_data2(bus_B)
);




alu_16bit alu (
    .a(bus_A),
    .b(alu_src_mux_out),
    .alu_op(op),
    .result(alu_out),
    .overflow(o),
    .negative(n),
    .zero(z)
);

adder_16bit pc_adder_normal (
    .a(pc_add_out_buffer),
    .b(16'h002), // change to 1 for 1 byte addressable
    .sum(pc_2),
    .overflow( next_pc_overflow )
);

adder_16bit pc_adder_branch (
    .a(extender_1_out),
    .b(pc_add_out_buffer),
    .sum(pc_branch),
    .overflow(pc_branch_overflow)
);


data_memory data_memory (
    .clk(clk),
    .address( address_in_mem_mux_out ),
    .data_in(data_in_mem_mux_out),
    .we ( we ),
    .re( re ),
    .data_out(mem_data_out)
);



instruction_memory instruction_memory (
    .clk(clk),
    .address(pc_add_out_buffer),
    .data_out(inst_mem_inst)
);


control_unit control_unit (
    .clk(clk),
    .reset(reset),
    .opcode(inst_data[0:3]),
    .over_flow(o),
    .negative(n),
    .zero(z),
    .mode(inst_data[4]),
    .we(we),
    .re(re),
    .Ext_1_sign_ext(ext_1_sel),
    .Ext_2_sign_ext(ext_2_sel),
    .Ext_3_sign_ext(ext_3_sel),
    .alu_op(op),
    .alu_src(alu_src),
    .pc_mux_sel(pc_mux_sel),
    .reg_file_in1(mux_A_sel),
    .reg_file_in2(mux_B_sel),
    .write_reg_file(write_reg_file_en),
    .reg_file_write_address(write_reg_file_address_sel),
    .buffer_reg_fileA_en(write_reg_fileA_en),
    .buffer_reg_fileB_en(write_reg_fileB_en),
    .buffer_pc_en(pc_en),
    .addressSel(mem_address_sel),
    .data_memory_in_sel(mem_data_sel),
    .write_back_sel(WB_mem_sel)
);


mux4to1_16bit pc_mux (
    .in0(pc_2),
    .in1(bus_A), // changed
    .in2(pc_branch),
    .in3({pc_add_out_buffer[15:12] , inst_data[4:15]}),
    .sel( pc_mux_sel ),
    .out(pc_mux_out)
);
mux4to1_16bit data_memory_mux (
    .in0(alu_out),
    .in1(mem_data_out_buffer),
    .in2(extender_3_out),
    .in3(pc_2),
    .sel( WB_mem_sel ),
    .out(write_back_data)
);

mux4to1_3bit address_A_mux (
    .sel( mux_A_sel ),
    .in0(inst_data[7:9]),
    .in1(3'b000),
    .in2(inst_data[8:10]),
    .in3(3'b111),
    .out(A_mux_A_add_buffer)
);

mux4to1_3bit address_B_mux (
    .sel( mux_B_sel ),
    .in0(inst_data[10:12]),
    .in1(inst_data[5:7]),
    .in2(inst_data[4:6]),
    .in3(3'b111),
    .out(B_mux_B_add_buffer)
);


mux4to1_3bit reg_file_write_back_address_mux (
    .sel( write_reg_file_address_sel ),
    .in0(inst_data[4:6]),
    .in1(inst_data[5:7]),
  .in2(3'b111),
  .in3(3'b000),
    .out(write_reg_file_in)
);

mux2to1_16bit data_in_mem_mux (
    .in0(bus_B),
    .in1(extender_2_out),
    .sel( mem_data_sel ),
    .out(data_in_mem_mux_out)
);

mux2to1_16bit address_in_mem_mux (
    .in0(bus_B),
    .in1(alu_out),
    .sel( mem_address_sel ),
    .out(address_in_mem_mux_out)
);

mux2to1_16bit alu_in (
    .in0(bus_B),
    .in1(extender_1_out),
    .sel( alu_src ),
    .out(alu_src_mux_out)
);



extender_5to16 extender_1 (
    .data_in(inst_data[11:15]),
    .sign_ext( ext_1_sel ),
    .data_out(extender_1_out)
);


extender_9to16 extender_2 (
    .data_in(inst_data[7:15]),
    .sign_ext( ext_2_sel ),
    .data_out(extender_2_out)
);

extender_8to16 extender_3 (
    .data_in(mem_data_out_buffer[7:0]),
    .sign_ext( ext_3_sel ),
    .data_out(extender_3_out)
);

endmodule




//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
/////
/////   MODULES
/////
//////////////////////////////////////////
//////////////////////////////////////////



// buffer with 3 bit input and output
module stage_buffer_3_bit (
    input wire clk,             // Clock input
    input wire en,              // Enable signal to write data
    input wire [2:0] data_in,   // Data input
    output reg [2:0] data_out   // Data output
);

    // Buffer register
    reg [2:0] buffer;

    // Write operation
    always @(posedge clk) begin
        if (en) begin
            buffer <= data_in;
        end
    end

    // Continuous assignment to output
    assign data_out = buffer;

endmodule





// main cotrol unit
module control_unit (
    input wire clk,
    input wire reset,
    input wire [3:0] opcode,
    input wire over_flow,
    input wire negative,
    input wire zero,
    input wire mode,
    output reg we,
    output reg re,
    output reg Ext_1_sign_ext,
    output reg Ext_2_sign_ext,
    output reg Ext_3_sign_ext,
    output reg [1:0] alu_op,
    output reg alu_src,
    output reg [1:0] pc_mux_sel,
    output reg [1:0] reg_file_in1,
    output reg [1:0] reg_file_in2,
    output reg write_reg_file,
    output reg [1:0] reg_file_write_address,
    output reg buffer_reg_fileA_en,
    output reg buffer_reg_fileB_en,
    output reg buffer_pc_en,
    output reg addressSel,
    output reg data_memory_in_sel,
    output reg [1:0] write_back_sel
);

    // Stage and instruction type definitions
    reg [2:0] current_stage, next_stage;
    reg [1:0] inst_type;
    reg reset_flage = 0;
    reg greater_than , less_than , equal , not_equal;
    localparam FETCH = 3'b000, DECODE = 3'b001, EXECUTE = 3'b010, MEMORY = 3'b011, WRITE_BACK = 3'b100;
    localparam R_TYPE = 2'b00, I_TYPE = 2'b01, J_TYPE = 2'b10, S_TYPE = 2'b11;

    // Instruction opcodes
    localparam AND = 0, ADD = 1, SUB = 2, ADDI = 3, ANDI = 4, LW = 5, LBU = 6, SW = 7,
            BGT = 8, BLT = 9, BEQ = 10, BNE = 11, J = 12, CALL = 13, RET = 14, SV = 15;

    initial begin 
        we = 0;
        re = 0;
        Ext_1_sign_ext = 0;
        Ext_2_sign_ext = 0;
        Ext_3_sign_ext = 0;
        alu_op = 0;
        alu_src = 0;
        pc_mux_sel = 0;
        reg_file_in1 = 0;
        reg_file_in2 = 0;
        write_reg_file = 0;
        reg_file_write_address = 0;
        buffer_reg_fileA_en = 0;
        buffer_reg_fileB_en = 0;
        buffer_pc_en = 0;
        addressSel = 0;
        data_memory_in_sel = 0;
        write_back_sel = 0;
        greater_than = 0;
        less_than = 0;
        equal = 0;
        not_equal = 0;

    end



    // Sequential logic for stage transitions
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            we = 0;
            re = 0;
            Ext_1_sign_ext = 0;
            Ext_2_sign_ext = 0;
            Ext_3_sign_ext = 0;
            alu_op = 0;
            alu_src = 0;
            pc_mux_sel = 0;
            reg_file_in1 = 0;
            reg_file_in2 = 0;
            write_reg_file = 0;
            reg_file_write_address = 0;
            buffer_reg_fileA_en = 0;
            buffer_reg_fileB_en = 0;
            buffer_pc_en = 0;
            addressSel = 0;
            data_memory_in_sel = 0;
            write_back_sel = 0;
            current_stage <= FETCH;
        end else begin
            
            current_stage <= next_stage;
        end
    end

    // Combinational logic for next stage determination
    always @(*) begin
        if ( ~reset ) begin
        case (current_stage)
            FETCH: next_stage = DECODE;
            DECODE: begin
                case (opcode)
                    J, RET: next_stage = FETCH;
                    CALL: next_stage = WRITE_BACK;
                    SV : next_stage = MEMORY;
                    default: next_stage = EXECUTE;
                endcase
            end
            EXECUTE: begin
                if (opcode == BGT || opcode == BLT || opcode == BEQ || opcode == BNE)
                    next_stage = FETCH;
                else if (opcode == LW || opcode == LBU || opcode == SW )
                    next_stage = MEMORY;
                else
                    next_stage = WRITE_BACK;
            end
            MEMORY: 
            begin 
            if ( opcode == SV || opcode == SW)
                next_stage = FETCH;
            else
                next_stage = WRITE_BACK;
            end
            
            WRITE_BACK: next_stage = FETCH;
            default: next_stage = FETCH;
        endcase
        end
    end

    // Combinational logic for control signal assignment
    always @(*) begin
        if (~ reset ) begin
        // Default signal assignments
        we = 0;  
        reg_file_in1 = 0; reg_file_in2 = 0;
        write_reg_file = 0; buffer_reg_fileA_en = 0;
        buffer_reg_fileB_en = 0; buffer_pc_en = 0; // edited form buffer_pc_en = 0; 
        

        case (current_stage)
            FETCH: begin
                buffer_pc_en = 1;
                
            end

            DECODE: begin
                addressSel = 0;
                data_memory_in_sel = 0;
                buffer_pc_en = 0;
                buffer_reg_fileA_en = 1;
                buffer_reg_fileB_en = 1;
                $display("pc_mux_befor_reset in decode %h",pc_mux_sel);
                pc_mux_sel = 0;
                case (opcode)
                    ADD, AND, SUB: begin
                        reg_file_in1 = 2'b00;
                        reg_file_in2 = 2'b00;
                        reg_file_write_address = 2'b00;
                        alu_op = (opcode == AND) ? 0 : (opcode == ADD) ? 1 : 2;
                    end
                    ADDI, ANDI, LW, LBU: begin
                        reg_file_in1 = 2'b10;
                        reg_file_in2 = 2'b00;
                        reg_file_write_address = 2'b01;
                        Ext_1_sign_ext = (opcode != ANDI);
                        Ext_3_sign_ext = ~mode;
                        alu_op = (opcode == ANDI) ? 0 : 1;
                    end
                    SW: begin
                        reg_file_in1 = 2'b10;
                        reg_file_in2 = 2'b01;
                        Ext_1_sign_ext = 1;
                        alu_op = 1;
                    end
                    BGT, BLT, BEQ, BNE: begin
                        reg_file_in1 = mode ? 2'b01 : 2'b10;
                        reg_file_in2 = 2'b01;
                        Ext_1_sign_ext = 1;
                        alu_op = 2;
                    end
                    J: pc_mux_sel = 3;
                    CALL: begin
                        reg_file_write_address = 2'b10;
                        alu_op = 3;
                    end
                    RET: begin
                        reg_file_in1 = 2'b11;
                        pc_mux_sel = 1;
                    end
                    SV: begin
                        reg_file_in2 = 2'b10;
                        Ext_2_sign_ext = 1;
                        alu_op = 3;
                    end
                endcase
            end

            EXECUTE: begin
                greater_than = 0;
                less_than = 0;
                equal = 0;
                not_equal = 0;

                alu_src = 0;
                alu_src = (opcode == ADDI || opcode == ANDI || opcode == LW || opcode == LBU || opcode == SW);
                
                if (opcode == BGT || opcode == BLT || opcode == BEQ || opcode == BNE) begin
                    equal = zero;
                    not_equal = ~zero;
                    less_than = ~((negative ^ over_flow) & ~zero);
                    greater_than = ~((~(negative ^ over_flow)) & ~zero);
                    if ( 
                        (opcode == BGT && greater_than) || 
                        (opcode == BLT && less_than) || 
                        (opcode == BEQ && equal) || 
                        (opcode == BNE && not_equal)
                    )   begin
                        $display("branching");
                        pc_mux_sel = 2;
                    end else begin
                        pc_mux_sel = 0;
                    end

                end
            end

            MEMORY: begin

                re = 1;
                addressSel = (opcode != SV);
                data_memory_in_sel = (opcode != SW);
                
                if (opcode == SV || opcode == SW) begin
                    we = 1;
                end
            end

            WRITE_BACK: begin
                write_reg_file = 1;
                re=1;
                
                case (opcode)
                    ADD, AND, SUB, ADDI, ANDI: write_back_sel = 0;
                    LW: write_back_sel = 1;
                    LBU: write_back_sel = 2;
                    CALL: begin
                        write_back_sel = 3;
                        pc_mux_sel = 3;
                    end
                endcase
            end
        endcase
    end
    end

    // For debugging purposes
    always @(posedge clk) begin
        if (reset) begin
            $display("\n\nRESET  Time %d", $time);
        end else begin
        case (current_stage)
            FETCH: $display("\n\nFETCH Time %d" , $time );
            DECODE: $display("\n\nDECODE Time %d" , $time );
            EXECUTE: $display("\n\nEXECUTE Time %d" , $time );
            MEMORY: $display("\n\nMEMORY Time %d" , $time );
            WRITE_BACK: $display("\n\nWRITE_BACK Time %d" , $time );
        endcase
        end
    end

endmodule






module extender_8to16 (
    input wire [7:0] data_in,       // 8-bit input
    input wire sign_ext,            // Sign extension control signal
    output reg [15:0] data_out      // 16-bit output
);

    always @(*) begin
        if (sign_ext) begin
            // Sign extension
            data_out = {{8{data_in[7]}}, data_in};
        end else begin
            // Zero extension
            data_out = {8'b0, data_in};
        end
    end

endmodule

module extender_5to16 (
    input wire [4:0] data_in,       // 5-bit input
    input wire sign_ext,            // Sign extension control signal
    output reg [15:0] data_out      // 16-bit output
);

    always @(*) begin
        if (sign_ext) begin
            // Sign extension
            data_out = {{11{data_in[4]}}, data_in};
        end else begin
            // Zero extension
            data_out = {11'b0, data_in};
        end
    end

endmodule


module extender_9to16 (
    input wire [8:0] data_in,       // 9-bit input
    input wire sign_ext,            // Sign extension control signal
    output reg [15:0] data_out      // 16-bit output
);

    always @(*) begin
        if (sign_ext) begin
            // Sign extension
            data_out = {{7{data_in[8]}}, data_in};
        end else begin
            // Zero extension
            data_out = {7'b0, data_in};
        end
    end

endmodule




module instruction_memory (
    input wire clk,           // Clock input
    input wire [15:0] address, // Address input (assuming 16-bit address space)
    output reg [15:0] data_out // Data output
);

    // Memory array, for example 256 words of 16 bits each (change the size as needed)
    reg [7:0] memory [0:255];
    //reg [15:0] memory [0:255];
    // Initial block to load instructions into the memory (optional)
    initial begin
        $readmemh("instructions.dat", memory);
    end

    // Read operation
    always @(*) begin
        data_out =  {memory[address+1],memory[address]};
        //data_out = memory[address];
    end
endmodule



module mux4to1_16bit (
    input [15:0] in0,  // 16-bit input 0
    input [15:0] in1,  // 16-bit input 1
    input [15:0] in2,  // 16-bit input 2
    input [15:0] in3,  // 16-bit input 3
    input [1:0] sel,   // 2-bit select input
    output reg [15:0] out  // 16-bit output
);
always @(*) begin
    case (sel[1:0])  // Only using 2 LSBs of the 3-bit select input
        2'b00: out = in0;
        2'b01: out = in1;
        2'b10: out = in2;
        2'b11: out = in3;
        default: out = 16'h0000;  // Default case to avoid latches
    endcase
end
endmodule



module mux4to1_3bit (
    input wire [1:0] sel,       // Select input (3-bit wide)
    input wire [2:0] in0,       // Input 0 (3-bit wide)
    input wire [2:0] in1,       // Input 1 (3-bit wide)
    input wire [2:0] in2,       // Input 2 (3-bit wide)
    input wire [2:0] in3,       // Input 3 (3-bit wide)
    output reg [2:0] out        // Output (3-bit wide)
);
    always @(*) begin
        case (sel)
            3'b000: out = in0;
            3'b001: out = in1;
            3'b010: out = in2;
            3'b011: out = in3;
            // Add additional cases as needed
            default: out = 3'b000; // Default case to avoid latches
        endcase
    end
endmodule





module mux2to1_16bit (
    input [15:0] in0,  // 16-bit input 0
    input [15:0] in1,  // 16-bit input 1
    input sel,         // 1-bit select input
    output reg [15:0] out  // 16-bit output
);
always @(*) begin
    case (sel)
        1'b0: out = in0;
        1'b1: out = in1;
        default: out = 16'h0000;  // Default case to avoid latches
    endcase
end

endmodule






module data_memory (
    input wire clk,             // Clock input
    input wire [15:0] address,  // Address input
    input wire [15:0] data_in,  // Data input for write operations
    input wire we,              // Write enable
    input wire re,              // Read enable
    output reg [15:0] data_out  // Data output for read operations
);
    // Memory array, for example, 256 words of 16 bits each
    //reg [15:0] memory [0:255];
    reg [7:0] memory [0:255];
    // Read and write operations
    always @(posedge clk) begin
        if (we) begin
            // Write operation
            //memory[address] <= data_in;
            memory[address] <= data_in[7:0];
            memory[address+1] <= data_in[15:8];
            $display("\n\n");
            $display("memory unit write  address %d data_in %d Time : %d ",address,data_in , $time);
            $display("\n\n");
        end
        if (re) begin
            // Read operation
            //data_out = memory[address];
            data_out = {memory[address+1],memory[address]};
        end
    end

endmodule





module register_file (
    input wire clk,                     // Clock input
    input wire [2:0] read_reg1,         // Address of the first register to read
    input wire [2:0] read_reg2,         // Address of the second register to read
    input wire [2:0] write_reg,         // Address of the register to write
    input wire [15:0] write_data,       // Data to write to the register
    input wire reg_write,               // Write enable signal
    output reg [15:0] read_data1,       // Data read from the first register
    output reg [15:0] read_data2        // Data read from the second register
);
    // Register array, 7 registers of 16 bits each
    reg signed [15:0] registers [0:7];
    // Initialize r0 to 0
    initial begin
        registers[0] = 16'h0000;
        registers[1] = 16'h0001;
        registers[2] = 16'h0002;
        registers[3] = 16'h0003;
        registers[4] = 16'h0004;
        registers[5] = 16'h0005;
        registers[6] = 16'h0006;
        registers[7] = 16'h0007;
    end
    // Read operations
    always @(*) begin
        read_data1 = registers[read_reg1];    
        read_data2 = registers[read_reg2];
    end
    // Write operatin
    always @(posedge clk) begin
        if (reg_write && write_reg != 3'b000) begin
            registers[write_reg] <= write_data;
            $display("\n\n");
            $display("write_reg address %d write_data %d   Time : %d  ",write_reg,write_data , $time);
            $display("\n\n");
        end
        $display (
                "Time : %d \nR0 : %d, R1 : %d, R2 : %d, R3 : %d, R4 : %d, R5 : %d, R6 : %d, R7 : %d",$time,
                registers[0], registers[1], registers[2], registers[3],registers[4], registers[5], registers[6], registers[7]
            );
    end
endmodule







module stage_buffer (
    input wire clk,             // Clock input
    input wire en,    
    input wire [15:0] data_in,  // Data input
    output reg [15:0] data_out  // Data output
);
    // Buffer register
    reg [15:0] buffer;
    initial begin
        buffer = 16'hFFFe;
        //buffer = 16'hFFFF; 
    end
    // Write operation
    always @(posedge clk ) begin
        if (en) begin
            buffer <= data_in;
        end
    end
    // Continuous assignment to output
    assign data_out = buffer;
endmodule






module alu_16bit (
    input wire  [15:0] a,          // First 16-bit input
    input wire  [15:0] b,          // Second 16-bit input
    input wire  [1:0] alu_op,      // ALU operation selector
    output reg  [15:0] result,     // 16-bit result output
    output reg overflow,          // Overflow flag
    output reg negative,          // Negative flag
    output reg zero               // Zero flag
);
    // ALU operations
    localparam ADD = 2'b01;
    localparam SUB = 2'b10;
    localparam AND = 2'b00;
    wire [15:0] sum, diff;
    wire sum_overflow, diff_overflow;
    // Instantiate the 16-bit adder for addition and subtraction
    adder_16bit adder (
        .a(a),
        .b(b),
        .sum(sum),
        .overflow(sum_overflow)
    );
    assign diff = a - b;
    assign diff_overflow = (a[15] & ~b[15] & ~diff[15]) | (~a[15] & b[15] & diff[15]);
    always @(*) begin
        case (alu_op)
            ADD: begin
                result = sum;
                overflow = sum_overflow;
            end
            SUB: begin
                result = diff;
                overflow = diff_overflow;
            end
            AND: begin
                result = a & b;
                overflow = 0;
            end
            default: begin
                result = 16'h0000;
                overflow = 0;
            end
        endcase
        negative = result[15];
        zero = (result == 16'h0000);
    end
endmodule




module adder_16bit (
    input wire  [15:0] a,      // First 16-bit input
    input wire  [15:0] b,      // Second 16-bit input
    output wire  [15:0] sum,   // 16-bit sum output
    output wire overflow      // Overflow flag
);
    assign {overflow, sum} = a + b;
endmodule