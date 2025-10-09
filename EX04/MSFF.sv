// module MSFF  (
//     /*input with wire clk, input wire d, and output wire q*/
//     input logic clk,
//     input logic d,
//     output logic q
// );
//     wire md;
//     wire sd;
//     logic mq;
//     logic not_clk;

//     not n1(not_clk, clk);

//     notif1 #1 nt1 (md, d, not_clk);
//     //inverter
//     not n2 (mq, md);
//     //weak drive
//     not (weak0, weak1) inv1 (md, mq);

//     notif1 #1 nt2 (sd, mq, clk);
//     //inverter
//     not n3 (q, sd);
//     //weak drive
//     not (weak0, weak1) inv2 (sd, q);

// endmodule

module MSFF(
    input wire clk,
    input wire d,
    output wire q
);
    wire md, sd, nclk, mq;

    // Invert clock
    not  u_not_clk(nclk, clk);

    // Master latch
    notif1 #1 u_master(md, d, nclk); // inverting tri-state, data first, control second
        // Weak inverter for master node
        not (weak0, weak1) inv2_md(md, mq);
        //Output
        not u_not_q(mq, md);


    // Slave latch
    notif1 #1 u_slave(sd, mq, clk);
        // Weak inverter for slave node
        not (weak0, weak1) inv2_sd(sd, q);
        //  Output
        not u_not_qinv(q, sd);


endmodule