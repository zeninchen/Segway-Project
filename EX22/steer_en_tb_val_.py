import math
if __name__ == "__main__":
    lft_spd = 0
    rgt_spd = 0
    sum_spd = lft_spd + rgt_spd
    diff_spd = rgt_spd - lft_spd
    min_rider_wt = 512
    wt_h= 64
    sum= min_rider_wt + wt_h
    diff=min_rider_wt - wt_h
    sum_lt_min =0
    sum_gt_min =0
    diff_gt_1_4 =0
    diff_gt_15_16 =0
    # create two files so we can log the inputs and outputs
    
    with open("steer_en_stim.hex", "w") as input_log_file, open("steer_en_resp.hex", "w") as output_log_file:
        for i in range(2048*2):
            # put the values in the log file        
            
            #log the sum_lt_min, and other values
            
            lft_spd += 1
            if(lft_spd > 2047):
                lft_spd = -2048
            rgt_spd = 0
            for j in range(2048*2):
                
                rgt_spd +=  1
                if(rgt_spd > 2047):
                    rgt_spd = -2048
                #the rght and lft speed 
                
                sum_spd = lft_spd + rgt_spd
                diff_spd = rgt_spd - lft_spd
                abs_diff_spd = abs(diff_spd)    
                change = False
                if sum_spd < diff:
                    if(sum_lt_min==0):
                        change = True
                    sum_lt_min = 1                   
                else:
                    if(sum_lt_min==1):
                        change = True
                    sum_lt_min = 0
                    
                if sum_spd > sum:
                    if(sum_gt_min==0):
                        change = True
                    sum_gt_min = 1   
                else:
                    if(sum_gt_min==1):
                        change = True
                    sum_gt_min = 0
                    
                if abs_diff_spd > (sum_spd/4):
                    if(diff_gt_1_4==0):
                        change = True
                    diff_gt_1_4 = 1                
                else:
                    if(diff_gt_1_4==1):
                        change = True
                    diff_gt_1_4 = 0
                    
                #round up the value for 15/16
                if abs_diff_spd > math.ceil(sum_spd * 15 / 16):
                    if(diff_gt_15_16==0):
                        change = True
                    diff_gt_15_16 = 1                 
                else:
                    if(diff_gt_15_16==1):
                        change = True
                    diff_gt_15_16 = 0
                
                if(change): 
                    #concatenate the values to the log files  
                    #remove the 0x prefix for hex values   
                    #format the values to have consistent width of 3 
                    # fill the blanks with 0s 
                    # if it is negative convert is to two's complement representation
                    if lft_spd < 0:
                        lft_spd_tc = (1 << 12) + lft_spd
                    else:
                        lft_spd_tc = lft_spd
                    if rgt_spd < 0:
                        rgt_spd_tc = (1 << 12) + rgt_spd
                    else:
                        rgt_spd_tc = rgt_spd           
                    input_log_file.write(f"{hex(lft_spd_tc)[2:]:>03}{hex(rgt_spd_tc)[2:]:>03}\n")
                    #format the output values to become a single hex value
                    output_value = (sum_lt_min << 3) | (sum_gt_min << 2) | (diff_gt_1_4 << 1) | diff_gt_15_16
                    output_log_file.write(f"{output_value:x}\n")
                    
                