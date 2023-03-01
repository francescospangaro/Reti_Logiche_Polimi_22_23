import argparse
from math import floor
from pathlib import Path
from random import seed as seed_rnd, randrange, choice

parser = argparse.ArgumentParser(
    prog="Test bench generator",
    description="Generates random tests with a certain number of iterations"
)

# Generate default seed, copied from the std lib
try:
    from os import urandom
    seed = int.from_bytes(urandom(2500), 'big')
except NotImplementedError:
    import time
    seed = int(time.time() * 256)

parser.add_argument('testbench_name')
parser.add_argument('-s', '--seed', metavar="N", help="Sets the random seed used to generate the testbench.",
                    type=int, default=seed)
parser.add_argument('-i', '--iterations', metavar="N", help="Sets the number of iterations, random if left empty.",
                    type=int, default=10)
parser.add_argument('-z', '--zeros', action='store_true',
                    help="If flagged forces a testcase with 0 as address (start = 2 clock cycles)")
parser.add_argument('-a', '--full_address', action='store_true',
                    help="If flagged forces a testcase with 1 as address (start = 18 clock cycles)")
parser.add_argument('-r', '--multiple_resets', help="Probability that a reset will be inserted during processing",
                    type=float, default=0)
parser.add_argument('-m', '--use_example_memory', action='store_true',
                    help="If flagged uses the memory provided in the example testbench")

args = parser.parse_args()

provided_mem_data = {
    0: 20,
    1: 162,
    2: 75,
    3: 175,
    6: 88,
    57: 18,
    985: 456,
    721: 98,
    420: 420,
    65535: 400,
    1821: 697,
    1312: 985,
    7765: 894,
    214: 59,
    9: 654,
    3059: 6,
    69: 69,
}

bits_to_channel_names = {
    "00": "tb_z0",
    "01": "tb_z1",
    "10": "tb_z2",
    "11": "tb_z3",
}


def compose_memory_data(mem_content):
    ram_decl = []
    for key, val in mem_content.items():
        ram_decl.append(f'{key} => STD_LOGIC_VECTOR(to_unsigned({val}, 8)),')
    return "\n                                ".join(ram_decl) + '\n'


def decimal_to_binary(decimal):
    bit_number = "{0:b}".format(decimal)
    return "".join(["0" for _ in range(2 - len(bit_number))]) + bit_number


def get_random_address():
    if args.use_example_memory:
        return choice(list(provided_mem_data.keys()))
    return randrange(65535)


def get_random_mem_value():
    return randrange(65535)  # TODO: 8 bits, should be max 255 but the provided tb uses like 800 wutda


def generate_channel():
    return f"{randrange(2)}{randrange(2)}"


def generate_random_rst_string():
    return "".join(["0" for _ in range(randrange(10))] +
                   ["1" for _ in range(randrange(1, 10))] +
                   ["0" for _ in range(2, randrange(5, 10))])


def generate_bit_string(length, val):
    return "".join([val for _ in range(length)])


