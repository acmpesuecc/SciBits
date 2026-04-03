// Subtractor child module
module fp_subtractor(
input [31:0] a,
input [31:0] b,
output [31:0] result
);
wire [31:0] b_neg={~b[31],b[30:0]};
fp_adder A1(.a(a),.b(b_neg),.result(result));
endmodule
