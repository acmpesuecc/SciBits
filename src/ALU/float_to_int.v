module float_to_int(
input [31:0] in,
output reg [3:0] out
);

wire [7:0] exp = in[30:23];

always @(*) begin
case(exp)
8'd127: out=1;
8'd128: out=2;
8'd129: out=4;
8'd130: out=8;
default: out=0;
endcase
end

endmodule
