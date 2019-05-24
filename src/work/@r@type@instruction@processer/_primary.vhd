library verilog;
use verilog.vl_types.all;
entity RTypeInstructionProcesser is
    port(
        funct7          : in     vl_logic_vector(6 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        REG_1           : in     vl_logic_vector(31 downto 0);
        REG_2           : in     vl_logic_vector(31 downto 0);
        REG_F           : out    vl_logic_vector(31 downto 0)
    );
end RTypeInstructionProcesser;
