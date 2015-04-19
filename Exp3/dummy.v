/*
		case(state)

		2'd2:begin
			
		end

		2'd0:begin

			ACK_R[2:0] = 3'b0;  //default value.

			if(ack_st == 2'd0) begin
				next_SDO = DATA[SD_cnt];
				//ACK_R[2:0] = 3'b0; 
			end
			else begin //when encounter acknowledgement
				next_SDO = 1'bz;
				//ACK_R[ack_st - 2'b1] = I2C_SDAT:
			end
		end

		2'd1:begin
		end

		endcase*/

/* I2C PROGRESS STATE
*  0~1  : state 10
*  1~29 : state 00
*  29~33: state 01
*/
//wire state = {((SD_cnt < INIT_COUNT)&(~(SD_cnt > (INIT_COUNT+6'd28)))),((SD_cnt >= INIT_COUNT) & (SD_cnt <= 6'd30))};

/* ACKNOWLEDGEMENT STATE
*  cnt 9 : ack_st 1
*  cnt 18: ack_st 2
*  cnt 27: ack_st 3
*  other : ack_st 0
*/
/*wire ack_st = { ((&{  SD_cnt[4], (~SD_cnt[3]), (~SD_cnt[2]),   SD_cnt[1], (~SD_cnt[0])}) | 
				 (&{  SD_cnt[4],   SD_cnt[3],  (~SD_cnt[2]),   SD_cnt[1],   SD_cnt[0] })),
				((&{(~SD_cnt[4]),  SD_cnt[3],  (~SD_cnt[2]), (~SD_cnt[1]),  SD_cnt[0] }) | 
				 (&{  SD_cnt[4],   SD_cnt[3],  (~SD_cnt[2]),   SD_cnt[1],   SD_cnt[0] })) };*/