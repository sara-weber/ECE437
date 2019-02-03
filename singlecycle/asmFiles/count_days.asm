# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                       #
#   File name: count_days.asm                                           #
#                                                                       #
#   Date created: 01/14/19                                              #
#                                                                       #
#   Programmer: James Weber                                             #
#                                                                       #
#   Lab/HW #: 02                                                        #
#                                                                       #
#   Description: Multiplies two unsigned words.                         #
#                                                                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

org 0x00
main:	
	# Store stack pointer in s-register
	ori $s0, $0, 0x8FFC

	# CurrentMonth
	ori $t5, $0, 1
	# CurrentDay
	ori $t6, $0, 6
	# CurrentYear
	ori $t7, $0, 2019


	# CurrentMonth - 1
	addi $t5, $t5, -1
	# CurrentYear - 2000
	addi $t7, $t7, -2000

	# Mult 30 * CurrentMonth

	# Store 30, CurrentMonth on the stack
	ori $a3, $0, 30
	jal cust_push
	or $a3, $0, $t5
	jal cust_push
	# $t5 = 30 * (CurrentMonth - 1) 
	jal mult
	or $t5, $0, $v0

	# Mult 365 * (CurrentYear - 2000)

	# Store 365, CurrentYear on the stack
	ori $a3, $0, 365
	jal cust_push
	or $a3, $0, $t7
	jal cust_push
	# t7 = 365 * (CurrentYear - 2000)
	jal mult
	or $t7, $0, $v0

	# $t6 = CurrentDay + 30 * (CurrentMonth - 1) 
	add $t6, $t6, $t5

	# $t1 = CurrentDay + 30 * (CurrentMonth - 1) + 365 * (CurrentYear - 2000)
	add $t6, $t6, $t7

	# Push result to stack
	or $a3, $0, $t6
	jal cust_push
	halt

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#  ╔══════════╦═════════════╦════════╗
#  ║ asm      ║ c           ║ i/o/v  ║
#  ╠══════════╬═════════════╬════════╣
#  ║ a0 (R4)  ║ num_1       ║ input  ║
#  ║ a1 (R5)  ║ num_2       ║ input  ║
#  ║ v0 (R2)  ║ result      ║ output ║
#  ║ t0 (R8)  ║ multiplier  ║ var    ║
#  ║ t1 (R9)  ║ inner_prod  ║ var    ║
#  ║ t2 (R10) ║ ip_shifted  ║ var    ║
#  ║ t3 (R11) ║ shift_level ║ var    ║
#  ║ t4 (R12) ║ shift_one   ║ var    ║
#  ╚══════════╩═════════════╩════════╝

mult:  				  				# mult() {
	or $t9, $0, $ra 				#   // Store return address
	jal cust_pop					#   // Pops two unsigned numbers 
	or $a0, $0, $v0					#   // from the stack
	jal cust_pop					#
	or $a1, $0, $v0					#
	or $a3, $0, $t9					#   // Push $ra to the stack
	jal cust_push					#
	and $v0, $0, $0	  	  			#   int result = 0;
	and $t3, $0, $0		  			#   int shift_level = 0;
	addi $t4, $0, 1		  			#   int shift_one = 1;
	beq $a0, $0, return_mult  		#   if (!num_1 || !num_2)
	beq $a1, $0, return_mult  		#     return result;
mlt_out_loop:			  			#   while(num_2 > 0) {
	andi $t0, $a1, 1	  			#     int multiplier = num_2 & 0x1;
	and $t1, $0, $0		  			#     int inner_prod = 0;
	beq $t0, $0, mlt_out_loop_end 	#     
mlt_in_loop:			  			#     while (multiplier > 0) {
	add $t1, $t1, $a0	  			#       inner_prod += num_1;
	addi $t0, $t0, -1	  			#       multiplier -= 1;
	bne $t0, $0, mlt_in_loop  		#     }     
mlt_out_loop_end:					#
	sllv $t2, $t3, $t1	  			#     int ip_shifted = inner_prod << shift_level;
	add $v0, $v0, $t2 	  			#     result += ip_shifted;
	addi $t3, $t3, 1 	  			#     shift_level += 1;
	srlv $a1, $t4, $a1       		#     num_2 = num_2 >> 1;
	bne $a1, $0, mlt_out_loop 		#   }
return_mult:			  			#   
	or $t9, $0, $v0					#   // Save result in temp
	jal cust_pop 					#   // Pop $ra from stack 
	or $ra, $0, $v0					#   // Put result back in $v0
	or $v0, $0, $t9					#   return result;
	jr $ra 			  				# }
	 			 

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cust_push:
	addi $s0, $s0, -4	# SP -= 4
	sw $a3, 0($s0)		# push(arg_1)
	jr $ra				# return

cust_pop:
	lw $v0, 0($s0)		# pop(return_val_1)
	addi $s0, $s0, 4	# SP += 4
	jr $ra 				# return
