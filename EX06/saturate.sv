//create module saturate with inputs : unsigned_err[15:0], signed_err[15:0], signed_D_diff[9:0], and outputs: unsigned_err_sat[9:0], signed_err_sat[9:0] signed_D_diff_sat[6:0]
module saturate (
    input  logic [15:0] unsigned_err,
    input  logic [15:0] signed_err,
    input  logic [9:0] signed_D_diff,
    output logic [9:0] unsigned_err_sat,
    output logic [9:0] signed_err_sat,
    output logic [6:0] signed_D_diff_sat
);
    logic is_negative;
    logic is_negative_D;
    logic  contain1, contain0;
    logic  contain1_D, contain0_D;
    logic  contain1_u;
    //check if the input is negative
    assign is_negative = signed_err[15];
    //if the input is negative, we need to check if the bit [14:10] contains any 0s
    //if it is, we set the output to maximum negative value -256
    //if the input is positive, we need to check if the bit [14:10] contains any 1s
    //if it is, we set the output to maximum positive value 255
    //otherwise, we set the output to the input value
    //contain0 is true if there is at least one 0 in the range [14:10]
    //contain1 is true if there is at least one 1 in the range [14:10]
    assign contain1=|signed_err[14:9];
    assign contain0=~(&signed_err[14:9]);
    assign signed_err_sat = (is_negative) ? (contain0 ? 10'h200 : signed_err[9:0]) : (contain1 ? 10'h1FF : signed_err[9:0]);

    //for the unsigned error, we need to check if the bit [15:10] contains any 1s
    //if it is, we set the output to maximum value 1023
    //otherwise, we set the output to the input value
    //contain1_u is true if there is at least one 1 in the range [15:10]
    assign  contain1_u=|unsigned_err[15:9];
    assign unsigned_err_sat =  contain1_u? 10'h3FF : unsigned_err[9:0];

    //for the signed D diff, we need to check first check if it's negative
    assign is_negative_D = signed_D_diff[9];
    //if the input is negative, we need to check if the bit [8:7] contains any 0s
    //if it is, we set the output to maximum negative value -64
    //if the input is positive, we need to check if the bit [8:7] contains any 1s
    //if it is, we set the output to maximum positive value 63
    //otherwise, we set the output to the input value
    //contain0_D is true if there is at least one 0 in the range [8:7]
    //contain1_D is true if there is at least one 1 in the range [
    assign contain1_D=|signed_D_diff[8:6];
    assign contain0_D=~(&signed_D_diff[8:6]);
    assign signed_D_diff_sat = (is_negative_D) ? (contain0_D ? 7'h40 : signed_D_diff[6:0]) : (contain1_D ? 7'h3F : signed_D_diff[6:0]);
endmodule