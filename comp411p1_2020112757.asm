# -------------------------------------------------------------------
# [KNU COMP411 Computer Architecture] Skeleton code for the 1st project (calculator)
# ��ǻ���к� 2020112757 ������
# -------------------------------------------------------------------

.globl main

.data
error_str: .string "error!"
expr: .asciz ""
.align 2
.space 100

.text	
# main
main:

	jal x1, test #functionality test, Do not modify!!
	
	#----TODO-------------------------------------------------------------
	#1. read a string from the console
	#2. perform arithmetic operations
	#3. print a string to the console to show the computation result
	#----------------------------------------------------------------------
	
	addi sp, sp, -80			
	sw s1, 0(sp)			
	sw s2, 8(sp)				
	sw s3, 16(sp)
	sw s4, 24(sp)
	sw s5, 32(sp)
	sw s6, 40(sp)
	sw s7, 48(sp)
	sw s8, 56(sp)
	sw s9, 64(sp)
	sw s10, 72(sp)
	
	# input: get string from console 
	la a0, expr
	li a1, 100
	li a7, 8
	ecall  
	
	addi t3, zero, 43		# '+'
	addi t4, zero, 45		# '-'
	addi t5, zero, 42		# '*'
	addi t6, zero, 47		# '/'
	

	# s1 -> 1����Ʈ�� �о ����
	# s2 -> ù ��° operand�� ���� �ڸ��� counter
	# s3 -> �� ��° operand�� ���� �ڸ��� counter
	# s4 -> 10�� n��!!
	# s5 -> ù ��° operand�� 10�� �ڸ� �ּҰ� ����.
	# s6 -> �� ��° operand�� 10�� �ڸ� �ּҰ� ����.
	
	# s7 -> a1 �� �ӽ� ����
	# s8 -> a2 �� �ӽ� ����
	# s9 -> a3 �� �ӽ� ����.
	
	# s10 -> '\n' �ƽ�Ű�ڵ� ��
	li s10, 10
	
	# a5 -> string�� ���� �ּ�
	mv a5 a0
	
	li s2, -1			# first counter -1�� �ʱ�ȭ
	li s3, -1			# second counter -1�� �ʱ�ȭ
	li s4, 10	
	addi a1, zero, 2 
	
	oploop:
	lb s1, (a5)			# 1����Ʈ�� �о��.
	addi a5, a5, 1			# pointer�� �ڷ� ��ĭ �ű�.
	beq s1, t3, addop		#
	beq s1, t4, subop
	beq s1, t5, mulop
	beq s1, t6, dividop
	addi s8, s1, -48		# a2�� ���� �ӽ÷� s8��
	addi s5, a5, -2			# �� �ּҸ� ������ a2�� 10�� �ڸ� ����
	addi s2, s2, 1			# counter
	beq zero, zero, oploop
	
	# s7(a1)�� ��ȣ�� �ֱ�
	addop:
	addi s7, zero, 0
	beq zero, zero, setdone
	subop:
	addi s7, zero, 1
	beq zero, zero, setdone
	mulop:
	addi s7, zero, 2
	beq zero, zero, setdone
	dividop:
	addi s7, zero, 3
	
	# second operand�� �ڸ� �� ���ϱ�.
	setdone:
	lb s1, (a5)		
	addi a5, a5, 1
	addi a3, a3, 1
	beq s1, s10, second   # \n���� �ƽ�Ű �� ��
	addi s9, s1, -48		# a3���� �ӽ÷� s9�� ���� (�������� ���� �ڸ� ���� �����.)
	addi s6, a5, -2			# �� �ּҸ� ������ a2�� 10�� �ڸ� ����
	addi s3, s3, 1			# counter
	beq zero, zero, setdone
	
	# s9(a3)�� second operand �� ���ؼ� �ֱ�.
	second:
	beq s3, zero, reset		# second set complete
	lb s1, (s6)				# ���� �ڸ� ���� �о��. ###
	addi s1, s1, -48
	mv a2, s1
	mv a3, s4
	jal x1, calc			# ���
	add s9, s9, a0			# ���� �� �����ֱ�.
	addi s3, s3, -1			# index - 1
	addi s6, s6, -1
	beq s3, zero, reset		# second set complete
	mv a2, s4
	li a3, 10
	jal x1, calc
	mv s4, a0				# 0�� ���� ����.
	beq zero, zero, second
	
	reset:
	li s4, 10
	
	# s8(a2)�� first operand �� ���ؼ� �ֱ�.
	first: 
	beq s2, zero, goout	 	# second set complete
	lb s1, (s5)				# ���� �ڸ� ���� �о��.
	addi s1, s1, -48
	mv a2, s1
	mv a3, s4
	jal x1, calc			# ���
	add s8, s8, a0			# ���� �� �����ֱ�.
	addi s2, s2, -1			# index - 1
	addi s5, s5, -1
	beq s2, zero, goout	 	# second set complete
	mv a2, s4
	li a3, 10
	jal x1, calc
	mv s4, a0				# 0�� ���� ����.
	beq zero, zero, first
	
	# ��� �� ���
	goout:
	mv a1, s7
	mv a2, s8
	mv a3, s9	
	jal x1, calc
	li a7, 1	
	ecall
	
	# �������� ��� ������ ���
	li t0, 3
	bne a1, t0, exit		# a1�� 3�� �ƴϸ� ����
	li a7, 11
	li a0, 44				# display ','
	ecall 
	li a0, 32
	ecall					# display ' '
	li a7, 1				
	mv a0, a4				# display remainder
	ecall
				
	lw s1, 0(sp)			
	lw s2, 8(sp)				
	lw s3, 16(sp)
	lw s4, 24(sp)
	lw s5, 32(sp)
	lw s6, 40(sp)
	lw s7, 48(sp)
	lw s8, 56(sp)
	lw s9, 64(sp)
	lw s10, 72(sp)
	addi sp, sp, 80
	
	# Exit (93) with code 0
	exit:
    li a0, 0
    li a7, 93
    ecall
    ebreak

