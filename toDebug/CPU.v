module CPU(
	input         	  	clk, 
	input				rst,
	output reg        	instr_read,
	output reg [31:0] 	instr_addr,
	input  	   [31:0] 	instr_out,
	output reg        	data_read,
	output reg        	data_write,
	output reg [31:0] 	data_addr,
	output reg [31:0] 	data_in,
	input      [31:0] 	data_out
);

reg [31:0] REGISTER [31:0];
reg [31:0] REG_1;
reg [31:0] REG_2;
reg [31:0] IMM;
reg [31:0] PC;

reg [4:0] RD;

initial
begin 
	PC = 0;
	instr_addr = 0;
end

always @ (posedge clk)
begin
	if(data_read)
	begin
		REGISTER[RD] = data_out;
	end

	REGISTER[0] = 0;
	IMM = 0;
	data_read = 0;
	data_write = 0;
	REG_1 = REGISTER[instr_out[19:15]];
	REG_2 = REGISTER[instr_out[24:20]];
	RD = instr_out[11:7];
	
	// R-type //
	if(instr_out[6:0] == 7'b0110011) begin
		case({instr_out[31:25], instr_out[14:12]})
			10'b0000000000: REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) + $signed(REGISTER[instr_out[24:20]]);		//ADD
			10'b0100000000: REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) - $signed(REGISTER[instr_out[24:20]]);		//SUB
			10'b0000000001: REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] << REGISTER[instr_out[24:20]][4:0];				//SLL
			10'b0000000010: REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) < $signed(REGISTER[instr_out[24:20]]) ? 32'b1 : 32'b0;//SLT
			10'b0000000011: REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] < REGISTER[instr_out[24:20]] ? 32'b1 : 32'b0;				//SLTU
			10'b0000000100: REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] ^ REGISTER[instr_out[24:20]]; 	   					//XOR
			10'b0000000101: REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] >> REGISTER[instr_out[24:20]][4:0];			//SRL
			10'b0100000101: REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) >>> REGISTER[instr_out[24:20]][4:0];		//SRA
			10'b0000000110: REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] | REGISTER[instr_out[24:20]];   					//OR
			10'b0000000111: REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] & REGISTER[instr_out[24:20]];						//AND
		endcase
	end
	
	// I-type //
	if(instr_out[6:0] == 7'b0000011 || instr_out[6:0] == 7'b0010011 ||instr_out[6:0] == 7'b1100111) IMM = $signed(instr_out) >>> 20;
	case({instr_out[6:0], instr_out[14:12]})
		10'b0000011010:
		begin 											//LW
			IMM = instr_out[31] == 1'b1 ? {20'b11111111111111111111, instr_out[31:20]} : {20'b0, instr_out[31:20]};
			data_addr = $signed(REGISTER[instr_out[19:15]]) + $signed(IMM);
			data_read = 1'b1;
		end
		10'b0010011000: REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) + ($signed(instr_out) >>> 20);	//ADDI REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] + ($signed(instr_out) >>> 20);
		10'b0010011010: 
		begin
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) < $signed(IMM) ? 32'b1 : 32'b0;//SLTI
		end
		10'b0010011011: //REGISTER[RD] = (REG_1 < IMM)? 1:0; 				//SLTIU
		begin
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] < IMM ? 32'b1 : 32'b0;
		end
		10'b0010011100: //REGISTER[RD] = REG_1 ^ IMM; 						//XORI
		begin
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] ^ IMM;
		end
		10'b0010011110: 
		begin
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] | IMM;						//ORI
		end
		10'b0010011111: //REGISTER[RD] = REG_1 & IMM; 						//ANDI
		begin
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] & IMM;
		end
		10'b0010011001: REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] << instr_out[24:20];		//SLLI
		10'b0010011101: begin
			// case(instr_out[30])	
			// 	1'b0: REGISTER[RD] = REG_1 >> instr_out[24:20];			//SRLI
			// 	1'b1: REGISTER[RD] = $signed(REG_1) >>> instr_out[24:20];	//SRAI
			// endcase
			if(instr_out[30] == 0)
			begin
				REGISTER[RD] = REGISTER[instr_out[19:15]] >> instr_out[24:20];
			end
			else
			begin
				REGISTER[RD] = $signed(REGISTER[instr_out[19:15]]) >>> instr_out[24:20];
			end
		end
		10'b1100111000: begin											//JALR
			// // REGISTER[RD] = PC;
			// // PC = $signed(IMM) + $signed(REG_1);
			// IMM = $signed(instr_out) >>> 20;
			// //IMM = $signed(instr_out) >>> 20; //[31] == 1'b1 ? {20'b11111111111111111111, instr_out[31:20]} : {20'b0, instr_out[31:20]};
			// REGISTER[RD] = PC;
			// //PC = $signed(IMM) + $signed(REGISTER[instr_out[19:15]]);
			// PC = $signed(IMM) + $signed(REG_1);
			IMM = $signed(instr_out) >>> 20;
			REGISTER[RD] = PC;
			PC = $signed(IMM) + $signed(REG_1);
		end
	endcase
	
	// S-type //SW /////////////////////////////////////////////////////////////////////////////////////
	if({instr_out[14:12], instr_out[6:0]} == 10'b0100100011) begin
		// IMM = {instr_out[31:25], RD} + instr_out[31]*(2**20-1)*2**12;
		// data_addr = $signed(REG_1) + $signed(IMM);
		// data_write = 1;
		// data_in = REG_2;

		IMM = instr_out[31] == 1'b1 ? {20'b11111111111111111111, instr_out[31:25], instr_out[11:7]} : {20'b0, instr_out[31:25], instr_out[11:7]};
		data_write = 1'b1;
		data_in = REGISTER[instr_out[24:20]];
		data_addr = $signed(REGISTER[instr_out[19:15]]) + $signed(IMM);
	end
	
	// B-type //////////////////////////////////////////////////////////////////////////////////////////
	if(instr_out[6:0] == 7'b1100011) begin
		{IMM[12], IMM[10:5], IMM[4:1], IMM[11]} = {instr_out[31:25], RD} + instr_out[31]*(2**19-1)*2**13;
		case(instr_out[14:12])
			3'b000: //if(REG_1 == REG_2)					 PC = instr_addr + $signed(IMM);//BEG
			begin
				IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
				PC = REGISTER[instr_out[19:15]] == REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
			end
			3'b001: //if(REG_1 != REG_2)					 PC = instr_addr + $signed(IMM);//BNE
			begin
				IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
				PC = REGISTER[instr_out[19:15]] != REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
			end
			3'b100: //if($signed(REG_1) < $signed(REG_2))	 PC = instr_addr + $signed(IMM);//BLT
			begin
				IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			PC = $signed(REGISTER[instr_out[19:15]]) < $signed(REGISTER[instr_out[24:20]]) ? instr_addr + $signed(IMM) : PC;
			end
			3'b101: //if($signed(REG_1) >= $signed(REG_2)) PC = instr_addr + $signed(IMM);//BQE
			begin
				IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
				PC = $signed(REGISTER[instr_out[19:15]]) >= $signed(REGISTER[instr_out[24:20]]) ? instr_addr + $signed(IMM) : PC;
			end
			3'b110: //if(REG_1 < REG_2)					 PC = instr_addr + $signed(IMM);//BLTU
			begin
				IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
				PC = REGISTER[instr_out[19:15]] < REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
			end
			3'b111: //if(REG_1 >= REG_2) 				 	 PC = instr_addr + $signed(IMM);//BGEU
			begin
				IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
				PC = REGISTER[instr_out[19:15]] >= REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
			end
		endcase
	end
	
	// U-type //////////////////////////////////////////////////////////////////////////////////////////
	case(instr_out[6:0])
		7'b0010111: //REGISTER[RD] = instr_addr + $signed(instr_out[31:12]*2**12);//AUIPC
		begin
			IMM = {instr_out[31:12], 12'b0};
			REGISTER[instr_out[11:7]] = $signed(instr_addr)  + $signed(IMM);
		end
		7'b0110111:	//REGISTER[RD] = instr_out[31:12]*2**12;						//LUI
		begin
			IMM = {instr_out[31:12], 12'b0};
			REGISTER[RD] = IMM;
		end
	endcase
	
	// J-type //JAL ////////////////////////////////////////////////////////////////////////////////////
	if(instr_out[6:0] == 7'b1101111) begin
		{IMM[20], IMM[10:1], IMM[11], IMM[19:12]} = $signed(instr_out) >>> 12;
		REGISTER[RD] = PC;
		PC = instr_addr + $signed(IMM);

	end

	instr_addr = PC;
	PC = PC + 4;
end
endmodule