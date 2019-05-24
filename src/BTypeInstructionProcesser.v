module BTypeInstructionProcesser
(
	input [31:0] PC,
	input [12:0] imm,
	input [2:0] funct3,
	input [31:0] REG_1,
	input [31:0] REG_2,
	output reg [31:0] NewPC
);

always @ (PC)
begin
	case (funct3)
		3'b000:
		begin
			if(imm[12])
			begin
				NewPC <= REG_1 == REG_2 ? PC + {20'b11111111111111111111, imm} : PC + 32'd4;
			end
			else
			begin
				NewPC <= REG_1 == REG_2 ? PC + {20'b00000000000000000000, imm} : PC + 32'd4;
			end
		end
		3'b001:
		begin
			if(imm[12])
			begin
				NewPC <= REG_1 != REG_2 ? PC + {20'b11111111111111111111, imm} : PC + 32'd4;
			end
			else
			begin
				NewPC <= REG_1 != REG_2 ? PC + {20'b00000000000000000000, imm} : PC + 32'd4;
			end
		end
		3'b100:
		begin
			if(imm[12])
			begin
				NewPC <= $signed(REG_1) < $signed(REG_2) ? PC + {20'b11111111111111111111, imm} : PC + 32'd4;
			end
			else
			begin
				NewPC <= $signed(REG_1) < $signed(REG_2) ? PC + {20'b00000000000000000000, imm} : PC + 32'd4;
			end
		end
		3'b101:
		begin
			if(imm[12])
			begin
				NewPC <= $signed(REG_1) >= $signed(REG_2) ? PC + {20'b11111111111111111111, imm} : PC + 32'd4;
			end
			else
			begin
				NewPC <= $signed(REG_1) >= $signed(REG_2) ? PC + {20'b00000000000000000000, imm} : PC + 32'd4;
			end
		end
		3'b110:
		begin
			if(imm[12])
			begin
				NewPC <= REG_1 < REG_2 ? PC + {20'b11111111111111111111, imm} : PC + 32'd4;
			end
			else
			begin
				NewPC <= REG_1 < REG_2 ? PC + {20'b00000000000000000000, imm} : PC + 32'd4;
			end
		end
		3'b111:
		begin
			if(imm[12])
			begin
				NewPC <= REG_1 >= REG_2 ? PC + {20'b11111111111111111111, imm} : PC + 32'd4;
			end
			else
			begin
				NewPC <= REG_1 >= REG_2 ? PC + {20'b00000000000000000000, imm} : PC + 32'd4;
			end
		end
	endcase
end

endmodule