module CPU(clk, rst, instr_read, instr_addr, instr_out, data_read, data_write, data_addr, data_in, data_out);

input         	  clk, rst;
output reg        instr_read;
output reg [31:0] instr_addr;
input  	   [31:0] instr_out;
output reg        data_read;
output reg        data_write;
output reg [31:0] data_addr;
output reg [31:0] data_in;
input      [31:0] data_out;

reg [31:0] register [31:0];
reg [31:0] rs1, rs2, imm, pc;
reg [4:0] rd;

initial {pc, instr_addr} = 0;

always@(posedge clk) begin
	if(data_read == 1) register[rd] = data_out;
	{register[0], imm, data_read, data_write} = 0;
	{rs1, rs2} = {register[instr_out[19:15]], register[instr_out[24:20]]};
	rd = instr_out[11:7];
	
	// R-type //////////////////////////////////////////////////////////////////////////////////////////
	if(instr_out[6:0] == 7'b0110011) begin
		case({instr_out[31:25], instr_out[14:12]})
			10'b0000000000: register[rd] = $signed(rs1) + $signed(rs2);		//ADD
			10'b0100000000: register[rd] = $signed(rs1) - $signed(rs2);		//SUB
			10'b0000000001: register[rd] = rs1 << rs2[4:0]; 				//SLL
			10'b0000000010: register[rd] = $signed(rs1) < $signed(rs2)? 1:0;//SLT
			10'b0000000011: register[rd] = (rs1 < rs2)? 1:0;				//SLTU
			10'b0000000100: register[rd] = rs1 ^ rs2; 	   					//XOR
			10'b0000000101: register[rd] = rs1 >> rs2[4:0]; 				//SRL
			10'b0100000101: register[rd] = $signed(rs1) >>> rs2[4:0];		//SRA
			10'b0000000110: register[rd] = rs1 | rs2; 	   					//OR
			10'b0000000111: register[rd] = rs1 & rs2;						//AND
		endcase
	end
	
	// I-type //////////////////////////////////////////////////////////////////////////////////////////
	if(instr_out[6:0] == 7'b0000011 || instr_out[6:0] == 7'b0010011 ||instr_out[6:0] == 7'b1100111) imm = $signed(instr_out) >>> 20;
	case({instr_out[6:0], instr_out[14:12]})
		10'b0000011010: begin 											//LW
			data_addr = $signed(rs1) + $signed(imm);
			data_read = 1;
		end
		10'b0010011000: register[rd] = $signed(rs1) + $signed(imm); 	//ADDI
		10'b0010011010: register[rd] = $signed(rs1) < $signed(imm)? 1:0;//SLTI
		10'b0010011011: register[rd] = (rs1 < imm)? 1:0; 				//SLTIU
		10'b0010011100: register[rd] = rs1 ^ imm; 						//XORI
		10'b0010011110: register[rd] = rs1 | imm; 						//ORI
		10'b0010011111: register[rd] = rs1 & imm; 						//ANDI
		10'b0010011001: register[rd] = rs1 << instr_out[24:20]; 		//SLLI
		10'b0010011101: begin
			case(instr_out[30])	
				1'b0: register[rd] = rs1 >> instr_out[24:20];			//SRLI
				1'b1: register[rd] = $signed(rs1) >>> instr_out[24:20];	//SRAI
			endcase
		end
		10'b1100111000: begin											//JALR
			register[rd] = pc;
			pc = $signed(imm) + $signed(rs1);
		end
	endcase
	
	// S-type //SW /////////////////////////////////////////////////////////////////////////////////////
	if({instr_out[14:12], instr_out[6:0]} == 10'b0100100011) begin
		imm = {instr_out[31:25], rd} + instr_out[31]*(2**20-1)*2**12;
		data_addr = $signed(rs1) + $signed(imm);
		data_write = 1;
		data_in = rs2;
	end
	
	// B-type //////////////////////////////////////////////////////////////////////////////////////////
	if(instr_out[6:0] == 7'b1100011) begin
		{imm[12], imm[10:5], imm[4:1], imm[11]} = {instr_out[31:25], rd} + instr_out[31]*(2**19-1)*2**13;
		case(instr_out[14:12])
			3'b000: if(rs1 == rs2)					 pc = instr_addr + $signed(imm);//BEG
			3'b001: if(rs1 != rs2)					 pc = instr_addr + $signed(imm);//BNE
			3'b100: if($signed(rs1) < $signed(rs2))	 pc = instr_addr + $signed(imm);//BLT
			3'b101: if($signed(rs1) >= $signed(rs2)) pc = instr_addr + $signed(imm);//BQE
			3'b110: if(rs1 < rs2)					 pc = instr_addr + $signed(imm);//BLTU
			3'b111: if(rs1 >= rs2) 				 	 pc = instr_addr + $signed(imm);//BGEU
		endcase
	end
	
	// U-type //////////////////////////////////////////////////////////////////////////////////////////
	case(instr_out[6:0])
		7'b0010111: register[rd] = instr_addr + $signed(instr_out[31:12]*2**12);//AUIPC
		7'b0110111:	register[rd] = instr_out[31:12]*2**12;						//LUI
	endcase
	
	// J-type //JAL ////////////////////////////////////////////////////////////////////////////////////
	if(instr_out[6:0] == 7'b1101111) begin
		{imm[20], imm[10:1], imm[11], imm[19:12]} = $signed(instr_out) >>> 12;
		register[rd] = pc;
		pc = instr_addr + $signed(imm);

	end

	instr_addr = pc;
	pc = pc + 4;
end
endmodule