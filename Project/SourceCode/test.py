import os
import sys
import fileinput
import copy
arg_n = len(sys.argv)
if(arg_n >= 3):
    print("Error! Test script usage: 'python test.py' or 'python test.py <test_file>' or 'python test.py clean'")
elif(arg_n == 2):
    if(sys.argv[1] == "clean"):
        base_path = './test'
        file_ls = [f for f in os.listdir(base_path) if os.path.isfile(os.path.join(base_path, f))]
        filtered_file_ls = []
        for i in file_ls:
            if i.endswith('.hex'):
                filtered_file_ls.append(i)
        os.chdir('test')
        test_num = len(filtered_file_ls)
        for i in range(test_num):
            cmd = "rm "+filtered_file_ls[i]+" -f"
            os.system(cmd)
    elif(sys.argv[1] == "help"):
        print()
        print("test.py Usage:")
        print("1. Running 'python test.py' will check all .asm files in the test folder, run the assembler and simulator for all of them.")
        print("If all test passes, then an message 'All tests passed will be printed'.")
        print("If a test fails, then an message about which file failed will display, and test.output will contain the simulation detail.")
        print()
        print("2. Running 'python test.py <test_file>' will file check that the file is an asm file, then it will run the assembler and simulator for this file")
        print("A message will show whether the test passes or not. If the test fails, test.output will contain the simulation detail.")
        print()
        print("3. Running 'python test.py clean' will simply remove all .hex files in the test folder.")
        print()
        print("4. Running 'python test.py help' will display this message, as you already found out.")
    else:
        if(sys.argv[1][-4:] != ".asm"):
            print("Error! Test script only takes in .asm files as test file input. To test all file, no file names should be given")
        else:
            cmd = "vlog -timescale 1ns/1ps cpu_tb.sv"
            os.system(cmd)
            testFile = sys.argv[1][:-4]
            os.chdir('test')
            cmd = "rm "+testFile+".hex -f"
            os.system(cmd)
            cmd = "perl asmbl_32.pl "+testFile+".asm > "+testFile+".hex"
            os.system(cmd)
            os.chdir('../')
            cmd = "vlog -work work -vopt -stats=none *.v *.sv"
            os.system(cmd)
            cmd = "vlog -timescale 1ns/1ps cpu_tb.sv"
            os.system(cmd)
            with open('instr_mem.v','r') as file:
                init_instrmem = file.read()
            with open('instr_mem.v','r') as file:
                instrmem = file.read()
            first_index = instrmem.index("\"")
            hex_len = instrmem[first_index+1:].index("\"")
            new_instrmem = instrmem.replace(instrmem[first_index+1:first_index+hex_len+1], ".//test//"+testFile+".hex")
            cmd = "rm instr_mem.v -f"
            os.system(cmd)
            write_file = open('instr_mem.v', 'w')
            write_file.write(new_instrmem)
            write_file.close()
            cmd = "vlog -work work -vopt -stats=none instr_mem.v"
            os.system(cmd)
            cmd = "vsim -c work.cpu_tb -do 'run -all' > test.output"
            os.system(cmd)
            with open('test.output','r') as file:
                outputString = file.read()
            if("tests passed!" in outputString):
                print("Test passed!")
                cmd = "rm test.output -f"
                os.system(cmd)
            else:
                print("Test failed, check test.output for more detail.")
            cmd = "rm instr_mem.v -f"
            os.system(cmd)
            write_file = open('instr_mem.v', 'w')
            write_file.write(init_instrmem)
            write_file.close()
else:
    # read in total file number
    test_pass = True
    base_path = './test'
    file_ls = [f for f in os.listdir(base_path) if os.path.isfile(os.path.join(base_path, f))]
    filtered_file_ls = []
    for i in file_ls:
        if i.endswith('.asm'):
            filtered_file_ls.append(i[:-4])
    os.chdir('test')
    test_num = len(filtered_file_ls)
    # parse all the asm files in test folder
    for i in range(test_num):
        cmd = "rm "+filtered_file_ls[i]+".hex -f"
        os.system(cmd)
        cmd = "perl asmbl_32.pl "+filtered_file_ls[i]+".asm > "+filtered_file_ls[i]+".hex"
        os.system(cmd)
    # back to source code folder
    os.chdir('../')
    # compile all files
    cmd = "vlog -work work -vopt -stats=none *.v *.sv"
    os.system(cmd)
    cmd = "vlog -timescale 1ns/1ps cpu_tb.sv"
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
        new_instrmem = instrmem.replace(instrmem[first_index+1:first_index+hex_len+1], ".//test//"+filtered_file_ls[i]+".hex")
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
            print("Test failed at " + filtered_file_ls[i] + ".hex, please check your code/test. Result is in test.output")
            test_pass = False
            break
    if(test_pass):
        print("All tests passes!!")
    cmd = "rm instr_mem.v -f"
    os.system(cmd)
    write_file = open('instr_mem.v', 'w')
    write_file.write(init_instrmem)
    write_file.close()
        
        
        
        
        
        