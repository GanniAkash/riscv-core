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

   reg [N-1:0]           registers [0:31];

   always_ff @(posedge clk or posedge rst) begin
      if(rst == 1'b1) begin
         for(int i = 1; i < 32; i++) begin
            registers[i] <= 0;
         end
      end
      if(we3 == 1'b1)
        registers[2**addr3] <= wd3;
   end

   // Hard wire x0 to 0
   assign registers[0] = 0;

   // Read outputs
   assign rd1 = registers[2**addr1];
   assign rd2 = registers[2**addr2];


endmodule; // register_file
