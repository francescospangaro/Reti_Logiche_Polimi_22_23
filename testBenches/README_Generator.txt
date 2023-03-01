# TEST BENCH GENERATOR FOR "PROGETTO DI RETI LOGICHE 2022/2023"

## DESCRIPTION
This script will generate a test bench file containing multiple iterations of the project (multiple start signals, multiple i_w, etc..)
This also has some args that can be passed to decide the number of iterations, and to force some particular tests cases in the test bench (for example having 0 as address, or having all 1 as address, adding a second reset in middle of iterations).

## USAGE
* Install python.
* Open a terminal window in the script folder.
* Run `python test_bench_generator.py -h` for infos about arguments.
* Run `python test_bench_generator.py` to run the script in default mode without args or particular tests.
* Run `python test_bench_generator.py [...args]` to run the script in default mode without args or particular tests.
* A VHD test bench file will be generated with a name `generated_test_bench_<uuid>.vhd`

## Args
```
  -h, --help            show this help message and exit
  -i N, --iterations N  Sets the number of iterations, random if left empty.
  -z, --zeros           If flagged forces a testcase with 0 as address (start = 2 clock cycles)
  -a, --full_address    If flagged forces a testcase with 1 as address (start = 18 clock cycles)
  -r, --multiple_resets If flagged forces multiple resets inside the test bench
```

#### Notes
This script has been done in half a day, so sorry for the ugly code :D
