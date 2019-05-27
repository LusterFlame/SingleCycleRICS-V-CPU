`include "SetImm.v";

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

reg [31:0] REG [31:0];
reg [31:0] REG1;
reg [31:0] REG2;
reg [ 4:0] rd;
reg [31:0] pc; 				
reg [ 4:0] reading_data; 		
reg [31:0] branch_dest;
integer temp;
wire [31:0] imm;
SetImm s(
	.instr_type(instr_out[6:0]),
	.instr(instr_out),
	.imm(imm)
);

always@(posedge clk)
begin
	if(rst) begin
		pc = 0;
		instr_addr = 0;
        data_write = 0;
        data_read = 0;
        REG[0] = 32'b0;
	end

	pc = pc + 4;
	if(data_read) begin
		REG[reading_data] = data_out;
	end
	REG[0] = 32'b0;
	REG1 = REG[instr_out[19:15]];  // For using in the right side of equation.
	REG2 = REG[instr_out[24:20]];  // For using in the right side of equation.
	rd = instr_out[11:7];
	data_read = 0;
	data_write = 0;	

	if(instr_out[6:0] == 7'b0110011) begin
		case(instr_out[14:12])
			3'b000: begin
				if(instr_out[30] == 1'b0) begin
					REG[rd] = $signed(REG1) + $signed(REG2); 
				end
				else begin
					REG[rd] = $signed(REG1) - $signed(REG2);
				end
			end
			3'b001: REG[rd] = REG1 << REG2[4:0];
			3'b010: REG[rd] = $signed(REG1) < $signed(REG2) ? 32'b1 : 32'b0;
			3'b011: REG[rd] = REG1 < REG2 ? 32'b1 : 32'b0;
			3'b100: REG[rd] = REG1 ^ REG2;
			3'b101: begin
				if(instr_out[30] == 1'b0) begin
					REG[rd] = REG1 >> REG2[4:0];
				end
				else begin
					REG[rd] = $signed(REG1) >>> REG2[4:0];
				end
			end
			3'b110: REG[instr_out[11:7]] = REG1 | REG2;
			3'b111: REG[rd] = REG1 & REG2;
			default: begin	end
		endcase
	end
	else if(instr_out[6:0] == 7'b0010011) begin
		case(instr_out[14:12])
			3'b000: REG[rd] = $signed(REG1) + $signed(imm);
			3'b001: REG[rd] = REG1 << instr_out[24:20];
			3'b010: REG[rd] = $signed(REG1) < $signed(imm) ? 32'b1 : 32'b0;
			3'b011: REG[rd] = REG1 < imm ? 32'b1 : 32'b0;
			3'b100: REG[rd] = REG1 ^ imm;
			3'b101: begin
				if(instr_out[30] == 0) begin
					REG[rd] = REG1 >> instr_out[24:20];
				end
				else begin
					REG[rd] = $signed(REG1) >>> instr_out[24:20];
				end
			end
			3'b110: REG[rd] = REG1 | imm;
			3'b111: REG[rd] = REG1 & imm;
			default: begin	end
		endcase
	end
	else if(instr_out[6:0] == 7'b1100111) begin
		REG[rd] = pc;
		pc = $signed(imm) + $signed(REG1);
	end
	else if (instr_out[6:0] == 7'b1100011) begin
		branch_dest = instr_addr + $signed(imm);
		case(instr_out[14:12])
			3'b000: pc = (REG1 == REG2 ? branch_dest : pc);
			3'b001: pc = (REG1 != REG2 ? branch_dest : pc);
			3'b100: pc = ($signed(REG1) < $signed(REG2) ? branch_dest : pc);
			3'b101: pc = ($signed(REG1) >= $signed(REG2) ? branch_dest : pc);
			3'b110: pc = (REG1 < REG2 ? branch_dest : pc);
			3'b111: pc = (REG1 >= REG2 ? branch_dest : pc);
		default: begin  end
		endcase
	end
	else if (instr_out[6:0] == 7'b1101111) begin
		REG[rd] = pc;
		pc = $signed(instr_addr) + $signed(imm);
	end
	else if (instr_out[6:0] == 7'b0110111) begin
		REG[rd] = imm;
	end
	else if (instr_out[6:0] == 7'b0010111) begin
		REG[rd] = $signed(instr_addr)  + $signed(imm);
	end
	else if (instr_out[6:0] == 7'b0000011) begin
		data_addr = $signed(REG1) + $signed(imm);
		data_read = 1'b1;
		reading_data = rd;
	end
	else if (instr_out[6:0] == 7'b0100011) begin
		data_write = 1'b1;
		data_in = REG2;
		data_addr = $signed(REG1) + $signed(imm);
	end

	instr_addr = pc;
end
endmodule