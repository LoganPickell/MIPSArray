.data
	welcomeMessage: .asciiz "Welcome! This program permutates an array of any size."
	askForSize: .asciiz "Please enter the size of the array: "
	askForNumber1: .asciiz "Please enter the "
	askForNumber2: .asciiz " elements of your array: "
	permutation1: .asciiz "Please enter the permuataion(Index values between 0-"
	permutation2: .asciiz "): "
	postPermArray: .asciiz "The array after permutation is: "
	
	
.text
#						array address stored in $t0
#						arraySize stored in $t9, reloading into $t1 for loops
# 						permutation array address stored in $t2
#	
	
	la $a0, welcomeMessage
	li $v0, 4
	syscall
	
	li $a0, 10
	li $v0, 11
	syscall
	
arraySize:
	la $a0, askForSize
	li $v0, 4
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
	li $v0, 5
	syscall
	
	move $t9, $v0   #Size in $t9
	add $t1, $zero, $t9 #store copy of size in $t1 for loops
	
allocateMemForArrays:	
	mul $a0, $t1, 4 # a0 = 4(size) = bytes needed
	li $v0, 9
	syscall #allocate memory for the array
	
	move $t0, $v0 #move mem. address of array into $t0
	
	
	mul $a0, $t1, 4 #repeat to create permutation array of same size
	li $v0, 9
	syscall
	
	move $t2, $v0  #move mem. address of permArray into $t2
	
arrayValuesPrompt:
	la $a0, askForNumber1   
	li $v0, 4
	syscall			  # print "Please enter the "
	
	add $a0, $t1, $zero
	li $v0, 1
	syscall                   #print array size
	
	la $a0, askForNumber2
	li $v0, 4
	syscall                   #" elements of your array: "
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
setArrayValues:
	subi $t1, $t1, 1 #subtract one from arraySize
	
	li $v0, 5#ask for number
	syscall
	sw $v0, ($t0)#store number in array
	
	addi $t0, $t0, 4#move to next array slot
	
	bgt $t1, $zero, setArrayValues #loop if arraySize is greater than 0
permutations:

	add $t1, $t9, $zero
	la $a0, permutation1
	li $v0, 4
	syscall              #print "Please enter the permuataion(Index values between 0-"
	
	subi $t1, $t1, 1
	la $a0, ($t1)
	li $v0, 1
	syscall                #print array size-1
	addi $t1, $t1, 1
	
	la $a0, permutation2  # print "): "
	li $v0, 4
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall
permValues: #(assuming correct input; ex: 0-9 for size 10 array)
	subi $t1, $t1, 1 #subtract one from arraySize
	
	li $v0, 5
	syscall
	

	sw $v0, ($t2)#store number in array
	
	addi $t2, $t2, 4#move to next array slot
	bgt $t1, $zero, permValues #loop if arraySize is greater than 0

resetArrays:
	add $t1, $t9, $zero
	mul $t3, $t9, 4
	sub $t0, $t0, $t3
	sub $t2, $t2, $t3

	
	subi $t3, $t9, 2	
	li $t4, 0         #t4 = i{0}
			   
iLoop:
	mul $t6,$t4, 4 #t6 = 4i
	add $t8, $t0, $t6 
	lw $t8, 0($t8) # t8 = array[i].value
	add $t1, $t2,$t6 
	
	lw $t1,0($t1) # t1 = permArray[i].value
	mul $t1, $t1, 4 
	add $t7, $t0, $t1 
	
	lw $t7, 0($t7) # t7= array[permArray[i]].value
	add $t0, $t0, $t6 # t0 = array[i]
	sw $t7, 0($t0)  # store t7 into array[i]
	sub $t0, $t0, $t6 # reset array

	add $t1, $t0, $t1
	sw $t8, ($t1) # store array[i].value into array[permArray[i]]
	
					# array[I] <--> array[permArray[I]]  complete
	add $t5, $t4, 1  # t5 = j{i+1}
	jal jLoop
	addi $t4,$t4,  1 # i++
	bge $t3, $t4, iLoop
	j postPermArrayPrompt



jLoop:
	mul $t7, $t5, 4
	add $t6, $t2, $t7 #t6 = Permarray[j]
	lw $t1, 0($t6) #t1 = PermArray[J].value
	
	subi $t8, $t9, 1 # $t8 = {size - 1}
	addi $t5, $t5, 1 #j++
	beq $t4, $t1, swapPermArray_i_and_j
jLoopReturn:	
	bge $t8, $t5, jLoop # (size - 1) >= j
	jr $ra
	
	
swapPermArray_i_and_j:
	
	mul $t7, $t4, 4   #t7 = 4i 
	add $t2, $t2, $t7  #t2 = permArray[i]
	lw $t7, 0($t2) #t7 = permArray[i].value
	
	sw $t1, 0($t2)	#permArray[I] <->  permArray[J]
	sw $t7, 0($t6)
	
	mul $t7, $t4, 4
	sub $t2, $t2, $t7 #reset permArray
	j jLoopReturn
		
postPermArrayPrompt:	
	add $t1, $t9, $zero	
	la $a0, postPermArray  
	li $v0, 4
	syscall			#print "The array after permutation is: "
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
printFinalArray: 		#loop to print each array element after permutation
	sub $t9, $t9, 1

	lw $a0, 0($t0)
	li $v0, 1
	syscall
	
	li $a0, ' '
	li $v0, 11
	syscall
	
	addi $t0, $t0, 4
	bgt $t9, $zero, printFinalArray 

closeProgram:

	li $a0, '\n'
	li $v0, 11
	syscall
	
	li $v0, 10
	syscall 
	

	
