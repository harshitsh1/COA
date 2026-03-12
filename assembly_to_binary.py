#!/usr/bin/env python3
"""
RISC-32 Assembler to Binary File Converter
Converts assembly code to 32-bit machine code with separators.
"""

def convert_to_binary(imm, bit_count):
    # remove the first # and convert rest of the string to int
    imm = int(imm[1:len(imm)])
    # convert imm to signed binary representation with "bit_count" bits
    if imm < 0:
        imm = (1 << bit_count) + imm
    return format(imm, f"0{bit_count}b")

Rtype_func_map = {
    "ADD": "000001",
    "SUB": "000010",
    "AND": "000011",
    "OR": "000100",
    "XOR": "000101",
    "NOR": "000110",
    "SL": "000111",
    "SRL": "001000",
    "SRA": "001001",
    "SLT": "001010",
    "SGT": "001011",
    "NOT": "001100",
    "INC": "001101",
    "DEC": "001110",
    "HAM": "001111",
    "CMOV": "000000"
}

Itype = ["ADDI", "SUBI", "ANDI", "ORI", "XORI", "NORI", "SLI", "SRLI", "SRAI", "SLTI", "SGTI", "NOTI", "INCI", "DECI", "HAMI", "LUI", "LD", "ST", "BMI", "BPL", "BZ", "MOVE"]
Itype_3_ri = ["ADDI", "SUBI", "ANDI", "ORI", "XORI", "NORI", "SLI", "SRLI", "SRAI", "SLTI", "SGTI", "MOVE"]

Itype_opcode_map = {
    "ADDI": "000001",
    "SUBI": "000010",
    "ANDI": "000011",
    "ORI": "000100",
    "XORI": "000101",
    "NORI": "000110",
    "SLI": "000111",
    "SRLI": "001000",
    "SRAI": "001001",
    "SLTI": "001010",
    "SGTI": "001011",
    "NOTI": "001100",
    "INCI": "001101",
    "DECI": "001110",
    "HAMI": "001111",
    "LUI": "010000",
    "LD": "010001",
    "ST": "010010",
    "BMI": "100001",
    "BPL": "100010",
    "BZ": "100011",
    "MOVE": "010100"
}

Jtype = ["BR"]

Jtype_opcode_map = {
    "BR": "100000"
}

PCtype = ["HALT", "NOP", "CALL"]

PCtype_opcode_map = {
    "HALT": "100100",
    "NOP": "100101",
    "CALL": "100110"
}

R_REG_MAPPING = {
    "R0": "00000",
    "R1": "00001",
    "R2": "00010",
    "R3": "00011",
    "R4": "00100",
    "R5": "00101",
    "R6": "00110",
    "R7": "00111",
    "R8": "01000",
    "R9": "01001",
    "R10": "01010",
    "R11": "01011",
    "R12": "01100",
    "R13": "01101",
    "R14": "01110",
    "R15": "01111",
}


# read a high level instruction text file
with open("input.txt") as file:
    lines = file.readlines()

instructions = []
for line in lines:
    # removing leading and trailing whitespace and remove newline characters and split the line into a list of words separating by commas and spaces
    instructions.append(line.strip().replace(",", " ").split())

file_sep = open("binary_memidx.txt", "w") # file with separators
file_coe = open("output.coe", "w") # file without separators (.coe format)


Rtype = ["ADD", "SUB", "AND", "OR", "XOR", "NOR", "SL", "SRL", "SRA", "SLT", "SGT", "NOT", "INC", "DEC", "HAM", "CMOV"]
Rtype_3reg = ["ADD", "SUB", "AND", "OR", "XOR", "NOR", "SL", "SRL", "SRA", "SLT", "SGT", "CMOV"]

for counter, instr in enumerate(instructions):
    
    if instr[0] in ["LD", "ST"]: # LD R1, #10(R2) -> LD R1, #10 R2
        imm, reg = instr[2].split("(")
        imm = imm.strip()
        reg = reg.strip()
        reg = reg[:-1]
        instr[2] = imm
        instr.append(reg)

    binary_instruction = ""

    if instr[0] in Rtype:

        if instr[0] == "CMOV":
            binary_instruction += "010101" # opcode
        else:
            binary_instruction += "000000" # opcode
        
        binary_instruction += "_" # SEPARATOR

        if instr[0] in Rtype_3reg: # rs
            binary_instruction += R_REG_MAPPING[instr[2]]
        else:
            binary_instruction += "00000" # rs

        binary_instruction += "_" # SEPARATOR

        if instr[0] in Rtype_3reg: # rt
            binary_instruction += R_REG_MAPPING[instr[3]]
        else:
            binary_instruction += R_REG_MAPPING[instr[2]] # rt

        binary_instruction += "_" # SEPARATOR
        
        binary_instruction += R_REG_MAPPING[instr[1]] # rd

        binary_instruction += "_" # SEPARATOR
        
        binary_instruction += "00000" # don't care

        binary_instruction += "_" # SEPARATOR
        
        binary_instruction += Rtype_func_map[instr[0]] # funct

    elif instr[0] in Itype:

        binary_instruction += Itype_opcode_map[instr[0]] # opcode
        
        binary_instruction += "_" # SEPARATOR

        if instr[0] in Itype_3_ri: #rs
            binary_instruction += R_REG_MAPPING[instr[2]]
        elif instr[0] in ["BMI", "BPL", "BZ"]:
            binary_instruction += R_REG_MAPPING[instr[1]] # rs
        elif instr[0] in ["LD", "ST"]:
            binary_instruction += R_REG_MAPPING[instr[3]] # rs
        else: # LUI, NOTI, INCI, DECI, HAMI
            binary_instruction += "00000" # rs

        binary_instruction += "_" # SEPARATOR

        if instr[0] in ["BMI", "BPL", "BZ"]: #rt
            binary_instruction += "00000"
        else:
            binary_instruction += R_REG_MAPPING[instr[1]] # rt

        binary_instruction += "_" # SEPARATOR

        if instr[0] in Itype_3_ri: #immediate
            if instr[0] == "MOVE":
                binary_instruction += "0000000000000000" # 16-bit zero immediate for MOVE
            else:
                binary_instruction += convert_to_binary(instr[3], 16)
        else:
            binary_instruction += convert_to_binary(instr[2], 16) # immediate

    elif instr[0] in Jtype:

        binary_instruction += Jtype_opcode_map[instr[0]] # opcode
        
        binary_instruction += "_" # SEPARATOR
        
        binary_instruction += convert_to_binary(instr[1], 26) # immediate

    elif instr[0] in PCtype:

        binary_instruction += PCtype_opcode_map[instr[0]] # opcode
        
        binary_instruction += "_" # SEPARATOR
        
        binary_instruction += "00000000000000000000000000"

    # Write to file with separators
    file_sep.write(binary_instruction)
    file_sep.write(",")
    file_sep.write("\n")

    # Write to .coe file without separators
    binary_no_sep = binary_instruction.replace("_", "")
    file_coe.write(binary_no_sep)
    file_coe.write(",")
    file_coe.write("\n")

file_sep.close() # Close the file when done
file_coe.close() # Close the .coe file when done