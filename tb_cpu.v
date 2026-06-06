`timescale 1ns / 1ps

module tb_top;

    reg CLK;
    reg AR;

    
    mips_pipelined_top uut (
        .CLK(CLK),
        .AR(AR)
    );

    
    initial CLK = 0;
    always #5 CLK = ~CLK;

    integer i;

    initial begin
        
        $display("     MIPS 5-Stage Pipeline Simplified Test");
        
        
        
        AR = 1;
        #12; 
        AR = 0;

        
        #160000;

        
        $display("\n");
        $display("              FINAL REGISTER FILE DUMP                  ");
        $display("\n");
        
        for (i = 0; i < 32; i = i + 4) begin
            $display("R%02d: %08h | R%02d: %08h | R%02d: %08h | R%02d: %08h", 
                     i,   uut.ID_stage.rf.Q[i], 
                     i+1, uut.ID_stage.rf.Q[i+1], 
                     i+2, uut.ID_stage.rf.Q[i+2], 
                     i+3, uut.ID_stage.rf.Q[i+3]);
        end
        $display("=================================================================\n");

        $display("Simulation Complete.");
        $finish;
    end

    
    initial begin
        $dumpfile("mips_pipeline.vcd");
        $dumpvars(0, tb_top);
    end

endmodule