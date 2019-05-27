`include "SetImm.v";
//`include "Brancher.v";
`include "Adder.v";

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

reg [31:0] REG [31:0];	// Set (and keep) REG[0] to zero.
reg [31:0] REG1;			// Gets value according to instr_out[19:15]
reg [31:0] REG2;
reg [ 4:0] RD;  			// Index of destination REG.
//reg [31:0] imm;
reg [31:0] pc; 				// Setting at instr_addr + 4 in each cycle.
reg [ 4:0] readingREG; 		// REG index of sending data to DM.
reg [31:0] branchDest;		// Branch destination for B-Type Operations
integer temp;

wire [31:0] imm;
SetImm s(
	.instr_type(instr_out[6:0]),
	.instr(instr_out),
	.imm(imm)
);

wire [31:0] adder_result;
Adder a(
	.IN1(REG1),
	.IN2(REG2),
	.RESULT(adder_result)
);

// wire [31:0] t1;
// wire [31:0] t2;
// assign t1 = instr_addr + $signed(imm);
// assign t2 = pc;
// wire [31:0] bout;
// Brancher b(
// 	.clk(clk),
// 	.mode(instr_out[14:12]),
// 	.rs1(REG1),
// 	.rs2(REG2),
// 	.target1(t1),
// 	.target2(t2),
// 	.target_result(bout)
// );

initial
begin
	pc = 32'h0;
	instr_addr = 32'b0;
end

always@(posedge clk)
begin
	pc = pc + 4;
	if(data_read) // For the data lagging 1 tick
	begin
		REG[readingREG] = data_out;
	end
	if(rst)  // Resetting
	begin
		pc = 0;
		instr_addr = 0;
        data_write = 0;
        data_read = 0;
        REG[0] = 32'b0;
	end

	REG[0] = 32'b0;
	REG1 = REG[instr_out[19:15]];  // For using in the right side of equation.
	REG2 = REG[instr_out[24:20]];  // For using in the right side of equation.
	RD = instr_out[11:7];
	data_read = 0;
	data_write = 0;

	// Distinguish instruction according to instr_out[14:12], instr_out[6:0]
	$display("=======================================================");
	case ({instr_out[14:12], instr_out[6:0]})
		10'b0000110011: // ADD/SUB
		begin
			if(instr_out[30] == 1'b0)
			begin
				REG[RD] = adder_result; //$signed(REG1) + $signed(REG2); 
			end
			else
			begin
				REG[RD] = $signed(REG1) - $signed(REG2);
			end
		end
		10'b0010110011: // SLL
		begin
			REG[RD] = REG1 << REG2[4:0];
		end
		10'b0100110011: // SLT
		begin
			REG[RD] = $signed(REG1) < $signed(REG2) ? 32'b1 : 32'b0;
		end
		10'b0110110011: // SLTU
		begin
			REG[RD] = REG1 < REG2 ? 32'b1 : 32'b0;
		end
		10'b1000110011: // XOR
		begin
			REG[RD] = REG1 ^ REG2;
		end
		10'b1010110011: // SRL, SRA
		begin
			if(instr_out[30] == 1'b0)
			begin
				REG[RD] = REG1 >> REG2[4:0];
			end
			else
			begin
				REG[RD] = $signed(REG1) >>> REG2[4:0];
			end
		end
		10'b1100110011: // OR
		begin
			REG[instr_out[11:7]] = REG1 | REG2;
		end
		10'b1110110011: // AND
		begin
			REG[RD] = REG1 & REG2;
		end
		10'b0100000011: // LW
		begin
			data_addr = $signed(REG1) + $signed(imm);
			data_read = 1'b1;
			readingREG = RD;
		end
		10'b0000010011: // ADDI
		begin
			REG[RD] = $signed(REG1) + $signed(imm);
		end
		10'b0010010011: // SLLI 
		begin
			REG[RD] = REG1 << imm[4:0];
		end
		10'b0100010011: // SLTI
		begin
			REG[RD] = $signed(REG1) < $signed(imm) ? 32'b1 : 32'b0;
		end
		10'b0110010011: // SLTIU
		begin
			REG[RD] = REG1 < imm ? 32'b1 : 32'b0;
		end
		10'b1000010011: // XORI
		begin
			REG[RD] = REG1 ^ imm;
		end
		10'b1010010011: // SRLI, SRAI
		begin
			if(instr_out[30] == 0)
			begin
				REG[RD] = REG1 >> instr_out[24:20];
			end
			else
			begin
				REG[RD] = $signed(REG1) >>> instr_out[24:20];
			end
		end
		10'b1100010011: // ORI
		begin
			REG[RD] = REG1 | imm;
		end
		10'b1110010011: // ANDI
		begin
			REG[RD] = REG1 & imm;
		end
		10'b0001100111: // JALR
		begin
			REG[RD] = pc;
			pc = $signed(imm) + $signed(REG1);
		end
		10'b0100100011: // SW
		begin
			data_write = 1'b1;
			data_in = REG2;
			data_addr = $signed(REG1) + $signed(imm);
		end
		default:
		begin
			case(instr_out[6:0])
				7'b0010111: //AUIPC
				begin
					REG[RD] = $signed(instr_addr)  + $signed(imm);
				end
				7'b0110111: // LUI
				begin
					REG[RD] = imm;
				end
				7'b1101111: // JAL
				begin
					REG[RD] = pc;
					pc = $signed(instr_addr) + $signed(imm);
				end
				default: begin end
			endcase
		end
	endcase

	if (instr_out[6:0] == 7'b1100011)
	begin
		branchDest = instr_addr + $signed(imm);
		case(instr_out[14:12])
			3'b000: pc = (REG1 == REG2 ? branchDest : pc);
			3'b001: pc = (REG1 != REG2 ? branchDest : pc);
			3'b100: pc = ($signed(REG1) < $signed(REG2) ? branchDest : pc);
			3'b101: pc = ($signed(REG1) >= $signed(REG2) ? branchDest : pc);
			3'b110: pc = (REG1 < REG2 ? branchDest : pc);
			3'b111: pc = (REG1 >= REG2 ? branchDest : pc);
		default: begin  end
		endcase
	end

	//Getting New instr_addr.
	instr_addr = pc;
end
endmodule