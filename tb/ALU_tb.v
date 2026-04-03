// Testbench For fp_ALU

`timescale 1ns/1ps

module SCIBits_ALU_tb;

    reg [31:0] a;
    reg [31:0] b;
    reg [1:0] op;
    wire [31:0] result;

    SCIBits_ALU uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    initial begin
        $display("Time\t OP\t A\t\t B\t\t RESULT");
        $monitor("%0t\t %b\t %h\t %h\t %h", $time, op, a, b, result);

        a = 32'h3F800000; b = 32'h40000000; op = 2'b00; #10;
        a = 32'h40400000; b = 32'h3F800000; op = 2'b01; #10;
        a = 32'h40000000; b = 32'h40000000; op = 2'b10; #10;
        a = 32'h40800000; b = 32'h40000000; op = 2'b11; #10;
        a = 32'h3F000000; b = 32'h3F000000; op = 2'b00; #10;
        a = 32'h3F800000; b = 32'h00000000; op = 2'b11; #10;

        $finish;
    end

endmodule
