#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:4996)

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

//clock cycles
long long cycles = 0;

// registers
long long int regs[32];

// program counter
unsigned long pc = 0;

// memory
#define INST_MEM_SIZE 32*1024
#define DATA_MEM_SIZE 32*1024
unsigned long inst_mem[INST_MEM_SIZE]; //instruction memory
unsigned long long data_mem[DATA_MEM_SIZE]; //data memory

//misc. function
int init(char* filename);

void print_cycles();
void print_reg();
void print_pc();

char inst[33];
char inst32[33];
char opcode[8];
char funct3[4];
char funct7[8];
char rd[6];
char rs1[6];
char rs2[6];
char I_imm[13];
char S_imm[13];

int memto_reg;
int reg_write;
int mem_read;
int mem_write;
int branch;

int rd_value;
int rs1_value;
int rs2_value;
int imm_value;
int ALUresult;

char type[10];

int read_bin(char code[]) 
{
	int result = 0;
	int code_len = strlen(code);
	for (int i = 0; code[i]; i++) {
		result = (result << 1) + code[i] - '0';
	}
	return result;
}

//fetch an instruction from a instruction memory
void fetch() {

	_itoa(inst_mem[pc], inst, 2);

	memset(inst32, '0', 33);
	memset(opcode, '\0', 8);
	memset(funct3, '\0', 4);
	memset(funct7, '\0', 8);
	memset(rd, '\0', 6);
	memset(rs1, '\0', 6);
	memset(rs2, '\0', 6);
	memset(I_imm, '\0', 13);
	memset(S_imm, '\0', 13);

	int len = strlen(inst);
	strcpy(inst32 + (32 - len), inst);
	printf("%s\n", inst32);

	strncpy(opcode, inst32 + 25, 7);
	printf("opcode:	%s\n", opcode);

	strncpy(rd, inst32 + 20, 5);
	printf("rd: %s\n", rd);

	strncpy(funct3, inst32 + 17, 3);
	printf("funct3: %s\n", funct3);

	strncpy(rs1, inst32 + 12, 5);
	printf("rs1: %s\n", rs1);

	strncpy(rs2, inst32 + 7, 5);
	printf("rs2: %s\n", rs2);

	strncpy(funct7, inst32, 7);
	printf("funct7: %s\n", funct7);

	strcat(I_imm, funct7);
	strcat(I_imm, rs2);
	printf("I_imm: %s\n", I_imm);

	strcat(S_imm, funct7);
	strcat(S_imm, rd);
	printf("S_imm: %s\n", S_imm);

	pc++;
}

//decode the instruction and read data from register file
void decode() {
	// add, addi, beq, jal, jalr, sd, ld
	if (strcmp(opcode, "0110011") == 0 && strcmp(funct7, "0000000") == 0)
	{
		//add
		rd_value = read_bin(rd);
		printf("%d\n", rd_value);

		rs1_value = read_bin(rs1);
		printf("%d\n", rs1_value);

		rs2_value = read_bin(rs2);
		printf("%d\n", rs2_value);

		strcpy(type, "add\0");
		memto_reg = 0;
		reg_write = 1;
		mem_read = 0;
		mem_write = 0;
		branch = 0;
	}

	if (strcmp(opcode, "0010011") == 0 && strcmp(funct3, "000") == 0)
	{
		//addi
		rd_value = read_bin(rd);
		printf("%d\n", rd_value);

		rs1_value = read_bin(rs1);
		printf("%d\n", rs1_value);

		imm_value = read_bin(I_imm);
		printf("%d\n", imm_value);

		strcpy(type, "addi\0");
		memto_reg = 0;
		reg_write = 1;
		mem_read = 0;
		mem_write = 0;
		branch = 0;
	}

	// if (strcmp(opcode, 1100011) == 0 && funct3 == 000) beq;

	//if (strcmp(opcode, 1101111) == 0) jal;

	//if (strcmp(opcode, 1100111) == 0 && funct3 == 000) jalr;

	if (strcmp(opcode, "0000011") == 0 && strcmp(funct3, "011") == 0) 
	{
		// ld
		rd_value = read_bin(rd);
		printf("%d\n", rd_value);

		rs1_value = read_bin(rs1);
		printf("%d\n", rs1_value);

		imm_value = read_bin(I_imm);
		printf("%d\n", imm_value);

		strcpy(type, "ld\0");
		memto_reg = 1;
		reg_write = 1;
		mem_read = 1;
		mem_write = 0;
		branch = 0;
	}

	if (strcmp(opcode, "0100011") == 0)
	{
		//sd

		rs1_value = read_bin(rs1);
		printf("%d\n", rs1_value);

		imm_value = read_bin(S_imm); // address
		printf("%d\n", imm_value);

		rs2_value = read_bin(rs2); // 저장할 register
		printf("%d\n", rs2_value);

		strcpy(type, "ld\0");
		reg_write = 0;
		mem_read = 0;
		mem_write = 1;
		branch = 0;
	}
}

