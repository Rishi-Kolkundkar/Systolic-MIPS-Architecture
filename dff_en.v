// module dl (
//     output wire Q,
//     output wire Qbar,
//     input wire CLK,
//     input wire D,
//     input wire AR  
// );
//     wire nD, s, r;
//     wire ar_n, s_masked, r_masked;
//     wire q_int, qbar_int;

    
//     not (nD, D);
//     not (ar_n, AR);


//     and (s, nD, CLK);
//     and (r, D, CLK);


    

//    nor  (q_int, s, qbar_int, AR);
//     nor (qbar_int, r, q_int,AR);

    
//     buf  (Q, q_int);
//     buf  (Qbar,qbar_int);
// endmodule


// module d_flip_flop_en (
//     input wire AR,  
//     input wire D,   
//     input wire CLK, 
//     input wire EN,  
//     output wire Q   
// );
//     wire nck, interq, d_final;


//     // Invert clock for master latch
//     not (nck, CLK);

    
    
//     MUX_2 m1 ({D,Q},EN, d_final);

//     // Master latch with AR
//     dl master (
//         .CLK(nck),
//         .D(d_final),
//         .AR(AR),
//         .Q(interq),
//         .Qbar() // unused
//     );

//     // Slave latch with AR
//     dl slave (
//         .CLK(CLK),
//         .D(interq),
//         .AR(AR),
//         .Q(Q),
//         .Qbar() // unused
//     );
// endmodule






// Behavioural flip flips as gate level flips took a long time to compile

module d_flip_flop_en (
    input wire AR,   
    input wire D,    
    input wire CLK,  
    input wire EN,   
    output reg Q     
);
    
    always @(posedge CLK or posedge AR) begin
        if (AR) begin
            Q <= 1'b0;      
        end 
        else if (EN) begin
            Q <= D;         
        end
        
    end
endmodule


module d_flip_flop_sr (
    input wire AR,   
    input wire D,    
    input wire CLK,  
    input wire EN,   
    input wire SR,   
    output reg Q     
);
    always @(posedge CLK or posedge AR) begin
        if (AR) begin
            Q <= 1'b0;      
        end 
        else if (SR) begin
            Q <= 1'b0;      
        end 
        else if (EN) begin
            Q <= D;         
        end
    end
endmodule