main:
    addi x2, x0, 800
    addi x10, x0, 10                    #n=10
    jal x1, accum                       #call accum
    jal x0, exit                        #exit
accum:
    addi x2, x2, -16                    #adjust sp
    sd x1, 8(x2)                        #push return address
    sd x10, 0(x2)                       #push n
    addi x5, x10, -1                    #t=n-1
    beq x0, x0, L1
L2: addi x10, x0, 1                     #r=1
    addi x2, x2, 16                     #adjust sp
    jalr x0 0(x1)                       #return to caller
L1: beq x5, x0, L2                      #if n==0?
    addi x10, x10, -1                   #t=n-1
    jal x1 accum                         #call fact
    addi x6, x10, 0                     #t1=n    
    ld x10, 0(x2)                       #pop n
    ld x1, 8(x2)                        #pop return address
    addi x2, x2, 16                     #adjust sp
    add x10, x10, x6                    #n+accum(n-1)
    jalr x0, 0(x1)                      #return to caller
exit: addi x9, x0, 10
