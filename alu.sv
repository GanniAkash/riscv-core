module alu
  #(
    parameter N = 32
    )
   (
    input logic [N-1:0]  src1, src2,
    input logic [3:0]    op,
    output logic [N-1:0] res,
    output logic [3:0]   flags
    );

   logic                 carry_out;
   logic [N:0]           temp;

   assign temp = src1 - src2;
   logic signed [31:0]   temp1, temp2;

   always_comb begin : alu_results
      case (op)
        'b0000 : {carry_out, res} = src1 + src2;
        'b0001 : {carry_out, res} = temp;
        'b0010 : {carry_out, res} = {1'b0, src1} & {1'b0, src2};
        'b0011 : {carry_out, res} = {1'b0, src1} | {1'b0, src2};
        'b0101 : begin
           temp1 = src1;
           temp2 = src2;
           if(temp1 < temp2) {carry_out, res} = 1;
           else {carry_out, res} = 0;
        end
        'b1001 : begin
           if(src1 < src2) {carry_out, res} = 1;
           else {carry_out, res} = 0;
        end
        'b0100 : {carry_out, res} = {1'b0, src1} ^ {1'b0, src2};
        'b0110 : {carry_out, res} = {1'b0, src1 >>> src2[4:0]};
        'b0111 : {carry_out, res} = {1'b0, src1 >> src2[4:0]};
        'b1000 : {carry_out, res} = {1'b0, src1 << src2[4:0]};
        default : {carry_out, res} = src1 + src2;
      endcase; // case (op)
   end

   assign flags[0] = & (~res);
   assign flags[1] = res[N-1];
   assign flags[2] = carry_out && (~op[1]);
   assign flags[3] = (~op[1]) && (temp[N-1] ^ src1[N-1]) && (~(~(op[0] ^ src1[N-1]) ^ src2[N-1]));

endmodule // alu