//perform the appropriate operation 
void exe() {
	if (strcmp(type, "add") == 0)
	{
		ALUresult = regs[rs1_value] + regs[rs2_value];
	}

	if (strcmp(type, "addi") == 0)
	{
		ALUresult = regs[rs1_value] + imm_value;
	}
}

//access the data memory
void mem() {

}

//write result of arithmetic operation or data read from the data memory if required
void wb() {
	if(memto_reg == 0 && reg_write == 1)  //R
		regs[rd_value] = ALUresult;

	if (memto_reg == 1 && reg_write == 1) //ld
		regs[rd_value] = data_mem[10];

	regs[0] = 0;
}

int main(int ac, char* av[])
{

	if (ac < 3)
	{
		printf("./riscv_sim filename mode\n");
		return -1;
	}


	char done = 0;
	if (init(av[1]) != 0)
		return -1;


	printf("inst_mem[0] = %d\n", inst_mem[0]);
	printf("inst_mem[0] to bin = %32s\n", _itoa(inst_mem[0], inst, 2));
	//printf("inst_mem[1] = %d\n", inst_mem[1]);
	/*printf("inst_mem[0] to bin = %s\n", _itoa(inst_mem[1], arr, 2));
	printf("inst_mem[2] = %d\n", inst_mem[2]);
	printf("inst_mem[0] to bin = %s\n", _itoa(inst_mem[2], arr, 2));
	printf("inst_mem[3] = %d\n", inst_mem[3]);
	printf("inst_mem[0] to bin = %s\n", _itoa(inst_mem[3], arr, 2));*/

	while (!done)
	{

		fetch();
		decode();
		exe();
		mem();
		wb();


		cycles++;    //increase clock cycle

		//if debug mode, print clock cycle, pc, reg 
		if (*av[2] == '0') {
			print_cycles();  //print clock cycles
			print_pc();		 //print pc
			print_reg();	 //print registers
		}

		// check the exit condition, do not delete!! 
		if (regs[9] == 10)  //if value in $t1 is 10, finish the simulation
			done = 1;
	}

	if (*av[2] == '1')
	{
		print_cycles();  //print clock cycles
		print_pc();		 //print pc
		print_reg();	 //print registers
	}

	return 0;
}


/* initialize all datapat elements
//fill the instruction and data memory
//reset the registers
*/
int init(char* filename)
{
	FILE* fp = fopen(filename, "r");
	int i;
	long inst;

	if (fp == NULL)
	{
		fprintf(stderr, "Error opening file.\n");
		return -1;
	}

	/* fill instruction memory */
	i = 0;
	while (fscanf(fp, "%lx", &inst) == 1)
	{
		inst_mem[i++] = inst;
	}


	/*reset the registers*/
	for (i = 0; i < 32; i++)
	{
		regs[i] = 0;
	}

	/*reset pc*/
	pc = 0;
	/*reset clock cycles*/
	cycles = 0;
	return 0;
}

void print_cycles()
{
	printf("---------------------------------------------------\n");

	printf("Clock cycles = %lld\n", cycles);
}

void print_pc()
{
	printf("PC	   = %ld\n\n", pc);
}

void print_reg()
{
	printf("x0   = %d\n", regs[0]);
	printf("x1   = %d\n", regs[1]);
	printf("x2   = %d\n", regs[2]);
	printf("x3   = %d\n", regs[3]);
	printf("x4   = %d\n", regs[4]);
	printf("x5   = %d\n", regs[5]);
	printf("x6   = %d\n", regs[6]);
	printf("x7   = %d\n", regs[7]);
	printf("x8   = %d\n", regs[8]);
	printf("x9   = %d\n", regs[9]);
	printf("x10  = %d\n", regs[10]);
	printf("x11  = %d\n", regs[11]);
	printf("x12  = %d\n", regs[12]);
	printf("x13  = %d\n", regs[13]);
	printf("x14  = %d\n", regs[14]);
	printf("x15  = %d\n", regs[15]);
	printf("x16  = %d\n", regs[16]);
	printf("x17  = %d\n", regs[17]);
	printf("x18  = %d\n", regs[18]);
	printf("x19  = %d\n", regs[19]);
	printf("x20  = %d\n", regs[20]);
	printf("x21  = %d\n", regs[21]);
	printf("x22  = %d\n", regs[22]);
	printf("x23  = %d\n", regs[23]);
	printf("x24  = %d\n", regs[24]);
	printf("x25  = %d\n", regs[25]);
	printf("x26  = %d\n", regs[26]);
	printf("x27  = %d\n", regs[27]);
	printf("x28  = %d\n", regs[28]);
	printf("x29  = %d\n", regs[29]);
	printf("x30  = %d\n", regs[30]);
	printf("x31  = %d\n", regs[31]);
	printf("\n");
}
