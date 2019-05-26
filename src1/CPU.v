// Please include verilog file if you write module in other file

module CPU(
    input         		clk,
    input         		rst,
    output reg       	instr_read,
    output reg 	[31:0] 	instr_addr,
    input  		[31:0] 	instr_out,
    output reg       	data_read,
    output reg       	data_write,
    output reg 	[31:0] 	data_addr,
    output reg 	[31:0] 	data_in,
    input   	[31:0] 	data_out
);

reg [31:0] REGISTER [31:0];
reg [4:0] readingREG;
reg [31:0] IMM;
reg [31:0] PC;
reg [31:0] REG_1;
reg [4:0] RD;
integer temp;

initial
begin
	PC = 0;
	instr_addr = 0;
    data_write = 0;
    data_read = 0;
    REGISTER[0] = 32'b0;
end

always @ (posedge clk)
begin
	REGISTER[0] = 32'b0;
	REG_1 = REGISTER[instr_out[19:15]];
	RD = instr_out[11:7];
	instr_read = 1'b1;
	if(data_read)
	begin
		REGISTER[readingREG] = data_out;
		data_read = 1'b0;
	end
	data_write = 1'b0;

	if(rst)
	begin
		PC = 0;
		instr_addr = 0;
        data_write = 0;
        data_read = 0;
        REGISTER[0] = 32'b0;
	end

	$display("==========================================================\nNew tick! Current PC = %h, It is %b-%b-%b-%b-%b", PC, instr_out[31:20], instr_out[19:15], instr_out[14:12], instr_out[11:7], instr_out[6:0]);
	case ({instr_out[14:12], instr_out[6:0]})
		10'b0000110011: // ADD/SUB =pass
		begin
			$display("It is a ADD/SUB command.");
			if(instr_out[30] == 1'b0)
			begin
				REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) + $signed(REGISTER[instr_out[24:20]]); 
			end
			else
			begin
				REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) - $signed(REGISTER[instr_out[24:20]]);
			end
		end
		10'b0010110011: // SLL =pass
		begin
			$display("It is a SLL command.");
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] << REGISTER[instr_out[24:20]][4:0];
		end
		10'b0100110011: // SLT =pass
		begin
			$display("It is a SLT command.");
			REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) < $signed(REGISTER[instr_out[24:20]]) ? 32'b1 : 32'b0;
		end
		10'b0110110011: // SLTU =pass
		begin
			$display("It is a SLTU command.");
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] < REGISTER[instr_out[24:20]] ? 32'b1 : 32'b0;
		end
		10'b1000110011: // XOR =pass
		begin
			$display("It is a XOR command.");
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] ^ REGISTER[instr_out[24:20]];
		end
		10'b1010110011: // SRL, SRA =pass
		begin
			$display("It is a SRL/SRA command.");
			if(instr_out[30] == 1'b0)
			begin
				REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] >> REGISTER[instr_out[24:20]][4:0];
			end
			else
			begin
				REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) >>> REGISTER[instr_out[24:20]][4:0];
			end
		end
		10'b1100110011: // OR =pass
		begin
			$display("It is a OR command.");
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] | REGISTER[instr_out[24:20]];
		end
		10'b1110110011: // AND =pass
		begin
			$display("It is a AND command.");
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] & REGISTER[instr_out[24:20]];
		end
		10'b0100000011: // LW
		begin
			$display("It is a LW command.");
			IMM = $signed(instr_out) >>> 20;
			data_addr = $signed(REGISTER[instr_out[19:15]]) + $signed(IMM);
			data_read = 1'b1;
			readingREG = instr_out[11:7];
		end
		10'b0000010011: // ADDI =pass
		begin
			$display("It is a ADDI command.");
			REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) + $signed(instr_out) >>> 20;
		end
		10'b0010010011: // SLLI 
		begin
			$display("It is a SLLI command.");
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] << instr_out[24:20];
		end
		10'b0100010011: // SLTI
		begin
			$display("It is a SLTI command.");
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = $signed(REGISTER[instr_out[19:15]]) < $signed(IMM) ? 32'b1 : 32'b0;
		end
		10'b0110010011: // SLTIU
		begin
			$display("It is a SLTIU command.");
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] < IMM ? 32'b1 : 32'b0;
		end
		10'b1000010011: // XORI
		begin
			$display("It is a XORI command.");
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] ^ IMM;
		end
		10'b1010010011: // SRLI, SRAI
		begin
			$display("It is a SRLI/SRAI command.");
			if(instr_out[30] == 0)
			begin
				REGISTER[RD] = REGISTER[instr_out[19:15]] >> instr_out[24:20];
			end
			else
			begin
				REGISTER[RD] = $signed(REGISTER[instr_out[19:15]]) >>> instr_out[24:20];
			end
		end
		10'b1100010011: // ORI
		begin
			$display("It is a ORI command.");
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] | IMM;
		end
		10'b1110010011: // ANDI
		begin
			$display("It is a ANDI command.");
			IMM = $signed(instr_out) >>> 20;
			REGISTER[instr_out[11:7]] = REGISTER[instr_out[19:15]] & IMM;
		end
		10'b0001100111: // JALR
		begin
			$display("It is a JALR command.");
			//REG_1 = REGISTER[instr_out[19:15]];
			IMM = $signed(instr_out) >>> 20;
			REGISTER[RD] = PC;
			PC = $signed(IMM) + $signed(REG_1);
		end
		10'b0100100011: // SW =pass
		begin
			$display("It is a SW command.");
			IMM = instr_out[31] == 1'b1 ? {20'b11111111111111111111, instr_out[31:25], instr_out[11:7]} : {20'b0, instr_out[31:25], instr_out[11:7]};
			data_write = 1'b1;
			data_in = REGISTER[instr_out[24:20]];
			data_addr = $signed(REGISTER[instr_out[19:15]]) + $signed(IMM);
		end
		10'b0001100011: // BEQ =pass
		begin
			$display("It is a BEQ command.");
			IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			PC = REGISTER[instr_out[19:15]] == REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
		end
		10'b0011100011: // BNE =pass
		begin
			$display("It is a BNE command.");
			IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			PC = REGISTER[instr_out[19:15]] != REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
		end
		10'b1001100011: // BLT =pass
		begin
			$display("It is a BLT command.");
			IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			PC = $signed(REGISTER[instr_out[19:15]]) < $signed(REGISTER[instr_out[24:20]]) ? instr_addr + $signed(IMM) : PC ;
		end
		10'b1011100011: // BGE =pass
		begin
			$display("It is a BGE command.");
			IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			PC = $signed(REGISTER[instr_out[19:15]]) >= $signed(REGISTER[instr_out[24:20]]) ? instr_addr + $signed(IMM) : PC;
		end
		10'b1101100011: // BLTU =pass
		begin
			$display("It is a BLTU command.");
			IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			PC = REGISTER[instr_out[19:15]] < REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
		end
		10'b1111100011: // BGEU =pass
		begin
			$display("It is a BGEU command.");
			IMM = instr_out[31] == 1 ? {19'b1111111111111111111, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : {19'b0, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			PC = REGISTER[instr_out[19:15]] >= REGISTER[instr_out[24:20]] ? instr_addr + $signed(IMM) : PC;
		end
		default: 
		begin
			case(instr_out[6:0])
				7'b0010111: //AUIPC =pass
				begin
					$display("It is a AUIPC command.");
					IMM = {instr_out[31:12], 12'b0};
					REGISTER[instr_out[11:7]] = $signed(instr_addr)  + $signed(IMM);
				end
				7'b0110111: // LUI =pass
				begin
					$display("It is a LUI command.");
					IMM = {instr_out[31:12], 12'b0};
					REGISTER[instr_out[11:7]] = IMM;
				end
				7'b1101111: // JAL =pass
				begin
					$display("It is a JAL command.");
					IMM = instr_out[31] == 1'b1 ? {11'b11111111111, instr_out[31], instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0} : {11'b00000000000, instr_out[31], instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0};
					REGISTER[instr_out[11:7]] = PC;
					PC = $signed(instr_addr) + $signed(IMM);
				end
				default: begin $display("IDK why but u are in the default block."); end 
			endcase
		end
	endcase
	REGISTER[0] = 32'b0;
	// for (temp = 0;temp < 32;temp = temp + 1)
	// begin
	// 	$display("| REGISTER[%d] = %b |", temp, REGISTER[temp]);
	// end
	//instr_read = !instr_read;
	instr_addr = PC;
	PC = PC + 4;
end
endmodule