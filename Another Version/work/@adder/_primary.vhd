library verilog;
use verilog.vl_types.all;
entity Adder is
    port(
        IN1             : in     vl_logic_vector(31 downto 0);
        IN2             : in     vl_logic_vector(31 downto 0);
        RESULT          : out    vl_logic_vector(31 downto 0)
    );
end Adder;
