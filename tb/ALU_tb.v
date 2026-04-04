`timescale 1ns/1ps

module tb_SCIBits_ALU;

reg [31:0] a, b, c;
reg [2:0] op;

wire [31:0] result;
wire [6:0] seg;

// Instantiate DUT
SCIBits_ALU uut (
    .a(a),
    .b(b),
    .c(c),
    .op(op),
    .result(result),
    .seg(seg)
);

// ================= MONITOR =================
initial begin
    $monitor("TIME=%0t | OP=%b | A=%h | B=%h | C=%h | RESULT=%h | SEG=%b",
              $time, op, a, b, c, result, seg);
end

// ================= STIMULUS =================
initial begin

    // Initialize (VERY IMPORTANT → prevents X/Z)
    a = 32'h00000000;
    b = 32'h00000000;
    c = 32'h00000000;
    op = 3'b000;

    #10;

    $display("=========== START ===========");

    // ---------- ADD ----------
    // 5 + 3 = 8
    a = 32'h40A00000;
    b = 32'h40400000;
    op = 3'b000;
    #20;

    // ---------- SUB ----------
    // 10 - 4 = 6
    a = 32'h41200000;
    b = 32'h40800000;
    op = 3'b001;
    #20;

    // ---------- MUL ----------
    // 2 * 6 = 12
    a = 32'h40000000;
    b = 32'h40C00000;
    op = 3'b010;
    #20;

    // ---------- DIV ----------
    // 8 / 2 = 4
    a = 32'h41000000;
    b = 32'h40000000;
    op = 3'b011;
    #20;

    // ---------- SQRT ----------
    // sqrt(16) = 4
    a = 32'h41800000;
    op = 3'b100;
    #20;

    // ---------- QUADRATIC ----------
    // x² - 5x + 6 = 0 → roots: 2 and 3

    a = 32'h3F800000; // 1
    b = 32'hC0A00000; // -5
    c = 32'h40C00000; // 6

    // root 1
    op = 3'b101;
    #30;

    // root 2
    op = 3'b110;
    #30;

    $display("=========== END ===========");

    $finish;

end

endmodule
