
module core
  (
   input clk_, rst,
   output logic [31:0] io_o,
   output [31:0] test,
   output blink
   );

   localparam N = 32;
   localparam A = 5;



    logic [24:0] counter = 25'b0;
    logic clk = 1'b0;


     always @(posedge clk_ or posedge rst) begin
        if(rst) counter <= 0;
        else begin
         if (counter == 2) begin // 26MHz / 32*2 = 406.25kHz
             counter <= 0;
             clk <= ~clk; // Toggle the output clock
         end
         else begin
             counter <= counter + 1;
         end
        end
     end

//   assign clk = clk_;

   assign blink = clk;

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
   logic         regWrite, pcSrc, memWrite, aluSrc, zero, branch_, jump, io_s;
   logic [3:0]   aluControl;
   logic [2:0]   immSrc;
   logic [3:0]   resultSrc;
   logic [1:0]   aluOp;
   logic [1:0]   writeSrc;

   logic [6:0]   op;
   logic [2:0]   funct3;
   logic         funct7;

    logic [31:0] io;



   instruction_memory inst_mem(
                               .addr(pc[9:0]),
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

    assign test = regs.x14;

   alu alu(
           .src1(srcA),
           .src2(srcB),
           .op(aluControl),
           .res(aluResult),
           .flags(_flags)
           );

   data_memory data_mem(
                       .clk(clk),
                       .rst(rst),
                       .we(memWrite),
                       .addr(aluResult[9:0]),
                       .data(writeData),
                       .rdata(readData)
                       );

    //IO
    always_ff @(posedge clk or posedge rst) begin
        if(rst) {io_o} <= 32'b0;
        else io_o <= io;
    end

    always_comb begin
        if(io_s == 1'b1) io = writeData;
        else io = io_o;
    end

   // PC

   always_ff @(posedge rst or posedge clk) begin // PC Process
      if(rst) pc <= 0;
      else begin
         pc <= pc_next;
      end
   end

//   assign pc_plus_4 = pc + 4;
//   assign pc_next = (pcSrc == 1'b1) ? pc_target : pc_plus_4;
//   assign pc_target = (op[4:2] == 3'b001) ? {aluResult[N-1:1], 1'b0} : pc + immExt;

always @* begin
        pc_plus_4 = pc + 4;
        pc_target = (op[4:2] == 3'b001) ? {aluResult[N-1:1], 1'b0} : pc + immExt;
        pc_next = (pcSrc == 1'b1) ? pc_target : pc_plus_4;
   end


   // Register-File

   assign ra1 = instr[19:15];
   assign ra2 = instr[24:20];
   assign wa3 = instr[11:7];

   assign wd3 = result;


   // ALU
   assign srcA = rd1;
   assign srcB = (aluSrc == 1'b1) ? immExt : rd2;


   // Data Memory
   // assign writeData = rd2;
   always_comb begin
      case(writeSrc)
        2'b00: writeData = rd2;
        2'b01: writeData = {16'b0, rd2[15:0]};
        2'b10: writeData = {24'b0, rd2[7:0]};
        default: writeData = rd2;
      endcase; // case (writeSrc)
   end

   // Immediate
   always_comb begin
      case(immSrc)
        'b000: immExt = {{20{instr[31]}}, instr[31:20]};
        'b001: immExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        'b010: immExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        'b011: immExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        'b100: immExt = {instr[31:12], 12'b0};
        default: immExt = {{20{instr[31]}}, instr[31:20]};
      endcase; // case (immSrc)
   end;

   //Result
   always_comb begin
      case(resultSrc)
        4'b000 : result = aluResult;
        4'b001 : result = readData;
        4'b010 : result = pc_plus_4;
        4'b011 : result = immExt;
        4'b100 : result = pc_target;
        4'b101 : result = {{16{readData[15]}}, readData[15:0]};
        4'b110 : result = {{24{readData[7]}}, readData[7:0]};
        4'b111 : result = {16'b0, readData[15:0]};
        4'b1000: result = {24'b0, readData[7:0]};
        4'b1001: result = io_o;
        default : result = aluResult;
      endcase; // case (resultSrc)
   end;


   // Control
   assign op = instr[6:0];
   assign funct3 = instr[14:12];
   assign funct7 = instr[30];

   assign zero = _flags[0];

   always_comb begin
        io_s = 1'b0;
      case (op)

        7'b0000011: begin   //loads
           regWrite = 1'b1;
           immSrc = 3'b000;
           aluSrc = 1'b1;
           memWrite = 1'b0;
           // resultSrc = 4'b001;
           case(funct3)
             3'b000: resultSrc = 4'b0110;
             3'b001: resultSrc = 4'b0101;
             3'b010: resultSrc = 4'b0001;
             3'b101: resultSrc = 4'b0111;
             3'b100: resultSrc = 4'b1000;
             default: resultSrc = 4'b0001;
           endcase; // case (funct3)

            if(aluResult[31] == 1'b0) begin
              resultSrc = 4'b1001;
           end
           branch_ = 1'b0;
           aluOp = 2'b00;
           jump = 1'b0;
           writeSrc = 2'b00;
        end
        7'b0100011: begin    //store
           regWrite = 1'b0;
           immSrc = 3'b001;
           aluSrc = 1'b1;

            if(aluResult[31] == 0) begin
              io_s = 1'b1;
              memWrite = 1'b0;
           end
           else begin
              memWrite = 1'b1;
              io_s = 1'b0;

           end
           resultSrc = 4'bxxx;
           branch_ = 1'b0;
           aluOp = 2'b00;
           jump = 1'b0;
           case (funct3)
             3'b000: writeSrc = 2'b10;
             3'b001: writeSrc = 2'b01;
             3'b010: writeSrc = 2'b00;
             default: writeSrc = 2'b00;
           endcase // case (funct)
        end
        7'b0110011: begin   //r-type
           regWrite = 1'b1;
           immSrc = 3'bxxx;
           aluSrc = 1'b0;
           memWrite = 1'b0;
           resultSrc = 4'b000;
           branch_ = 1'b0;
           aluOp = 2'b10;
           jump = 1'b0;
           writeSrc = 2'b00;
        end
        7'b1100011: begin  //branches
           regWrite = 1'b0;
           immSrc = 3'b010;
           aluSrc = 1'b0;
           memWrite = 1'b0;
           resultSrc = 4'bxxx;
           branch_ = 1'b1;
           // aluOp = 2'b01;
           if(funct3 == 3'b000 || funct3 == 3'b001) aluOp = 2'b01;
           else aluOp = 2'b11;
           jump = 1'b0;
           writeSrc = 2'b00;
        end
        7'b0010011: begin //i-type (alu)
           regWrite = 1'b1;
           immSrc = 3'b000;
           aluSrc = 1'b1;
           memWrite = 1'b0;
           resultSrc = 4'b000;
           branch_ = 1'b0;
           aluOp = 2'b10;
           jump = 1'b0;
           writeSrc = 2'b00;
        end
        7'b1101111: begin // jal
           regWrite = 1'b1;
           immSrc = 3'b011;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 4'b010;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b1;
           writeSrc = 2'b00;
        end
        7'b1100111: begin //jalr
           regWrite = 1'b1;
           immSrc = 3'b000;
           aluSrc = 1'b1;
           memWrite = 1'b0;
           resultSrc = 4'b010;
           branch_ = 1'b0;
           aluOp = 2'b00;
           jump = 1'b1;
           writeSrc = 2'b00;
        end
        7'b0110111: begin //lui
           regWrite = 1'b1;
           immSrc = 3'b100;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 4'b011;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b0;
           writeSrc = 2'b00;
        end
        7'b0010111: begin //auipc
           regWrite = 1'b1;
           immSrc = 3'b100;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 4'b100;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b0;
           writeSrc = 2'b00;
        end
        default: begin
           regWrite = 1'b0;
           immSrc = 3'bxxx;
           aluSrc = 1'bx;
           memWrite = 1'b0;
           resultSrc = 4'bxxx;
           branch_ = 1'b0;
           aluOp = 2'bxx;
           jump = 1'b0;
           writeSrc = 2'b00;
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
