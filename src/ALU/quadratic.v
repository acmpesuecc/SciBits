module fp_quadratic(
input [31:0] a,
input [31:0] b,
input [31:0] c,
output [31:0] x1,
output [31:0] x2
);

wire [31:0] b2;
wire [31:0] ac;
wire [31:0] four_ac;
wire [31:0] disc;
wire [31:0] sqrt_disc;
wire [31:0] neg_b;
wire [31:0] two_a;

wire [31:0] four = 32'h40800000;
wire [31:0] two  = 32'h40000000;

fp_multiplier M1(.a(b),.b(b),.result(b2));
fp_multiplier M2(.a(a),.b(c),.result(ac));
fp_multiplier M3(.a(ac),.b(four),.result(four_ac));

fp_subtractor S1(.a(b2),.b(four_ac),.result(disc));

fp_sqrt SQ1(.in(disc),.out(sqrt_disc));

assign neg_b = {~b[31],b[30:0]};

fp_multiplier M4(.a(a),.b(two),.result(two_a));

wire [31:0] num1;
wire [31:0] num2;

fp_adder A1(.a(neg_b),.b(sqrt_disc),.result(num1));
fp_subtractor S2(.a(neg_b),.b(sqrt_disc),.result(num2));

fp_divider D1(.a(num1),.b(two_a),.result(x1));
fp_divider D2(.a(num2),.b(two_a),.result(x2));

endmodule