def compose_scenarios_and_assertions(num_of_iterations):
    seed_rnd(seed)
    
    outputs = {
        "tb_z0": "0",
        "tb_z1": "0",
        "tb_z2": "0",
        "tb_z3": "0",
    }

    mem_data = {}
    if args.use_example_memory:
        mem_data = provided_mem_data

    rst_string = generate_random_rst_string()
    zero_rst_string = generate_bit_string(len(rst_string), "0")
    rst = f"{rst_string}"
    start = f"{zero_rst_string}"
    w = f"{zero_rst_string}"

    assertions = ""

    random_cycle = randrange(num_of_iterations)
    wait_for_start = 1
    for i in range(num_of_iterations):
        random_address = get_random_address()

        if i == 0 and args.full_address:
            random_address = 65535

        if i == random_cycle and args.zeros:
            random_address = 0

        random_address_binary = decimal_to_binary(random_address).lstrip("0")
        channel = generate_channel()

        if not args.use_example_memory and random_address not in mem_data:
            mem_data[random_address] = get_random_mem_value()
        outputs[bits_to_channel_names[channel]] = mem_data[random_address]

        rst_idx = -1
        # Last iteration can't be a rst or the testbench triggers the watchdog
        # cause it ends with a WAIT UNTIL tb_rst = '0';
        if i != num_of_iterations and args.multiple_resets > 0:
            start_signal_len = len(random_address_binary) + 22
            rst_idx = randrange(floor(start_signal_len / args.multiple_resets))

        rst_in_address_bits = (2 <= rst_idx < len(random_address_binary) + 2)
        rst_in_computation_bits = (len(random_address_binary) + 2 <= rst_idx < (len(random_address_binary) + 22))
                
        if rst_idx == 0: # reset at first bit
            start += "1"
            rst += "1"
            w += channel[0]
        elif rst_idx == 1: # reset at second bit
            start += "11"
            rst += "01"
            w += channel
        elif rst_in_address_bits:
            # Cut all signals to the selected rst index
            start += "11" + generate_bit_string(rst_idx - 1, "1")
            rst += "00" + generate_bit_string(rst_idx - 2, "0") + "1"
            w += channel + random_address_binary[:rst_idx - 1]
        else:
            # Generate address bits normally
            start += "11" + generate_bit_string(len(random_address_binary), "1")
            rst += "00" + generate_bit_string(len(random_address_binary), "0")
            w += channel + random_address_binary
            
            if rst_in_computation_bits:
                start += generate_bit_string(rst_idx - len(random_address_binary) - 1, "0")
                rst += generate_bit_string(rst_idx - len(random_address_binary) - 2, "0") + "1"
                w += generate_bit_string(rst_idx - len(random_address_binary) - 1, "0")
            else: # No reset
                start += generate_bit_string(20, "0")
                rst += generate_bit_string(20, "0")
                w += generate_bit_string(20, "0")

        did_add_rst = (rst[-1] == "1")
        zero_before_rst = (rst[-2] == "0")
        if not did_add_rst:
            # Composing assertion for this iteration
            assertions += compose_assertion(outputs, wait_for_start)
            wait_for_start = 1
        else:
            zeros_after_rst = randrange(5)
            start += generate_bit_string(zeros_after_rst, "0")
            rst += generate_bit_string(zeros_after_rst, "0")
            w += generate_bit_string(zeros_after_rst, "0")
            if zero_before_rst:
                # At 3rd cycle we get output, so if we are after the 4th we need to check correctness
                cycles_since_start_signal = len(start) - 1 - zeros_after_rst - start.rfind("1")
                if cycles_since_start_signal > 4:
                    assertions += compose_assertion(outputs, wait_for_start)
                    wait_for_start = 1
                    assertions += compose_reset_assertion(False)
                else:
                    assertions += compose_reset_assertion(wait_for_start and rst_idx != 0)
                    wait_for_start = 1
                wait_for_start = 0 if zeros_after_rst == 0 else wait_for_start
            
            outputs = {
                "tb_z0": "0",
                "tb_z1": "0",
                "tb_z2": "0",
                "tb_z3": "0",
            }

    return {
        "scenario_start": start,
        "scenario_rst": rst,
        "scenario_w": w,
        "mem_data": mem_data,
        "assertions": assertions,
    }


