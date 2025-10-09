module synch_detect(
    input  logic clk,
    input  logic rst_n,
    input  logic asynch_sig_in,
    output logic rise_edge
);

    logic sync_ff1_q;
    logic sync_ff2_q;
    logic prev_q;
    logic not_sync_ff2;

    // First stage: synchronize asynch_sig_in to clk domain
    dff u_ff1 (
        .D   (asynch_sig_in),
        .clk (clk),
        .PRN (rst_n),
        .Q   (sync_ff1_q)
    );

    // Second stage: further reduce metastability
    dff u_ff2 (
        .D   (sync_ff1_q),
        .clk (clk),
        .PRN (rst_n),
        .Q   (sync_ff2_q)
    );

    // Third stage: store previous value for edge detection
    dff u_ff3 (
        .D   (sync_ff2_q),
        .clk (clk),
        .PRN (rst_n),
        .Q   (prev_q)
    );

    // Invert previous value
    not  n1 (not_sync_ff2,prev_q);
    // Rising edge detection: output high for 1 clk when signal rises
    and a1 (rise_edge,sync_ff2_q,not_sync_ff2);

endmodule