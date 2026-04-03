// Adder child-Module
module fp_adder(
input [31:0] a,
input [31:0] b,
output [31:0] result
);
wire sign_a=a[31];
wire sign_b=b[31];
wire [7:0] exp_a=a[30:23];
wire [7:0] exp_b=b[30:23];
wire [23:0] mant_a=(exp_a==0)?{1'b0,a[22:0]}:{1'b1,a[22:0]};
wire [23:0] mant_b=(exp_b==0)?{1'b0,b[22:0]}:{1'b1,b[22:0]};
reg [23:0] ma,mb;
reg [7:0] exp_c;
always @(*) begin
if(exp_a>exp_b) begin
ma=mant_a;
mb=mant_b>>(exp_a-exp_b);
exp_c=exp_a;
end else begin
ma=mant_a>>(exp_b-exp_a);
mb=mant_b;
exp_c=exp_b;
end
end
reg [24:0] sum;
reg sign_r;
always @(*) begin
if(sign_a==sign_b) begin
sum=ma+mb;
sign_r=sign_a;
end else begin
if(ma>=mb) begin
sum=ma-mb;
sign_r=sign_a;
end else begin
sum=mb-ma;
sign_r=sign_b;
end
end
end
reg [7:0] exp_r;
reg [23:0] mant_r;
integer i;
always @(*) begin
if(sum[24]) begin
mant_r=sum>>1;
exp_r=exp_c+1;
end else begin
mant_r=sum;
exp_r=exp_c;
for(i=0;i<24;i=i+1) begin
if(mant_r[23]==0 && exp_r>0) begin
mant_r=mant_r<<1;
exp_r=exp_r-1;
end
end
end
end
assign result={sign_r,exp_r,mant_r[22:0]};
endmodule
