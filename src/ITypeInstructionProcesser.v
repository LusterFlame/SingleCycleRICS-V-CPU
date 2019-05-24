module ITypeInstructionProcesser
(
	input [2:0] funct3,
	input [11:0] imm,
	input [31:0] REG,
	output reg [31:0] REG_F
);

integer temp;

always @ (funct3)
begin
	case (funct3)
		3'b000:
		begin
			REG_F <= $signed(REG) + $signed(imm);
		end
		3'b001:
		begin
			REG_F <= REG << imm[4:0];
		end
		3'b010:
		begin
			REG_F <= $signed(REG) < $signed(imm) ? 1'b1 : 1'b0;
		end
		3'b011:
		begin
			REG_F <= REG < {20'd0, imm} ? 1'b1 : 1'b0;
		end
		3'b100:
		begin
			if(imm[11])
			begin
				REG_F <= REG ^ {20'b11111111111111111111, imm};
			end
			else
			begin
				REG_F <= REG ^ {20'b00000000000000000000, imm};
			end
		end
		3'b101:
		begin
			REG_F <= REG >> imm[4:0];
			if(imm[10])
			begin
				for(temp = 31;temp > 31 - imm[4:0];temp = temp - 1)
				begin
					REG_F[temp] = REG[1];
				end
			end
		end
		3'b110:
		begin
			if(imm[11])
			begin
				REG_F <= REG | {20'b11111111111111111111, imm};
			end
			else
			begin
				REG_F <= REG | {20'b00000000000000000000, imm};
			end
		end
		3'b111:
		begin
			if(imm[11])
			begin
				REG_F <= REG & {20'b11111111111111111111, imm};
			end
			else
			begin
				REG_F <= REG & {20'b00000000000000000000, imm};
			end
		end
	endcase
end

endmodule