module SetImm(
	input [ 6:0]		instr_type,
	input [31:0] 		instr,
	output reg [31:0] 	imm
);

always @ (instr)
begin
	case(instr_type)
		7'b0000011, 7'b0010011, 7'b1100111: imm = $signed(instr) >>> 20; 
		7'b0100011: imm = $signed({instr[31:25], instr[11:7], 20'b0}) >>> 20;
		7'b1100011: imm = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 20'b0}) >>> 19;
		7'b0010111, 7'b0110111: imm = {instr[31:12], 12'b0};
		7'b1101111: imm = $signed({instr[31], instr[19:12], instr[20], instr[30:21], 12'b0}) >>> 11;
		default: imm = 7'b0000000;
	endcase
end

endmodule