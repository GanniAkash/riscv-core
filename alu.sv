module alu
  #(
    parameter N = 32
    )
   (
    input logic [N-1:0]  src1, src2,
    input logic [2:0]    op,
    output logic [N-1:0] res,
    output logic [3:0]   flags
    );

   logic                 carry_out;
   logic [N:0]           temp;

   assign temp = src1 - src2;

   always_comb begin : alu_results
      case (op)
        'b000 : {carry_out, res} = src1 + src2;
        'b001 : {carry_out, res} = temp;
        'b010 : {carry_out, res} = {1'b0, src1} & {1'b0, src2};
        'b011 : {carry_out, res} = {1'b0, src1} | {1'b0, src2};
        'b101 : {carry_out, res[N-1:1], res[0]} = {1'b0, 31'b0, temp[N-1] ^ ((~op[1]) && (temp[N-1] ^ src1[N-1]) && (~(~(op[0] ^ src1[N-1]) ^ src2[N-1])))};
        default : {carry_out, res} = src1 + src2;
      endcase; // case (op)
   end

   assign flags[0] = & (~res);
   assign flags[1] = res[N-1];
   assign flags[2] = carry_out && (~op[1]);
   assign flags[3] = (~op[1]) && (temp[N-1] ^ src1[N-1]) && (~(~(op[0] ^ src1[N-1]) ^ src2[N-1]));

endmodule; // alu
