test benches named as tb_x are the professor's made ones, no I don't know, and frankly don't care, what they do
they work, the more difficult ones work, I'm good

test bench 1 -> a random test, just to differ from the one given in class
test bench 2 -> uses multiple resets and 10 different iterations
test bench 3 -> uses a full address of all ones
test bench 4 -> uses multiple resents and 100 different iterations
test bench 5 -> uses multiple resents and 1000 different iterations


testbench "prova1" and "prova2", has been generated with the following parameters:
"prova1" :
-- Generated using: 
-- python3 generate_vivado_testbench.py \
--    --seed 755 \
--    --iterations 300 \
--    --zeros \
--    --full_address \
--    --multiple_resets 0.5 \
--    --use_example_memory \
--    args.testbench_name 

"prova2" :
-- Generated using: 
-- python3 generate_vivado_testbench.py \
--    --seed 37 \
--    --iterations 150 \
--    --zeros \
--    --full_address \
--    --multiple_resets 0.8 \
--    --use_example_memory \
--    args.testbench_name 

N.B: In order to avoid cases where a reset signal arrives before the data is ready to be read and DONE is still 0, modify row #191 of the testbench generator script, changing the number after ">", to 8 or higher.
