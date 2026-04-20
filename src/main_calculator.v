`timescale 1ns / 1ps

module main_calculator(
    input clk,
    input rst,
    input calculate, // make sure in the main CPU design u trigger the the calculate signal off once the calculation is calculated
    input [287:0] operands,
    input [26:0] isSign,
    input [8:0] isEmpty,
    output reg [31:0] final_output,
    output reg errorSignal
);   

/*
isSign Values

BODMAS RULE: (if sign then mem will be 32'b0)
D (division) = 3'b100;
M (multiplication) = 3'b101;
A (addition) = 3'b110;
S (subtraction) = 3'b111;

Number in Memory = 3'b0XX;
*/

    reg [31:0] a;
    reg [31:0] b;
    reg [1:0]  op;
    wire [31:0] result;
    reg [31:0] block_result;
     
    SCIBits_ALU ALU(.a(a),.b(b),.op(op),.result(result));
    
    reg [31:0] semi_a;
    reg [31:0] semi_b;
    reg [1:0] semi_op;
    
    reg [31:0] memCalc [0:8];
    
    reg [2:0] memIsSign [0:8];
    reg [8:0] memIsEmpty;
    
    integer i; // used for SIGNFIND
    integer j; // used for the SETA and SETB
    integer k; // used for VERIF1 (DONT OVER USE IT cause it might cause issues in timings or synth)
    integer loop; // number of loop for the WAITCYCLE state
    integer m; // will be running a for loop in VERIF2
    integer n; // will be counting how many non empty meowmory is present in VERIF2
    integer s; // to save the address of the answer in for loop by variable integer m in VARIF2
    
    reg [1:0] signNumber; // for SIGNSELECT state to control the sign being searched at SIGNFIND state
    reg canChangeSign; // a signal controlled by both SIGNFIND and SIGNSELECT and initialized at VERIF1, activated when a sign is no more present in the memory (e.g. when all the addition signs(+) are calculated then this signal turn high)
    
    
    localparam INITMEM = 0; // writing all the input to the internal memory to process it faster 
    localparam VERIF1 = 1; // verifying from the internal memory that all the inputs are correct and saved as intended
    localparam SIGNSELECT = 2; // Selecting from div, mul, add and sub 
    localparam SIGNFIND = 3; // finding the selected sign from the memory
    localparam SETA = 4; // SET A (basically the A is nothing but SCIBits_ALU s input)
    localparam EXTRASETA = 5; // If it cannot find A then 
    localparam SETB = 6; // SET B (basically the B is nothing but SCIBits_ALU s input)
    localparam EXTRASETB = 7; // If it cannot find B then 
    localparam INITALU = 8; // Sending all the INPUTS A B and OP to ALU
    localparam WAITCYCLE = 9; // waiting for alu to give output result, now the wait cycle depends upon the operation so if its add then will take 2 to 3 wait cycles and if its like mul or div then more, depending upon the technode clock freq and design speed
    localparam FETCHRESULT = 10; // getting the result from the ALU
    localparam MEMREWRITE = 11; // Re writing the memory [j-1] (where j is the integer address number of the sign) and replacing it with the result and turning on EMPTY signals on j and j+1
    localparam VERIF2 = 12; // verifying the final output where there will be only ONE NON EMPTY ADDRESS AND A NON SIGN ADDRESS is left, otherwise error state
    localparam SENDOUTPUT = 13; // Sending the only NUMBER VALUE left in the memory
    localparam ERRORSTATE = 14; // IF any issue then this state will be accessed (with maybe a info that what was the last)
    
    reg [3:0] state;
    
    always @(posedge clk or negedge rst) begin
        
        if (!rst) begin
            final_output <= 32'd0;
            errorSignal <= 1'b0;
            state <= INITMEM;
        end
        else
        begin
            if (calculate) begin
                case(state)
                    INITMEM: begin
                        memCalc[0] <= operands[31:0];
                        memCalc[1] <= operands[63:32];
                        memCalc[2] <= operands[95:64];
                        memCalc[3] <= operands[127:96];
                        memCalc[4] <= operands[159:128];
                        memCalc[5] <= operands[191:160];
                        memCalc[6] <= operands[223:192];
                        memCalc[7] <= operands[255:224];
                        memCalc[8] <= operands[287:256];
                        
                        memIsSign[0] <=	isSign[2:0];
                        memIsSign[1] <=	isSign[5:3];
                        memIsSign[2] <=	isSign[8:6];
                        memIsSign[3] <=	isSign[11:9];
                        memIsSign[4] <=	isSign[14:12];
                        memIsSign[5] <=	isSign[17:15];
                        memIsSign[6] <=	isSign[20:18];
                        memIsSign[7] <=	isSign[23:21];
                        memIsSign[8] <= isSign[26:24];
                        
                        memIsEmpty <= isEmpty;
                        
                        a <= 32'b0;
                        b <= 32'b0;
                        op <= 2'b0;
                        
                        state <= VERIF1;
                    end
                    
                    VERIF1: begin
                        k <= 0;
                        if (memIsSign[0] != 3'd000) begin
                            k <= 1;
                        end
                        if (memIsSign[8] != 3'd000) begin
                            k <= 1;
                        end
                        for (i = 1; i < 9; i = i + 1) begin
                            if ((memIsSign[i-1] != 3'd000) && (memIsSign[i] != 3'd000)) begin
                                k <= 1;
                            end
                        end
                        if (k) begin
                            state <= ERRORSTATE;
                        end
                        else begin
                            state <= SIGNSELECT;
                            signNumber <= 2'b00;
                            canChangeSign <= 1'b0;
                        end
                    end                        
                    
                    SIGNSELECT: begin
                        if (canChangeSign && (signNumber != 2'b11)) begin
                            signNumber <= signNumber + 2'd01; // change this and add one unused 2 bit variable (cause synth issues can come here) 
                            canChangeSign <= 1'b0;
                            state <= SIGNFIND;
                            i <= 0;
                        end
                        else if (canChangeSign && (signNumber == 2'b11)) begin
                            canChangeSign <= 1'b0;
                            state <= VERIF2;
                        end
                        else if ((!canChangeSign)) begin 
                            state <= SIGNFIND;
                            i <= 0;
                        end
                    end
                    
                    SIGNFIND: begin 
                        
                        if (i == 0) begin
                            i <= 1;
                        end
                        
                        if (i == 1) begin
                            if (signNumber == memIsSign[i][1:0] && (!memIsEmpty[i])) begin
                                state <= SETA;
                                i <= 1;
                            end
                            else begin
                                i <= 3;
                            end
                        end
                        else if (i == 3) begin
                            if (signNumber == memIsSign[i][1:0] && (!memIsEmpty[i])) begin
                                state <= SETA;
                                i <= 3;
                            end
                            else begin
                                i <= 5;
                            end
                        end
                        else if (i == 5) begin
                            if (signNumber == memIsSign[i][1:0] && (!memIsEmpty[i])) begin
                                state <= SETA;
                                i <= 5;
                            end
                            else begin
                                i <= 7;
                            end
                        end
                        else if (i == 7) begin
                            if (signNumber == memIsSign[i][1:0] && (!memIsEmpty[i])) begin
                                state <= SETA;
                                i <= 7;
                            end
                            else begin
                                canChangeSign <= 1'b1;
                                state <= SIGNSELECT;
                            end
                        end
                    end
                    
                    SETA: begin // a is a number that is stored an address above the operator so if the operator sign is + and is stored at address 3 then a the operand will be stored at the address 2. 
                        if (!memIsEmpty[i-1]) begin
                            if (memIsSign[i-1] == 3'd000) begin
                                semi_a <= memCalc[i-1];
                                state <= SETB;
                            end
                            else
                            begin
                                state <= ERRORSTATE;
                            end
                        end
                        else begin
                            state <= EXTRASETA;
                            j <= 2;
                        end
                    end
                    
                    EXTRASETA: begin
                        if ((!memIsEmpty[i-j]) && (i-j != -1)) begin
                            if (memIsSign[i-j] == 3'd000) begin
                                semi_a <= memCalc[i-j];
                                state <= SETB;
                            end
                            else
                            begin 
                                state <= ERRORSTATE;
                            end
                        end
                        else begin
                            if (i-j != -1) begin
                                j = j + 1;
                                state <= EXTRASETA;
                            end
                            else begin
                                state <= ERRORSTATE;
                            end
                        end
                    end
                    
                    SETB: begin
                        if (!memIsEmpty[i+1]) begin
                            if (memIsSign[i+1] == 3'd000) begin
                                semi_b <= memCalc[i+1];
                                state <= INITALU;
                            end
                            else
                            begin
                                state <= ERRORSTATE;
                            end
                        end
                        else begin
                            state <= EXTRASETB;
                            j <= 2;
                        end
                    end
                    
                    EXTRASETB: begin
                        if ((!memIsEmpty[i+j]) && (i+j != 9)) begin
                            if (memIsSign[i-j] == 3'd000) begin
                                semi_b <= memCalc[i+j];
                                state <= INITALU;
                            end
                            else
                            begin 
                                state <= ERRORSTATE;
                            end
                        end
                        else begin
                            if (i+j != 9) begin
                                j = j + 1;
                                state <= EXTRASETB;
                            end
                            else begin
                                state <= ERRORSTATE;
                            end
                        end
                    end
                    
                    INITALU: begin
                        a <= semi_a;
                        b <= semi_b;
                        op <= signNumber;
                        
                        if ((signNumber == 2'b11) || (signNumber == 2'b10)) begin
                            loop <= 2; // loop times depends upon ALU speed and the clk speed cause it is there to solve any issues related to timing slack.
                        end
                        else if (signNumber == 2'b01) begin
                            loop <= 3;
                        end
                        else
                        begin
                            loop <= 4;
                        end
                        
                        state <= WAITCYCLE;
                    end
                    
                    WAITCYCLE: begin
                        if (loop != 0) begin
                            loop = loop - 1;
                            state <= WAITCYCLE;
                        end
                        else
                        begin
                            state <= FETCHRESULT;
                        end
                    end
                    
                    FETCHRESULT: begin
                        block_result <= result;
                        state <= MEMREWRITE;
                    end
                    
                    MEMREWRITE: begin
                        memIsEmpty[i] <= 1'b1;
                        memIsEmpty[i+1] <= 1'b1;
                        memCalc[i-1] <= block_result;
                        state <= SIGNFIND;
                        n <= 0;
                        s <= 0;
                        m <= 0;
                    end
                    
                    VERIF2: begin
                        for (m = 0; m < 9; m = m + 1) begin
                            if (memIsEmpty[m] != 1) begin
                                n = n + 1;
                                s = m;
                            end
                        end
                        
                        if (n) begin
                            state <= SENDOUTPUT;
                        end
                        else
                        begin
                            state <= ERRORSTATE;
                        end
                    end
                    
                    SENDOUTPUT: begin
                        final_output <= memCalc[s];
                        errorSignal <= 1'b0;
                        state <= INITMEM;
                    end
                    
                    ERRORSTATE: begin
                        final_output <= 32'd0;
                        errorSignal <= 1'b1;
                        state <= INITMEM;
                    end
                    
                    default: begin
                        final_output <= 32'd0;
                        errorSignal <= 1'b1;
                        state <= INITMEM;
                    end
                    
                endcase
            end
        end
      
    end // always block's end
    
endmodule
