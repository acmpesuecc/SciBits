// divider child module
module fp_divider(
input [31:0] a,
input [31:0] b,
output [31:0] result
);
wire sign=a[31]^b[31];
wire [7:0] exp_a=a[30:23];
wire [7:0] exp_b=b[30:23];
wire [23:0] mant_a=(exp_a==0)?{1'b0,a[22:0]}:{1'b1,a[22:0]};
wire [23:0] mant_b=(exp_b==0)?{1'b0,b[22:0]}:{1'b1,b[22:0]};
wire [47:0] dividend={mant_a,23'b0};
wire [23:0] mant_div=dividend/mant_b;
reg [7:0] exp_r;
reg [22:0] mant_r;
always @(*) begin
mant_r=mant_div[22:0];
exp_r=exp_a-exp_b+8'd127;
end
assign result={sign,exp_r,mant_r};
endmodule
