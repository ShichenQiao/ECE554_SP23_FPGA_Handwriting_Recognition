# bubblesort program

llb R15, 0x01
llb R14, 0x01 #used for increment
llb R1,	24
sw  R1, R15, 0
add R15, R15, R14
llb R1,	22
sw  R1, R15, 0
add R15, R15, R14
llb R1,	25
sw  R1, R15, 0
add R15, R15, R14
llb R1,	56
sw  R1, R15, 0
add R15, R15, R14
llb R1,	34
sw  R1, R15, 0
add R15, R15, R14
llb R1,	53
sw  R1, R15, 0
add R15, R15, R14
llb R1,	31
sw  R1, R15, 0
add R15, R15, R14
llb R1,	26
sw  R1, R15, 0
add R15, R15, R14
llb R1,	40
sw  R1, R15, 0
add R15, R15, R14
llb R1,	41
sw  R1, R15, 0
add R15, R15, R14
llb R1,	43
sw  R1, R15, 0
add R15, R15, R14
llb R1,	28
sw  R1, R15, 0
add R15, R15, R14
llb R1,	42
sw  R1, R15, 0
add R15, R15, R14
llb R1,	63
sw  R1, R15, 0
add R15, R15, R14
llb R1,	33
sw  R1, R15, 0
add R15, R15, R14
llb R1,	46
sw  R1, R15, 0
add R15, R15, R14
llb R1,	59
sw  R1, R15, 0
add R15, R15, R14
llb R1,	20
sw  R1, R15, 0
add R15, R15, R14
llb R1,	62
sw  R1, R15, 0
add R15, R15, R14
llb R1,	4
sw  R1, R15, 0
add R15, R15, R14
llb R1,	27
sw  R1, R15, 0
add R15, R15, R14
llb R1,	39
sw  R1, R15, 0
add R15, R15, R14
llb R1,	61
sw  R1, R15, 0
add R15, R15, R14
llb R1,	1
sw  R1, R15, 0
add R15, R15, R14
llb R1,	49
sw  R1, R15, 0
add R15, R15, R14
llb R1,	23
sw  R1, R15, 0
add R15, R15, R14
llb R1,	7
sw  R1, R15, 0
add R15, R15, R14
llb R1,	8
sw  R1, R15, 0
add R15, R15, R14
llb R1,	21
sw  R1, R15, 0
add R15, R15, R14
llb R1,	2
sw  R1, R15, 0
add R15, R15, R14
llb R1,	17
sw  R1, R15, 0
add R15, R15, R14
llb R1,	12
sw  R1, R15, 0
add R15, R15, R14
llb R1,	11
sw  R1, R15, 0
add R15, R15, R14
llb R1,	50
sw  R1, R15, 0
add R15, R15, R14
llb R1,	58
sw  R1, R15, 0
add R15, R15, R14
llb R1,	60
sw  R1, R15, 0
add R15, R15, R14
llb R1,	6
sw  R1, R15, 0
add R15, R15, R14
llb R1,	38
sw  R1, R15, 0
add R15, R15, R14
llb R1,	36
sw  R1, R15, 0
add R15, R15, R14
llb R1,	55
sw  R1, R15, 0
add R15, R15, R14
llb R1,	19
sw  R1, R15, 0
add R15, R15, R14
llb R1,	30
sw  R1, R15, 0
add R15, R15, R14
llb R1,	10
sw  R1, R15, 0
add R15, R15, R14
llb R1,	48
sw  R1, R15, 0
add R15, R15, R14
llb R1,	52
sw  R1, R15, 0
add R15, R15, R14
llb R1,	54
sw  R1, R15, 0
add R15, R15, R14
llb R1,	37
sw  R1, R15, 0
add R15, R15, R14
llb R1,	16
sw  R1, R15, 0
add R15, R15, R14
llb R1,	51
sw  R1, R15, 0
add R15, R15, R14
llb R1,	47
sw  R1, R15, 0
add R15, R15, R14
llb R1,	14
sw  R1, R15, 0
add R15, R15, R14
llb R1,	57
sw  R1, R15, 0
add R15, R15, R14
llb R1,	64
sw  R1, R15, 0
add R15, R15, R14
llb R1,	45
sw  R1, R15, 0
add R15, R15, R14
llb R1,	9
sw  R1, R15, 0
add R15, R15, R14
llb R1,	18
sw  R1, R15, 0
add R15, R15, R14
llb R1,	29
sw  R1, R15, 0
add R15, R15, R14
llb R1,	32
sw  R1, R15, 0
add R15, R15, R14
llb R1,	3
sw  R1, R15, 0
add R15, R15, R14
llb R1,	35
sw  R1, R15, 0
add R15, R15, R14
llb R1,	5
sw  R1, R15, 0
add R15, R15, R14
llb R1,	13
sw  R1, R15, 0
add R15, R15, R14
llb R1,	15
sw  R1, R15, 0
add R15, R15, R14
llb R1,	44
sw  R1, R15, 0
add R15, R15, R14

#preload some value
llb R14, -1
llb R13, 1

#R9 is the first pointer and Ra is the second
#Re is the general counter
#sort from large to small

llb R12, 63
#llb R11, 62 # loop counter
llb R7, 64


.outerLoop:
llb R9, 0x00
llb R10, 0x00
sub R8, R7, R12
add R9, R8, R9
add R10, R10, R8
add R10, R10, R13

add R12, R12, R14
sll R11, R12, 0
b eq, .hltLabel

.mainLoop:
lw R1, R9, 0
lw R2, R10, 0
sub R3, R1, R2
b lte, .exchangeLoop

.updateCounter:
add R9, R9, R13
add R10, R10, R13
add R11, R11, R14
b eq, .outerLoop
b uncond, .mainLoop

.exchangeLoop:
sw R1, R10, 0
sw R2, R9, 0
b uncond, .updateCounter

.hltLabel:
llb R15, 50
lw R1, R15, 0
lw R2, R15, 1
lw R3, R15, 2
lw R4, R15, 3
lw R5, R15, 4
lw R6, R15, 5
lw R7, R15, 6
lw R8, R15, 7
lw R9, R15, 8
lw R10, R15, 9
lw R11, R15, 10
lw R12, R15, 11
lw R13, R15, 12
lw R14, R15, 13
#lw R15, R15, 14

hlt
llb R3, 0x0
llb R3, 0x0
llb R3, 0x0
llb R3, 0x0
llb R3, 0x0
hlt