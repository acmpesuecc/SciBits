// multiplier child module
module fp_multiplier(
input [31:0] a,
input [31:0] b,
output [31:0] result
);
wire sign=a[31]^b[31];
wire [7:0] exp_a=a[30:23];
wire [7:0] exp_b=b[30:23];
wire [23:0] mant_a=(exp_a==0)?{1'b0,a[22:0]}:{1'b1,a[22:0]};
wire [23:0] mant_b=(exp_b==0)?{1'b0,b[22:0]}:{1'b1,b[22:0]};
wire [47:0] mant_mul=mant_a*mant_b;
reg [7:0] exp_r;
reg [22:0] mant_r;
always @(*) begin
if(mant_mul[47]) begin
mant_r=mant_mul[46:24];
exp_r=exp_a+exp_b-8'd127+1;
end else begin
mant_r=mant_mul[45:23];
exp_r=exp_a+exp_b-8'd127;
end
end
assign result={sign,exp_r,mant_r};
endmodule
