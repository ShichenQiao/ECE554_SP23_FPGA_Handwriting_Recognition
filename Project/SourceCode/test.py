import os
import sys
import fileinput
# file = open('instr_mem.v', 'r+')
test_num = 20
for i in range(test_num):
    cmd = "vsim -c work.cpu_tb -do 'run -all'"
    os.system(cmd)
    #wait?
    for line in fileinput.input("instr_mem.v", inplace=True):
        line = line.replace("test"+str(i)+".hex", "test"+str(i+1)+".hex")
        sys.stdout.write(line)