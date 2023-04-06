import os
import sys
import fileinput
import copy
arg_n = len(sys.argv)
if(arg_n < 2):
    print("Error! Test script usage: 'python3 test.py <num_of_tests>'")
else:
    # read in total file number
    test_pass = True
    test_num = int(sys.argv[1])
    os.chdir('test')
    cmd = "pwd"
    os.system(cmd)
    # parse all the asm files in test folder
    for i in range(test_num):
        cmd = "rm test"+str(i)+".hex -f"
        os.system(cmd)
        cmd = "perl asmbl_32.pl test"+str(i)+".asm > test"+str(i)+".hex"
        os.system(cmd)
    # back to source code folder
    os.chdir('../')
    # compile all files
    cmd = "vlog -work work -vopt -stats=none *.v *.sv"
    os.system(cmd)
    # save the initial instr_mem.v information to restore later
    with open('instr_mem.v','r') as file:
        init_instrmem = file.read()
    for i in range(test_num):
        # change intra_mem.v to containing current hex test file
        with open('instr_mem.v','r') as file:
            instrmem = file.read()
        first_index = instrmem.index("\"")
        hex_len = instrmem[first_index+1:].index("\"")
        new_instrmem = instrmem.replace(instrmem[first_index+1:first_index+hex_len+1], ".//test//test"+str(i)+".hex")
        # remove instr_mem.v and re-write it
        cmd = "rm instr_mem.v -f"
        os.system(cmd)
        write_file = open('instr_mem.v', 'w')
        write_file.write(new_instrmem)
        write_file.close()
        # compile new instr_mem.v file
        cmd = "vlog -work work -vopt -stats=none instr_mem.v"
        os.system(cmd)
        # run simulation
        cmd = "vsim -c work.cpu_tb -do 'run -all' > test.output"
        os.system(cmd)
        # check output, find out if the test passed or not
        with open('test.output','r') as file:
            outputString = file.read()
        if("tests passed!" in outputString):
            cmd = "rm test.output -f"
            os.system(cmd)
        else:
            print("Test failed at test" + str(i) + ".hex, please check your code/test. Result is in test.output")
            test_pass = False
            break
    if(test_pass):
        print("All tests passes!!")
    cmd = "rm instr_mem.v -f"
    os.system(cmd)
    write_file = open('instr_mem.v', 'w')
    write_file.write(init_instrmem)
    write_file.close()
        
        
        
        
        
        