#----------------------------------
#name: calc
#func: performs arithmetic operation
#x11(a1): arithmetic operation (0: addition, 1:  subtraction, 2:  multiplication, 3: division)
#x12(a2): the first operand
#x13(a3): the second operand
#x10(a0): return value
#x14(a4): return value (remainder for division operation)
#----------------------------------
calc:
	addi sp, sp, -24			#adjust stack pointer
	sw a2, 0(sp)				# first
	sw a3, 8(sp)				# second
	sw s0, 16(sp)
	
	#TODO
	addi t0, zero, 0
	bne a1, t0, calc_sub
	
	calc_add:
	add a0, a2, a3
	beq zero, zero, done
	
	calc_sub:
	addi t0, zero, 1
	bne a1, t0, calc_mul
	neg a3, a3						# a3�� ������ ��ȯ
	add a0, a2, a3
	beq zero, zero, done
	
	calc_mul:
	addi t0, zero, 2
	bne a1, t0, calc_div
	addi t4, zero, 32				# index
	addi a0, zero, 0				# result (return value)
		mul_loop:
		andi t5, a3, 1				# LSB ���ϱ�
		beq zero, t5, shift  		# 0 �̸� �ٷ� shift 
		add a0, a0, a2    			# a0�� multiplicand ���ϱ�
		shift: 
		slli a2, a2, 1    			# multiplicand <<
		srli a3, a3, 1     			# multiplier >>
		addi t4, t4, -1   			# index ����
		bne t4, zero, mul_loop		# index�� 0�� �ƴϸ� �ݺ�
		beq zero, zero, done
	
	calc_div:
	beq a3, zero, error
	addi t4, zero, 17				# index
	addi a4, a2, 0					# initialize remainder (return value)
	addi a0, zero, 0				# quotient (return value)
	slli a3, a3, 16					# divisor << (initialized in the left half) 
		div_loop:
		addi t5, a4, 0				# t5�� remainder ����
		neg s0, a3
		add a4, a4, s0				# remainder = remainder-divisor
		blt a4, zero, recovery		# remainder < 0 ��� recovery��
		slli a0, a0, 1				# (remainder >= 0) quotient << 1
		addi a0, a0, 1				# quotient + 1
		beq zero, zero, divisor_shift
		recovery:
			addi a4, t5, 0			# remainder = t5
			slli a0, a0, 1			# quotient << 1
		divisor_shift:
		srli a3, a3, 1				# divisor >> 1
		addi t4, t4, -1   			# index ����
		bne t4, zero, div_loop     # index�� 0�� �ƴϸ� �ݺ�
		
	done:
	lw a2, 0(sp)
	lw a3, 8(sp)
	lw s0, 16(sp)
	addi sp, sp, 24
	
	jalr zero, 0(ra)
	
	# print error!
	error:
	la a0, error_str
	li a7, 4
	ecall						

	# Exit (93) with code 0
    li a0, 0
    li a7, 93
    ecall
    ebreak

.include "common.asm"
