// Please include verilog file if you write module in other file
`include "RTypeInstructionProcesser.v";
`include "ITypeInstructionProcesser.v";
`include "BTypeInstructionProcesser.v";

module CPU
(
    input         		clk,		//
    input				rst,		//
    output reg 		   	instr_read, // Signal to read new instruction.
    output reg 	[31:0] 	instr_addr,	// Addres of instuction to read.
    input 		[31:0] 	instr_out,	// Instruction recevied.
    output reg     		data_read,	// Signal to read data in DM
    output reg     		data_write, // Signal to write data in DM
    output reg 	[31:0]	data_addr,  // Addres in DM to be read / written
    output reg  [31:0]	data_in,	// Data to send to DM
    input  		[31:0]	data_out	// Data recieved from DM
);

reg [31:0] REGISTER [31:0];
reg readData;
reg getData;
integer temp;

initial
begin
	REGISTER[0] <= 32'd0;
	instr_addr <= 8'h00000000;
	instr_read = 1'b0;
	readData <= 1'b0;
	getData <= 1'b0;
end
//Reset call
always @ (posedge rst)
begin
	$display("================================\nI am reseting.\nREG[0] is now %b.", REGISTER[0]);
	REGISTER[0] <= 32'd0;
	instr_addr <= 8'h00000000;
	instr_read = 1'b0;
	readData <= 1'b0;
	getData <= 1'b0;
end

// Read 1 new instruction every tick
always @ (posedge clk)
begin
	instr_read <= !instr_read;
end
always @ (negedge clk)
begin
	instr_read <= !instr_read;
end

// Pre-processing after receving new instruction (Adding instr_addr by 4 in here.)
//	1. Get The Opcode [R]0110011 / [I]0000011 / [I]0010011 / [I]1100111 / [S]0100011 / [B]1100011 / [U]0010111 / [U]0110111 / [J]1101111
//
wire [31:0] outputR;
RTypeInstructionProcesser R(
				.funct7(instr_out[31:25]),
				.funct3(instr_out[14:12]),
				.REG_1(REGISTER[instr_out[19:15]]),
				.REG_2(REGISTER[instr_out[24:20]]),
				.REG_F(outputR)
);

wire [31:0] outputI;
ITypeInstructionProcesser I(
				.funct3(instr_out[14:12]),
				.imm(instr_out[31:20]),
				.REG(REGISTER[instr_out[19:15]]),
				.REG_F(outputI)
);

wire [31:0] outputB;
BTypeInstructionProcesser B(
				.PC(instr_addr),
				.imm({instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0}),
				.funct3(instr_out[14:12]),
				.REG_1(REGISTER[instr_out[19:15]]),
				.REG_2(REGISTER[instr_out[24:20]]),
				.NewPC(outputB)
);


always @ (instr_out)
begin
	$display("When the instr_addr is %h, the instr_out is %h", instr_addr, instr_out);
	instr_addr <= instr_addr + 4;

	case(instr_out[6:0])
		7'b0110011: // R-Type
		begin
			$display("R-Type case.");
			REGISTER[instr_out[11:7]] <= outputR;
		end
		7'b0000011: // LW
		begin
			$display("LW case.");
			readData = 1'b1;
		end
		7'b0010011:
		begin
			$display("I-Type case.");
			REGISTER[instr_out[11:7]] <= outputI;
		end
		7'b1100111: // JALR
		begin
			$display("JALR case.");
			REGISTER[instr_out[11:7]] <= instr_addr + 4;
			instr_addr <= instr_out[31:20] + REGISTER[instr_out[19:15]];
			instr_addr[0] <= 1'b0;
		end
		7'b0100011: // SW
		begin
			$display("SW case.");
			getData = 1'b1;
		end
		7'b1100011:
		begin
			$display("B-Type case.");
			instr_addr <= outputB;
		end
		7'b0010111: // AUIPC
		begin
			$display("AUIPC case.");
			REGISTER[instr_out[11:7]] <= instr_addr + {instr_out[31:12], 12'b000000000000};
		end
		7'b0110111: // LUI
		begin
			$display("LUI case.");
			REGISTER[instr_out[11:7]] <= {instr_out[31:12], 12'b000000000000};
		end
		7'b1101111:	// JAL
		begin
			$display("JAL case.");
			REGISTER[instr_out[11:7]] <= instr_addr + 32'd4;
			instr_addr <= instr_addr + {instr_out[31], instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0};
		end
		default:
		begin end
	endcase
end

always @ (posedge readData) // block for LW
begin
	data_addr <= REGISTER[instr_out[19:15]] + instr_out[31:20];
	data_read <= 1'b1;
end

always @ (data_out)
begin
	if(readData)
	begin
		REGISTER[instr_out[11:7]] <= data_out;
	end
	data_read <= 1'b0;
	readData <= 1'b0;
end

always @ (posedge getData)
begin
	$display("I am saving data.");
	data_addr <= REGISTER[instr_out[19:15]] + {instr_out[31:25], instr_out[11:7]};
	data_write <= 1'b1;
	data_in <= REGISTER[instr_out[24:20]];
	getData <= 1'b0;
end

endmodule