def compose_assertion(outputs, wait_for_start):
    output_assertion_strings = f"\
        ASSERT tb_z0 = std_logic_vector(to_unsigned({outputs['tb_z0']}, 8))  REPORT \"TEST FALLITO (Z0 ---) found \" & integer'image(to_integer(unsigned(tb_z0))) & \" expected \" & integer'image(to_integer(to_unsigned({outputs['tb_z0']}, 8))) severity failure;\n\
        ASSERT tb_z1 = std_logic_vector(to_unsigned({outputs['tb_z1']}, 8))  REPORT \"TEST FALLITO (Z1 ---) found \" & integer'image(to_integer(unsigned(tb_z1))) & \" expected \" & integer'image(to_integer(to_unsigned({outputs['tb_z1']}, 8)))  severity failure;\n\
        ASSERT tb_z2 = std_logic_vector(to_unsigned({outputs['tb_z2']}, 8))  REPORT \"TEST FALLITO (Z2 ---) found \" & integer'image(to_integer(unsigned(tb_z2))) & \" expected \" & integer'image(to_integer(to_unsigned({outputs['tb_z2']}, 8)))  severity failure;\n\
        ASSERT tb_z3 = std_logic_vector(to_unsigned({outputs['tb_z3']}, 8))  REPORT \"TEST FALLITO (Z3 ---) found \" & integer'image(to_integer(unsigned(tb_z3))) & \" expected \" & integer'image(to_integer(to_unsigned({outputs['tb_z3']}, 8)))  severity failure;"
    ris = f"\n"
    if wait_for_start:
        ris += f"\n\
        WAIT UNTIL tb_start = '1';\n\
        ASSERT tb_z0 = \"00000000\" REPORT \"TEST FALLITO (poststart Z0 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z0))) severity failure; \n\
        ASSERT tb_z1 = \"00000000\" REPORT \"TEST FALLITO (poststart Z1 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z1))) severity failure; \n\
        ASSERT tb_z2 = \"00000000\" REPORT \"TEST FALLITO (poststart Z2 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z2))) severity failure; \n\
        ASSERT tb_z3 = \"00000000\" REPORT \"TEST FALLITO (poststart Z3 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z3))) severity failure;"

    ris += f"\n\
        WAIT UNTIL tb_done = '1';\n\
        --WAIT UNTIL rising_edge(tb_clk);\n\
        WAIT FOR CLOCK_PERIOD/2;\n\
{output_assertion_strings}\n\
        WAIT UNTIL tb_done = '0';\n\
        ASSERT tb_z0 = \"00000000\" REPORT \"TEST FALLITO (postdone Z0 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z0))) severity failure; \n\
        ASSERT tb_z1 = \"00000000\" REPORT \"TEST FALLITO (postdone Z1 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z1))) severity failure; \n\
        ASSERT tb_z2 = \"00000000\" REPORT \"TEST FALLITO (postdone Z2 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z2))) severity failure; \n\
        ASSERT tb_z3 = \"00000000\" REPORT \"TEST FALLITO (postdone Z3 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z3))) severity failure;"
    return ris


def compose_reset_assertion(wait_for_start):
    ris = ""
    if wait_for_start:
        ris = f"\n\
        WAIT UNTIL tb_start = '1';\n\
        ASSERT tb_z0 = \"00000000\" REPORT \"TEST FALLITO (poststart Z0 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z0))) severity failure; \n\
        ASSERT tb_z1 = \"00000000\" REPORT \"TEST FALLITO (poststart Z1 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z1))) severity failure; \n\
        ASSERT tb_z2 = \"00000000\" REPORT \"TEST FALLITO (poststart Z2 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z2))) severity failure; \n\
        ASSERT tb_z3 = \"00000000\" REPORT \"TEST FALLITO (poststart Z3 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z3))) severity failure;"

    ris += f"\n\
        WAIT UNTIL tb_rst = '1';\n\
        WAIT FOR CLOCK_PERIOD/2;\n\
        ASSERT tb_z0 = \"00000000\" REPORT \"TEST FALLITO (postreset Z0 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z0))) severity failure; \n\
        ASSERT tb_z1 = \"00000000\" REPORT \"TEST FALLITO (postreset Z1 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z1))) severity failure; \n\
        ASSERT tb_z2 = \"00000000\" REPORT \"TEST FALLITO (postreset Z2 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z2))) severity failure; \n\
        ASSERT tb_z3 = \"00000000\" REPORT \"TEST FALLITO (postreset Z3 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z3))) severity failure; \n\
        WAIT UNTIL tb_rst = '0';\n\
        ASSERT tb_z0 = \"00000000\" REPORT \"TEST FALLITO (postreset Z0 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z0))) severity failure; \n\
        ASSERT tb_z1 = \"00000000\" REPORT \"TEST FALLITO (postreset Z1 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z1))) severity failure; \n\
        ASSERT tb_z2 = \"00000000\" REPORT \"TEST FALLITO (postreset Z2 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z2))) severity failure; \n\
        ASSERT tb_z3 = \"00000000\" REPORT \"TEST FALLITO (postreset Z3 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z3))) severity failure;"
    return ris


data = compose_scenarios_and_assertions(args.iterations)

