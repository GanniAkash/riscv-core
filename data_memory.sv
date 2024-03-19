module data_memory
  #(
    parameter N = 32,
    parameter A = 32,
    parameter SIZE = 4096*4 //4kB
    )
   (
    input logic          clk, we, rst,
    input logic [A-1:0]  addr,
    input logic [N-1:0]  data,
    output logic [N-1:0] rdata
    );

   reg [7:0]           memory [0:SIZE-1];

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
      end
      if (we) begin
         memory[addr] <= data[7:0];
         memory[addr+1] <= data[15:8];
         memory[addr+2] <= data[23:16];
         memory[addr+3] <= data[31:24];
      end
   end

   assign rdata = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]};

endmodule // data_memory
