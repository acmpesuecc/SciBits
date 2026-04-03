// ALU-Floating point standard

module SCIBits_ALU(
input [31:0] a,
input [31:0] b,
input [1:0] op,
output reg [31:0] result
);
wire [31:0] sum;
wire [31:0] diff;
wire [31:0] prod;
wire [31:0] quot;
fp_adder A1(.a(a),.b(b),.result(sum));
fp_subtractor S1(.a(a),.b(b),.result(diff));
fp_multiplier M1(.a(a),.b(b),.result(prod));
fp_divider D1(.a(a),.b(b),.result(quot));
always @(*) begin
case(op)
2'b00:result=sum;
2'b01:result=diff;
2'b10:result=prod;
2'b11:result=quot;
default:result=32'b0;
endcase
end
endmodule
