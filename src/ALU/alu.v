module SCIBits_ALU(
input [31:0] a,
input [31:0] b,
input [31:0] c,
input [2:0] op,
output [31:0] result,
output [6:0] seg
);

// BASIC OPS
wire [31:0] sum,diff,prod,quot;

fp_adder A1(.a(a),.b(b),.result(sum));
fp_subtractor S1(.a(a),.b(b),.result(diff));
fp_multiplier M1(.a(a),.b(b),.result(prod));
fp_divider D1(.a(a),.b(b),.result(quot));

// ADVANCED
wire [31:0] sqrt_out;
wire [31:0] x1,x2;

fp_sqrt SQ1(.in(a),.out(sqrt_out));
fp_quadratic Q1(.a(a),.b(b),.c(c),.x1(x1),.x2(x2));

// SELECT
reg [31:0] res;

always @(*) begin
case(op)
3'b000: res=sum;
3'b001: res=diff;
3'b010: res=prod;
3'b011: res=quot;
3'b100: res=sqrt_out;
3'b101: res=x1;
3'b110: res=x2;
default: res=32'b0;
endcase
end

assign result=res;

// DISPLAY
wire [3:0] digit;

float_to_int F1(.in(res),.out(digit));
seven_seg S2(.digit(digit),.seg(seg));

endmodule