generated_cmd = "-- python3 generate_vivado_testbench.py \\\n";
generated_cmd += f"--    --seed {args.seed} \\\n"
generated_cmd += f"--    --iterations {args.iterations} \\\n"
generated_cmd += f"--    --zeros \\\n" if args.zeros else ''
generated_cmd += f"--    --full_address \\\n" if args.full_address else ''
generated_cmd += f"--    --multiple_resets {args.multiple_resets} \\\n"
generated_cmd += f"--    --use_example_memory \\\n" if args.use_example_memory else ''
generated_cmd += f"--    args.testbench_name \n"

test_bench_script = f"\
-- TB EXAMPLE PFRL 2022-2023\n\
\n\
-- Generated using: \n\
{generated_cmd}\
\n\
--VUNIT%% library vunit_lib; %%-- \n\
--VUNIT%% context vunit_lib.vunit_context; %%-- \n\
\n\
LIBRARY ieee;\n\
USE ieee.std_logic_1164.ALL;\n\
USE ieee.numeric_std.ALL;\n\
USE ieee.std_logic_unsigned.ALL;\n\
USE std.textio.ALL;\n\
\n\
ENTITY {args.testbench_name} IS\n\
    --VUNIT%% generic(runner_cfg: string := runner_cfg_default); %%-- \n\
END {args.testbench_name};\n\
\n\
ARCHITECTURE projecttb OF {args.testbench_name} IS\n\
    CONSTANT CLOCK_PERIOD : TIME := 100 ns;\n\
    SIGNAL tb_done : STD_LOGIC;\n\
    SIGNAL mem_address : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');\n\
    SIGNAL tb_rst : STD_LOGIC := '0';\n\
    SIGNAL tb_start : STD_LOGIC := '0';\n\
    SIGNAL tb_clk : STD_LOGIC := '0';\n\
    SIGNAL mem_o_data, mem_i_data : STD_LOGIC_VECTOR (7 DOWNTO 0);\n\
    SIGNAL enable_wire : STD_LOGIC;\n\
    SIGNAL mem_we : STD_LOGIC;\n\
    SIGNAL tb_z0, tb_z1, tb_z2, tb_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0);\n\
    SIGNAL tb_w : STD_LOGIC;\n\
\n\
    CONSTANT SCENARIOLENGTH : INTEGER := {len(data['scenario_rst'])};\n\
    SIGNAL scenario_rst : unsigned(0 TO SCENARIOLENGTH - 1)     := \"{data['scenario_rst']}\";\n\
    SIGNAL scenario_start : unsigned(0 TO SCENARIOLENGTH - 1)   := \"{data['scenario_start']}\";\n\
    SIGNAL scenario_w : unsigned(0 TO SCENARIOLENGTH - 1)       := \"{data['scenario_w']}\";\n\
    -- Channel 2 -> MEM[1] -> 162\n\
    -- Channel 1 -> MEM[2] -> 75\n\
\n\
    TYPE ram_type IS ARRAY (65535 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);\n\
    SIGNAL RAM : ram_type := (  {compose_memory_data(data['mem_data'])}\
                                OTHERS => \"00000000\"-- (OTHERS => '0')\n\
                            );\n\
\n\
    COMPONENT project_reti_logiche IS\n\
        PORT (\n\
            i_clk : IN STD_LOGIC;\n\
            i_rst : IN STD_LOGIC;\n\
            i_start : IN STD_LOGIC;\n\
            i_w : IN STD_LOGIC;\n\
\n\
            o_z0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);\n\
            o_z1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);\n\
            o_z2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);\n\
            o_z3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);\n\
            o_done : OUT STD_LOGIC;\n\
\n\
            o_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);\n\
            i_mem_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);\n\
            o_mem_we : OUT STD_LOGIC;\n\
            o_mem_en : OUT STD_LOGIC\n\
        );\n\
    END COMPONENT project_reti_logiche;\n\
\n\
BEGIN\n\
    UUT : project_reti_logiche\n\
    PORT MAP(\n\
        i_clk => tb_clk,\n\
        i_start => tb_start,\n\
        i_rst => tb_rst,\n\
        i_w => tb_w,\n\
\n\
        o_z0 => tb_z0,\n\
        o_z1 => tb_z1,\n\
        o_z2 => tb_z2,\n\
        o_z3 => tb_z3,\n\
        o_done => tb_done,\n\
\n\
        o_mem_addr => mem_address,\n\
        o_mem_en => enable_wire,\n\
        o_mem_we => mem_we,\n\
        i_mem_data => mem_o_data\n\
    );\n\
\n\
\n\
    -- Process for the clock generation\n\
    CLK_GEN : PROCESS IS\n\
    BEGIN\n\
        WAIT FOR CLOCK_PERIOD/2;\n\
        tb_clk <= NOT tb_clk;\n\
    END PROCESS CLK_GEN;\n\
\n\
\n\
    -- Process related to the memory\n\
    MEM : PROCESS (tb_clk)\n\
    BEGIN\n\
        IF tb_clk'event AND tb_clk = '1' THEN\n\
            IF enable_wire = '1' THEN\n\
                IF mem_we = '1' THEN\n\
                    RAM(conv_integer(mem_address)) <= mem_i_data;\n\
                    mem_o_data <= mem_i_data AFTER 1 ns;\n\
                ELSE\n\
                    mem_o_data <= RAM(conv_integer(mem_address)) AFTER 1 ns; \n\
                END IF;\n\
            END IF;\n\
        END IF;\n\
    END PROCESS;\n\
\n\
    -- This process provides the correct scenario on the signal controlled by the TB\n\
    createScenario : PROCESS (tb_clk)\n\
    BEGIN\n\
        IF tb_clk'event AND tb_clk = '0' THEN\n\
            tb_rst <= scenario_rst(0);\n\
            tb_w <= scenario_w(0);\n\
            tb_start <= scenario_start(0);\n\
            scenario_rst <= scenario_rst(1 TO SCENARIOLENGTH - 1) & '0';\n\
            scenario_w <= scenario_w(1 TO SCENARIOLENGTH - 1) & '0';\n\
            scenario_start <= scenario_start(1 TO SCENARIOLENGTH - 1) & '0';\n\
        END IF;\n\
    END PROCESS;\n\
\n\
    -- Process without sensitivity list designed to test the actual component.\n\
    testRoutine : PROCESS IS\n\
    BEGIN\n\
        --VUNIT%% test_runner_setup(runner, runner_cfg); %%-- \n\
\n\
        mem_i_data <= \"00000000\";\n\
        -- wait for 10000 ns;\n\
        WAIT UNTIL tb_rst = '1';\n\
        WAIT UNTIL tb_rst = '0';\n\
        ASSERT tb_z0 = \"00000000\" REPORT \"TEST FALLITO (postreset Z0 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z0))) severity failure; \n\
        ASSERT tb_z1 = \"00000000\" REPORT \"TEST FALLITO (postreset Z1 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z1))) severity failure; \n\
        ASSERT tb_z2 = \"00000000\" REPORT \"TEST FALLITO (postreset Z2 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z2))) severity failure; \n\
        ASSERT tb_z3 = \"00000000\" REPORT \"TEST FALLITO (postreset Z3 != 0 ) found \" & integer'image(to_integer(unsigned(tb_z3))) severity failure; \n\
        {data['assertions']} \
\n\
        --VIVADO-START%% \n\
        ASSERT false REPORT \"Simulation Ended! TEST PASSATO (EXAMPLE)\" SEVERITY failure; \n\
        --VIVADO-END%% \n\
\n\
        --VUNIT%% test_runner_cleanup(runner); %%-- \n\
    END PROCESS testRoutine;\n\
\n\
    --VUNIT%% test_runner_watchdog(runner, CLOCK_PERIOD * SCENARIOLENGTH); %%-- \n\
\n\
END projecttb;"

i = 1
while Path("./serial_to_parallel_ram_dereference.srcs/sim_" + str(i)).exists():
    i += 1

file = Path(f"./serial_to_parallel_ram_dereference.srcs/sim_{str(i)}/new/{args.testbench_name}.vhd")

file.parent.mkdir(parents=True, exist_ok=True)
with open(file, "w+") as f:
    f.writelines(test_bench_script)

print(f"Generated test bench: {file}")
