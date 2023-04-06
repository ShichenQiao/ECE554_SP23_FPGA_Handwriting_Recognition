module int_mul_16by16(A, B, sign, OUT);

    input [15:0] A;            // 16 bit integer input
    input [15:0] B;            // 16 bit integer input
    input sign;                // signed multiply when set, unsigned multiply when unsigned
    output [31:0] OUT;         // the product of A*B

    logic signed [16:0] A_eff, B_eff;
    logic signed [33:0] product;

    assign A_eff = {sign ? A[15] : 1'b0, A};
    assign B_eff = {sign ? B[15] : 1'b0, B};

    assign product = A_eff * B_eff;

    assign OUT = product[31:0];

endmodule