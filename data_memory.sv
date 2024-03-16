module data_memory
  #(
    parameter N = 32,
    parameter A = 32,
    parameter SIZE = 2**32 //4GB
    )
   (
    input logic          clk, we, rst,
    input logic [A-1:0]  raddr, waddr,
    input logic [N-1:0]  data,
    output logic [N-1:0] rdata
    );

   reg [N-1:0]           memory [SIZE-1:0];

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         for (int i = 0; i < SIZE; i++) begin
            memory[i] <= 0;
         end
      end
      if (we) begin
         memory[waddr] <= data;
      end
   end

   assign rdata = memory[raddr];

endmodule; // data_memory
