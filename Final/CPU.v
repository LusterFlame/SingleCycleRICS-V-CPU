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

reg [31:0] REGISTER [31:0];	// Set (and keep) REGISTER[0] to zero.
reg [31:0] REG_1;			// Gets value according to instr_out[19:15]
reg [31:0] REG_2;
reg [ 4:0] RD;  			// Index of destination register.
reg [31:0] IMMEDIATE;
reg [31:0] PC; 				// Setting at instr_addr + 4 in each cycle.
reg [ 4:0] readingREG; 		// Register index of sending data to DM.
integer temp;

initial
begin
	PC = 32'h0;
	instr_addr = 32'b0;
end

always@(posedge clk)
begin
	PC = PC + 4;
	if(data_read) // For the data lagging 1 tick
	begin
		REGISTER[readingREG] = data_out;
	end
	if(rst)  // Resetting
	begin
		// PC = 32'h0;
		// instr_addr = 32'b0;
		PC = 0;
		instr_addr = 0;
        data_write = 0;
        data_read = 0;
        REGISTER[0] = 32'b0;
	end

	REGISTER[0] = 32'b0;
	IMMEDIATE = 32'b0;
	REG_1 = REGISTER[instr_out[19:15]];  // For using in the right side of equation.
	REG_2 = REGISTER[instr_out[24:20]];  // For using in the right side of equation.
	RD = instr_out[11:7];
	data_read = 0;
	data_write = 0;

	$display("==========================================================\nNew tick! Current instr_addr = %h, It is %b-%b-%b-%b-%b", PC, instr_out[31:20], instr_out[19:15], instr_out[14:12], instr_out[11:7], instr_out[6:0]);
	// Set IMMEDIATE according to excution type.
	case(instr_out[6:0])
		// I-Type
		7'b0000011, 7'b0010011, 7'b1100111:
		begin
			IMMEDIATE = $signed(instr_out) >>> 20;
		end
		// S-Type
		7'b0100011:
		begin
			IMMEDIATE = $signed({instr_out[31:25], instr_out[11:7], 20'b0}) >>> 20;
		end
		// B-Type
		7'b1100011:
		begin
			IMMEDIATE = $signed({instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 20'b0}) >>> 19;
		end
		// U-Type
		7'b0010111, 7'b0110111:
		begin
			IMMEDIATE = {instr_out[31:12], 12'b0};
		end
		// J-Type
		7'b1101111:
		begin
			IMMEDIATE = $signed({instr_out[31], instr_out[19:12], instr_out[20], instr_out[30:21], 12'b0}) >>> 11;
		end
	endcase
	$display("IMMEDIATE set to %b.", IMMEDIATE);

	// Distinguish instruction according to instr_out[14:12], instr_out[6:0]
	case ({instr_out[14:12], instr_out[6:0]})
		10'b0000110011: // ADD/SUB
		begin
			if(instr_out[30] == 1'b0)
			begin
				$display("It is a ADD command.");
				REGISTER[RD] = $signed(REG_1) + $signed(REG_2); 
			end
			else
			begin
				$display("It is a SUB command.");
				REGISTER[RD] = $signed(REG_1) - $signed(REG_2);
			end
		end
		10'b0010110011: // SLL
		begin
			$display("It is a SLL command.");
			REGISTER[RD] = REG_1 << REG_2[4:0];
		end
		10'b0100110011: // SLT
		begin
			$display("It is a SLT command.");
			REGISTER[RD] = $signed(REG_1) < $signed(REG_2) ? 32'b1 : 32'b0;
		end
		10'b0110110011: // SLTU
		begin
			$display("It is a SLTU command.");
			REGISTER[RD] = REG_1 < REG_2 ? 32'b1 : 32'b0;
		end
		10'b1000110011: // XOR
		begin
			$display("It is a XOR command.");
			REGISTER[RD] = REG_1 ^ REG_2;
		end
		10'b1010110011: // SRL, SRA
		begin
			if(instr_out[30] == 1'b0)
			begin
				$display("It is a SRL command.");
				REGISTER[RD] = REG_1 >> REG_2[4:0];
			end
			else
			begin
				$display("It is a SRA command.");
				REGISTER[RD] = $signed(REG_1) >>> REG_2[4:0];
			end
		end
		10'b1100110011: // OR
		begin
			$display("It is a OR command.");
			REGISTER[instr_out[11:7]] = REG_1 | REG_2;
		end
		10'b1110110011: // AND
		begin
			$display("It is a AND command.");
			REGISTER[RD] = REG_1 & REG_2;
		end
		10'b0100000011: // LW
		begin
			$display("It is a LW command.");
			data_addr = $signed(REG_1) + $signed(IMMEDIATE);
			data_read = 1'b1;
			readingREG = RD;
		end
		10'b0000010011: // ADDI
		begin
			$display("It is a ADDI command.");
			REGISTER[RD] = $signed(REG_1) + IMMEDIATE;
		end
		10'b0010010011: // SLLI 
		begin
			$display("It is a SLLI command.");
			REGISTER[RD] = REG_1 << instr_out[24:20];
		end
		10'b0100010011: // SLTI
		begin
			$display("It is a SLTI command.");
			REGISTER[RD] = $signed(REG_1) < $signed(IMMEDIATE) ? 32'b1 : 32'b0;
		end
		10'b0110010011: // SLTIU
		begin
			$display("It is a SLTIU command.");
			REGISTER[RD] = REG_1 < IMMEDIATE ? 32'b1 : 32'b0;
		end
		10'b1000010011: // XORI
		begin
			$display("It is a XORI command.");
			REGISTER[RD] = REG_1 ^ IMMEDIATE;
		end
		10'b1010010011: // SRLI, SRAI
		begin
			if(instr_out[30] == 0)
			begin
				$display("It is a SRLI command.");
				REGISTER[RD] = REG_1 >> instr_out[24:20];
			end
			else
			begin
				$display("It is a SRAI command.");
				REGISTER[RD] = $signed(REG_1) >>> instr_out[24:20];
			end
		end
		10'b1100010011: // ORI
		begin
			$display("It is a ORI command.");
			REGISTER[RD] = REG_1 | IMMEDIATE;
		end
		10'b1110010011: // ANDI
		begin
			$display("It is a ANDI command.");
			REGISTER[RD] = REG_1 & IMMEDIATE;
		end
		10'b0001100111: // JALR
		begin
			$display("It is a JALR command.");
			REGISTER[RD] = PC;
			PC = $signed(IMMEDIATE) + $signed(REG_1);
		end
		10'b0100100011: // SW
		begin
			$display("It is a SW command.");
			data_write = 1'b1;
			data_in = REG_2;
			data_addr = $signed(REG_1) + $signed(IMMEDIATE);
		end
		10'b0001100011: // BEQ
		begin
			$display("It is a BEQ command.");
			PC = REG_1 == REG_2 ? instr_addr + $signed(IMMEDIATE) : PC;
		end
		10'b0011100011: // BNE
		begin
			$display("It is a BNE command.");
			PC = REG_1 != REG_2 ? instr_addr + $signed(IMMEDIATE) : PC;
		end
		10'b1001100011: // BLT
		begin
			$display("It is a BLT command.");
			PC = $signed(REG_1) < $signed(REG_2) ? instr_addr + $signed(IMMEDIATE) : PC ;
		end
		10'b1011100011: // BGE
		begin
			$display("It is a BGE command.");
			PC = $signed(REG_1) >= $signed(REG_2) ? instr_addr + $signed(IMMEDIATE) : PC;
		end
		10'b1101100011: // BLTU
		begin
			$display("It is a BLTU command.");
			PC = REG_1 < REG_2 ? instr_addr + $signed(IMMEDIATE) : PC;
		end
		10'b1111100011: // BGEU
		begin
			$display("It is a BGEU command.");
			PC = REG_1 >= REG_2 ? instr_addr + $signed(IMMEDIATE) : PC;
		end
		default:
		begin
			case(instr_out[6:0])
				7'b0010111: //AUIPC
				begin
					$display("It is a AUIPC command.");
					REGISTER[RD] = $signed(instr_addr)  + $signed(IMMEDIATE);
				end
				7'b0110111: // LUI
				begin
					$display("It is a LUI command.");
					REGISTER[RD] = IMMEDIATE;
				end
				7'b1101111: // JAL
				begin
					$display("It is a JAL command.");
					REGISTER[RD] = PC;
					PC = $signed(instr_addr) + $signed(IMMEDIATE);
				end
				default:
				begin
					$display("Something is wrong. You shouldn't be in here.");
				end
			endcase
		end
	endcase

	//Print all REGISTER's current data.
	for (temp = 0;temp < 32;temp = temp + 1)
	begin
		$display("| REGISTER[%d] = %b |", temp, REGISTER[temp]);
	end

	//Getting New instr_addr.
	instr_addr = PC;
end
endmodule