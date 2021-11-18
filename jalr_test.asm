	jal x31, L
	jal x0, END
	addi x16, x0, 10
L:      addi x16, x0, 10
	addi x17, x0, 20
	jalr x0, 0(x31)
	addi x18, x0, 20
END:	addi x19, x0, 20
	addi x9, x0, 10
