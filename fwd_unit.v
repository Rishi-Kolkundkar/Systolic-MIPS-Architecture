module forwarding_unit (
    input wire       regwriteW, 
    input wire       regwriteM,
    input wire [4:0] wregW,     
    input wire [4:0] wregM,     
    input wire [4:0] rsE,       
    input wire [4:0] rtE,       

    output reg [1:0] ForwardAE, 
    output reg [1:0] ForwardBE  
);

    
    always @(*) begin
        
        //A
        if ((rsE != 5'd0) && (rsE == wregM) && regwriteM) begin
            ForwardAE = 2'b10; 
        end 
        else if ((rsE != 5'd0) && (rsE == wregW) && regwriteW) begin
            ForwardAE = 2'b01; 
        end 
        else begin
            ForwardAE = 2'b00;
        end

        //B
        if ((rtE != 5'd0) && (rtE == wregM) && regwriteM) begin
            ForwardBE = 2'b10;
        end 
        else if ((rtE != 5'd0) && (rtE == wregW) && regwriteW) begin
            ForwardBE = 2'b01; 
        end 
        else begin
            ForwardBE = 2'b00; 
        end
    end

endmodule

module hazard_detection_unit (
    input wire        mem_read_e, 
    input wire [4:0]  rt_e,       
    input wire [4:0]  rs_d,       
    input wire [4:0]  rt_d,       
    output reg        stall       
);

    always @(*) begin
        
        if (mem_read_e && (rt_e != 5'd0) && ((rt_e == rs_d) || (rt_e == rt_d))) begin
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
    end

endmodule