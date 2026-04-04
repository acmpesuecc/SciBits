module fp_sqrt(
input [31:0] in,
output [31:0] out
);
wire sign = in[31];
wire [7:0] exp = in[30:23];
wire [22:0] mant = in[22:0];
reg [7:0] exp_r;
reg [22:0] mant_r;
always @(*) begin
    if (exp[0] == 1) begin
        mant_r = mant >> 1;
        exp_r = (exp >> 1) + 8'd64;
    end else begin
        mant_r = mant;
exp_r = (exp >> 1) + 8'd63;
end
end
assign out = {1'b0, exp_r, mant_r};
endmodule
