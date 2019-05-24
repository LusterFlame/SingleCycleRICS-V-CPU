module RTypeInstructionProcesser
(
	input [6:0]			funct7,
	input [2:0]			funct3,
	input [31:0]		REG_1,
	input [31:0]		REG_2,
	output reg [31:0]	REG_F
);

integer temp;

always @ (funct3)
begin
	case (funct3)
		3'b000:
		begin
			if(funct7[5])
				REG_F <= $signed(REG_1) + $signed(REG_2);
			else
				REG_F <= $signed(REG_1) + $signed(REG_2);
		end
		3'b001:
		begin
			REG_F <= REG_1 << REG_2[4:0];
		end
		3'b010:
		begin
			REG_F <= $signed(REG_2) > $signed(REG_1) ? 32'b1 : 32'b0;
		end
		3'b011:
		begin
			REG_F <= REG_2 > REG_1 ? 32'b1 : 32'b0;
		end
		3'b100:
		begin
			REG_F <= REG_1 ^ REG_2;
		end
		3'b101:
		begin
			REG_F <= REG_1 >> REG_2[4:0];
			if(funct7[5])
			begin
				for(temp = 31;temp > 31 - REG_2[4:0];temp = temp - 1)
				begin
					REG_F[temp] = REG_1[31];
				end
			end
		end
		3'b110:
		begin
			REG_F <= REG_1 | REG_2;
		end
		3'b111:
		begin
			REG_F <= REG_1 & REG_2;
		end
	endcase
end
endmodule 