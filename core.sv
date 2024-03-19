`include "instruction_memory.sv"
`include "data_memory.sv"
`include "alu.sv"
`include "register_file.sv"

module core
  (
   input clk, rst
   );

   localparam N = 32;
   localparam A = 5;

   // PC Signals
   logic [N-1:0] pc, pc_next, pc_plus_4, pc_target;
   logic [N-1:0] instr;

   // Register File Signals
   logic [A-1:0] ra1, ra2, wa3;
   logic [N-1:0] rd1, rd2, wd3;

   //Misc
   logic [N-1:0] result, immExt;

   // ALU Signals
   logic [N-1:0] srcA, srcB, aluResult;
   logic [3:0]   _flags;

   // Data Memory Signals
   logic [N-1:0] readData, writeData;

   // Control Signals
   logic         regWrite, pcSrc, memWrite, aluSrc, zero, branch_, jump;
   logic [3:0]   aluControl;
   logic [2:0]   immSrc;
   logic [2:0]   resultSrc;
   logic [1:0]   aluOp;

   logic [6:0]   op;
   logic [2:0]   funct3;
   logic         funct7;




   instruction_memory inst_mem(
                               .addr(pc),
                               .data(instr)
                               );

   register_file regs(
                      .clk(clk),
                      .rst(rst),
                      .we3(regWrite),
                      .addr1(ra1),
                      .addr2(ra2),
                      .rd1(rd1),
                      .rd2(rd2),
                      .addr3(wa3),
                      .wd3(wd3)
                      );

   alu alu(
           .src1(srcA),
           .src2(srcB),
           .op(aluControl),
           .res(aluResult),
           .flags(_flags)
           );

   data_memory dat_mem(
                       .clk(clk),
                       .rst(rst),
                       .we(memWrite),
                       .addr(aluResult),
                       .data(writeData),
                       .rdata(readData)
                       );


   // PC

   always_ff @(posedge clk or posedge rst) begin // PC Process
      if(rst == 1'b1) pc <= 0;
      if(clk == 1'b1) begin
         pc <= pc_next;
      end
   end

   assign pc_plus_4 = pc + 4;
   assign pc_next = (pcSrc == 1'b1) ? pc_target : pc_plus_4;
   assign pc_target = (op[4:2] == 3'b001) ? {aluResult[N-1:1], 1'b0} : pc + immExt;


   // Register-File

   assign ra1 = instr[19:15];
   assign ra2 = instr[24:20];
   assign wa3 = instr[11:7];

   assign wd3 = result;


   // ALU
   assign srcA = rd1;
   assign srcB = (aluSrc == 1'b1) ? immExt : rd2;


   // Data Memory
   assign writeData = rd2;

   // Immediate
   always_comb begin
      case(immSrc)
        'b00: immExt = {{20{instr[31]}}, instr[31:20]};
        'b01: immExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        'b10: immExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        'b11: immExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        'b100: immExt = {instr[31:12], 12'b0};
        default: immExt = {{20{instr[31]}}, instr[31:20]};
      endcase; // case (immSrc)
   end;

   //Result
   always_comb begin
      case(resultSrc)
        'b00 : result = aluResult;
        'b01 : result = readData;
        'b10 : result = pc_plus_4;
        'b11 : result = immExt;
        'b100: result = pc_target;
        default : result = aluResult;
      endcase; // case (resultSrc)
   end;


   // Control
   assign op = instr[6:0];
   assign funct3 = instr[14:12];
   assign funct7 = instr[30];

   assign zero = _flags[0];

   always_comb begin
      case (op)
        7'b0000011: begin   //lw
           regWrite = 1'b1;
           immSrc = 3'b000;
           aluSrc = 1'b1;
           memWrite = 1'b0;
           resultSrc = 3'b001;
           branch_ = 1'b0;
           aluOp = 2'b00;
           jump = 1'b0;
        end
        7'b0100011: begin    //sw
           regWrite = 1'b0;
           immSrc = 3'b001;
           aluSrc = 1'b1;
           memWrite = 1'b1;
           resultSrc = 3'bxxx;
           branch_ = 1'b0;
           aluOp = 2'b00;
           jump = 1'b0;
        end
        7'b0110011: begin   //r-type
           regWrite = 1'b1;
           immSrc = 3'bxxx;
           aluSrc = 1'b0;
           memWrite = 1'b0;
           resultSrc = 3'b000;
           branch_ = 1'b0;
           aluOp = 2'b10;
           jump = 1'b0;
        end
        7'b1100011: begin  //branches
           regWrite = 1'b0;
           immSrc = 3'b010;
           aluSrc = 1'b0;
           memWrite = 1'b0;
           resultSrc = 3'bxxx;
           branch_ = 1'b1;
           // aluOp = 2'b01;
           if(funct3 == 3'b000 || funct3 == 3'b001) aluOp = 2'b01;
           else aluOp = 2'b11;
           jump = 1'b0;
        end
        7'b0010011: begin //i-type (alu)
           regWrite = 1'b1;
           immSrc = 3'b000;
           aluSrc = 1'b1;
           memWrite = 1'b0;
           resultSrc = 3'b000;
           branch_ = 1'b0;
           aluOp = 2'b10;
           jump = 1'b0;
        end
        7'b1101111: begin // jal
           regWrite = 1'b1;
           immSrc = 3'b011;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 3'b010;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b1;
        end
        7'b1100111: begin //jalr
           regWrite = 1'b1;
           immSrc = 3'b000;
           aluSrc = 1'b1;
           memWrite = 1'b0;
           resultSrc = 3'b010;
           branch_ = 1'b0;
           aluOp = 2'b00;
           jump = 1'b1;
        end
        7'b0110111: begin //lui
           regWrite = 1'b1;
           immSrc = 3'b100;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 3'b011;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b0;
        end
        7'b0010111: begin //auipc
           regWrite = 1'b1;
           immSrc = 3'b100;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 3'b100;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b0;
        end
        default: begin
           regWrite = 1'b0;
           immSrc = 3'bxxx;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 3'bxxx;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b0;
        end
      endcase; // case (op)
   end; // always_comb

   // assign pcSrc = (zero && branch_) || jump;
   always_comb begin
      case(funct3)
        3'b000: pcSrc = (zero && branch_) || jump;
        3'b001: pcSrc = (~zero && branch_) || jump;
        3'b100: pcSrc = (~zero && branch_) || jump;
        3'b101: pcSrc = (zero && branch_) || jump;
        3'b110: pcSrc = (~zero && branch_) || jump;
        3'b111: pcSrc = (zero && branch_) || jump;
        default: pcSrc =  branch_ || jump;
      endcase; // case (funct3)
   end

   // ALU Decoder

   always_comb begin
      case (aluOp)
        2'b00: aluControl = 4'b0000;
        2'b01: aluControl = 4'b0001;
        2'b10: begin
           case (funct3)
             3'b000: begin
                if({op[5], funct7} == 2'b11) aluControl = 4'b0001;
                else aluControl = 4'b0000;
             end
             3'b001: aluControl = 4'b1000;
             3'b010: aluControl = 4'b0101;
             3'b011: aluControl = 4'b1001;
             3'b100: aluControl = 4'b0100;
             3'b101: begin
                if(funct7 == 1'b1) aluControl = 4'b0110;
                else aluControl = 4'b0111;
             end
             3'b110: aluControl = 4'b0011;
             3'b111: aluControl = 4'b0010;
             default: aluControl = 4'b0000;
           endcase; // case (funct3)
        end // case: 2'b10
        2'b11: begin
           case(funct3)
             3'b100: aluControl = 4'b0101;
             3'b101: aluControl = 4'b0101;
             3'b110: aluControl = 4'b1001;
             3'b111: aluControl = 4'b1001;
             default: aluControl = 4'b0001;
           endcase // case (funct3)
        end
        default: aluControl = 4'b0000;
      endcase; // case (aluOp)
   end; // always_comb


endmodule // core
