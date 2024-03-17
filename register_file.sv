module register_file
  # (
     parameter N = 32,
     parameter A = $clog2(N)
     )
   (
    input logic          clk, we3, rst,
    input logic [A-1:0]  addr1, addr2, addr3,
    output logic [N-1:0] rd1, rd2,
    input logic [N-1:0]  wd3
    );

   logic [N-1:0]           regs [0:31];

    wire [31: 0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20
                ,x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31;

    assign x0 = regs[0/4];
    assign x1 = regs[4/4];
    assign x2 = regs[8/4];
    assign x3 = regs[12/4];
    assign x4 = regs[16/4];
    assign x5 = regs[20/4];
    assign x6 = regs[24/4];
    assign x7 = regs[28/4];
    assign x8 = regs[32/4];
    assign x9 = regs[36/4];
    assign x10 = regs[40/4];
    assign x11 = regs[44/4];
    assign x12 = regs[48/4];
    assign x13 = regs[52/4];
    assign x14 = regs[56/4];
    assign x15 = regs[60/4];
    assign x16 = regs[64/4];
    assign x17 = regs[68/4];
    assign x18 = regs[72/4];
    assign x19 = regs[76/4];
    assign x20 = regs[80/4];
    assign x21 = regs[84/4];
    assign x22 = regs[88/4];
    assign x23 = regs[92/4];
    assign x24 = regs[96/4];
    assign x25 = regs[100/4];
    assign x26 = regs[104/4];
    assign x27 = regs[108/4];
    assign x28 = regs[112/4];
    assign x29 = regs[116/4];
    assign x30 = regs[120/4];
    assign x31 = regs[124/4];


   always_ff @(posedge clk, posedge rst) begin
      if(rst) begin
         for(int i = 1; i < 32; i = i + 1) begin
            regs[i] <= 32'b0;
         end
      end
      else if(we3 && clk== 1'b1) begin
         regs[addr3] <= wd3;
         regs[0] <= 0;
      end
   end

   // Read outputs
   assign rd1 = regs[addr1];
   assign rd2 = regs[addr2];

endmodule // register_file
