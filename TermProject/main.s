;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@date				31/01/2021
;
;@PROJECT GROUP
;@groupno			12
;@member1			150160514 Halil Ibrahim YAVUZ
;@member2			150180730 Ayse Betül ÇETIN
;@member3			150160718 Samed Kahyaoglu
;@member4			150170706 Samil Taner CENGIZ
;@member5			150130042 Guris ÖZEN
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
							


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------															
				EXPORT SysTick_Handler
				PUSH	{r0-r7, lr}
				
				;tick count is incremented
				LDR		r1, =TICK_COUNT				;loading tick count address to r1
				LDR		r2, [r1]					;tick count value is stored in r2
				ADDS	r2, r2, #1					;tick count is incremented
				STR		r2, [r1]					;updated tick count is stored in memory
				
				LDR		r1, =INDEX_INPUT_DS			;loading index address to r1
				LDR		r4, [r1]					;loading value address to r4
				LSLS	r4, r4, #2					;r4 is multiplied by 4 (for memory operations)
				LDR		r2, =IN_DATA				;loading data address to r2
				LDR		r3, =IN_DATA_FLAG			;loading data flag address to r3
				LDR		r0,	[r2, r4]				;loading the data value to r0
				LDR		r6, [r3, r4]				;loading the flag value to r6
				MOV		r7, r0						;loading data value to r7 also
				
				CMP		r6, #2						
				BLE		valid_op					;if operation is valid
				PUSH	{r0-r3}						;operation is not valid
				MOV		r3,	r0						;4th parameter of WriteErrorLog
				LDR		r0,	=INDEX_INPUT_DS			;r0 keeps the address of index
				LDR		r0, [r0]					;1st parameter of WriteErrorLog
				LDR		r1, =6						;2nd parameter of WriteErrorLog
				MOV		r2,	r6						;3rd parameter of WriteErrorLog
				BL		WriteErrorLog				;Call WriteErrorLog
				POP		{r0-r3}
				B		not_LL2Array
valid_op				
				CMP		r6, #0						;if the operation is deletion
				BNE		not_deletion
				BL		Remove						;call Remove
				CMP		r0, #0						;error code ?= 0
				BEQ		not_LL2Array

				;error occured in Remove
				PUSH	{r0-r3}						
				MOV		r3,	r7						;4th parameter of WriteErrorLog
				MOV		r1, r0						;2nd parameter of WriteErrorLog
				LDR		r0,	=INDEX_INPUT_DS			;r0 keeps the address of index
				LDR		r0, [r0]					;1st parameter of WriteErrorLog
				MOV		r2,	r6						;3rd parameter of WriteErrorLog
				BL		WriteErrorLog				;Call WriteErrorLog
				POP		{r0-r3}
				B		not_LL2Array

not_deletion	
				CMP		r6, #1						;if the operation is insertion
				BNE		not_insertion
				BL		Insert
				CMP		r0, #0						;error code ?= 0
				BEQ		not_LL2Array
				
				;error occured in Insert
				PUSH	{r0-r3}						
				MOV		r3,	r7						;4th parameter of WriteErrorLog(data)
				MOV		r1, r0						;2nd parameter of WriteErrorLog(error code)
				LDR		r0,	=INDEX_INPUT_DS			;r0 keeps the address of index
				LDR		r0, [r0]					;1st parameter of WriteErrorLog(index)
				MOV		r2,	r6						;3rd parameter of WriteErrorLog(operation)
				BL		WriteErrorLog				;Call WriteErrorLog
				POP		{r0-r3}
				B		not_LL2Array
				
not_insertion	
				CMP		r6, #2						;if the operation is linked list to array
				BNE		not_LL2Array
				BL		LinkedList2Arr
				CMP		r0, #0						;error code ?= 0
				BEQ		not_LL2Array
				B		not_LL2Array	;;sonra sil
				;error occured in LL2Array
				PUSH	{r0-r3}						;operation is not valid
				MOV		r3,	r7						;4th parameter of WriteErrorLog
				MOV		r1, r0						;2nd parameter of WriteErrorLog
				LDR		r0,	=INDEX_INPUT_DS			;r0 keeps the address of index
				LDR		r0, [r0]					;1st parameter of WriteErrorLog
				MOV		r2,	r6						;3rd parameter of WriteErrorLog
				BL		WriteErrorLog				;Call WriteErrorLog
				POP		{r0-r3}
not_LL2Array
				LSRS	r4, r4, #2					;r4 is divided by 4
				ADDS	r4, r4, #1					;index value is incremented
				STR		r4, [r1]					;index value is stored in the memory again		
				
				
				
				
				;checking if all data operations are finished
				LDR		r0, =IN_DATA				;r0 holds the address of the IN_DATA
				LDR		r1, =END_IN_DATA			;r1 holds the address of the END_IN_DATA
				LDR		r2, =INDEX_INPUT_DS			;
				LDR		r2, [r2]					;r2 keeps the index value
				LSLS	r2, r2, #2					;index is multiplied by 4 (OFFSET)
				ADD		r0, r0, r2					;r0 = IN_DATA address + OFFSET(index * 4)
				MOV		r3, r0						;r3 = r0
				CMP		r3, r1						;r3 >= END_IN_DATA address 
				BLT		not_finished				;program continues if not
				
				;all operations are finished
				BL		SysTick_Stop				;stops the timer
not_finished
				
				POP		{r0-r7, pc}
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------	

				PUSH	{r1, r2, r3, lr}
				
				LDR		r1, =0xE000E018				;loading systick current value address to r1
				LDR		r2, =0						;loading 0 to r2
				STR		r2, [r1]					;clearing systick current value
				
				LDR		r1, =0xE000E014				;loading systick reload value address to r1
				LDR		r2, =722					;loading 722(our tick timer interrupt period) to r2
				STR		r2, [r1]					;storing 722 to systick reload value register
				
				LDR		r1, =0xE000E010				;loading SYST_CSR address to r1
				LDR		r2, [r1]					;loading SYST_CSR value to r2
				LDR		r3, =7						;loading 7 (111 in binary) to r3
				ORRS	r2, r2, r3					;setting first 3 bits of r2 to 1
				STR		r2, [r1]					;storing r2 to SYST_CSR
													;CLKSOURCE, TICKINT and ENABLE bits are set to 1
													
				LDR		r1, =PROGRAM_STATUS			;loading PROGRAM_STATUS address to r1
				LDR		r2, =1						;loading 1 to r2
				STR		r2, [r1]					;changing program status to 1(timer started)
				
				POP		{r1, r2, r3, pc}

;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	

				PUSH	{r1, r2, r3, lr}
				
				LDR		r1, =0xE000E010				;loading SYST_CSR address to r1
				LDR		r2, [r1]					;loading SYST_CSR value to r2
				LDR		r3, =7						;loading 7 (111 in binary) to r3
				RSBS	r3, r3, #0					;negating r3 (r3=1111...000 now) 
				SUBS	r3, r3, #1					;previous operation adds 1, so we decrease 1
				ANDS	r2, r2, r3					;setting first 3 bits of r2 to 0
				STR		r2, [r1]					;storing r2 to SYST_CSR
													;CLKSOURCE, TICKINT and ENABLE bits are set to 0	

				;changing program status to 2
				LDR		r1, =PROGRAM_STATUS			;loading PROGRAM_STATUS address to r1
				LDR		r2, =2						;loading 2 to r2
				STR		r2, [r1]					;changing program status to 2(all operations are finished)
				
				POP		{r1, r2, r3, pc}

;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------	

				PUSH	{r0-r3, lr}
				
				LDR		r0, =0					;r0 holds the line value
				LDR		r1, =NUMBER_OF_AT		;loading the address of NUMBER_OF_AT to r1
				LDR		r2, =0					;r2 will be used for resetting
				LDR		r3, =AT_MEM				;loading AT_MEM address to r3

Loop_CA
				CMP		r0, r1					;if line < NUMBER_OF_AT
				BGE		Loop_CA_end				;line is >= NUMBER_OF_AT
				LSLS	r0, r0, #2				;line is multiplied by 4 to be used in memory operations
				STR		r2, [r3, r0]			;corresponding AT bits are set to 0
				LSRS	r0, r0, #2				;line is divided by 4
				
				ADDS	r0, r0, #1				;line++
				B 		Loop_CA
Loop_CA_end				
				
				POP		{r0-r3, pc}

;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------	

				PUSH	{r0-r3, lr}
				
				LDR		r0, =0					;r0 holds the line value
				LDR		r1, =NUMBER_OF_AT*32*3	;loading the address of LOG_ARRAY_SIZE to r1
				LDR		r2, =0					;r2 will be used for resetting
				LDR		r3, =LOG_MEM			;loading LOG_MEM address to r3

Loop_CEL
				CMP		r0, r1					;if line < LOG_ARRAY_SIZE
				BGE		Loop_CEL_end			;line is >= LOG_ARRAY_SIZE
				LSLS	r0, r0, #2				;line is multiplied by 4 to be used in memory operations
				STR		r2, [r3, r0]			;corresponding LOG_MEM bits are set to 0
				LSRS	r0, r0, #2				;line is divided by 4
				
				ADDS	r0, r0, #1				;line++
				B 		Loop_CEL
Loop_CEL_end				
				
				POP		{r0-r3, pc}

;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------	

				PUSH	{r1, r2, lr}
				
				LDR		r1, =TICK_COUNT						;loading TICK_COUNT address to r1
				LDR		r2, =0								;loading 0 to r2
				STR		r2, [r1]							;setting TICK_COUNT to 0
				
				LDR		r1, =FIRST_ELEMENT					;loading FIRST_ELEMENT address to r1
				STR		r2, [r1]							;setting FIRST_ELEMENT to 0
				
				LDR		r1, =INDEX_INPUT_DS					;loading INDEX_INPUT_DS to r1
				STR		r2, [r1]							;setting INDEX_INPUT_DS to 0
				
				LDR		r1, =INDEX_ERROR_LOG				;loading INDEX_ERROR_LOG address to r1
				STR		r2, [r1]							;setting INDEX_ERROR_LOG to 0
				
				LDR		r1, =PROGRAM_STATUS					;loading PROGRAM_STATUS address to r1
				STR		r2, [r1]							;setting PROGRAM_STATUS to 0
				
				POP		{r1, r2, pc}

;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	

				PUSH	{r1-r7, lr}
				
				LDR		r1, =AT_MEM					;loading AT_MEM address to r1
				LDR		r2, =DATA_MEM 				;loading DATA_MEM address to r2
				LDR		r3, =0						;r3 holds the line value
				
				;finding line value
Malloc_Loop		
				LSLS	r3, #2						;line = line * 4
				LDR		r4, [r1, r3]				;r4 holds the value in the line
				LSRS	r3, #2						;line = line / 4
				LDR		r7, =0xFFFFFFFF
				CMP		r4, r7						;checking if the line is full
				BEQ		Skip
				BLS		Malloc_LoopEND				;
Skip
				ADDS	r3, r3, #1					;line value is incremented

				;checking if maximum line number is exceeded
				LDR		r5, =NUMBER_OF_AT			;r5 holds the NUMBER_OF_AT
				CMP		r3, r5						;if line > NUMBER_OF_AT
				BLT		Malloc_Loop				
				LDR		r0, =0						;r0 = NULL
				B		Malloc_END					;finishes the Malloc function
Malloc_LoopEND	
				
				LDR		r5, =0						;r5 holds the bit value
				LDR		r6, =1						;r6 holds 1
				;finding bit value
M_Bit_start		LSLS	r6, r6, r5					;1 is left shifted bits value times
				ANDS	r6, r6, r4					;r6 is bitwise ANDed with r4
				LSRS	r6, r6, r5					;result is right shifted bits value times
				CMP		r6, #1						;checking if result is 1(result is 0 if the corresponding bit was 0)
				BNE		M_Bit_Stop
				ADDS	r5, #1						;increment bits value
				B		M_Bit_start
M_Bit_Stop		
				;corresponding bit is set to 1
				LDR		r6, =1						;r6 holds 1
				LSLS	r6, r6, r5					;1 is left shifted bit value times 
				ADDS	r4, r4, r6					;corresponding bit is set to 1
				LSLS	r3, r3, #2
				STR		r4, [r1, r3]				;value of the line is stored back in the memory
				LSRS	r3, r3, #2
				
				;finding the allocated cell address
				LSLS	r3, #8						;line value is multiplied by 256
				LSLS	r5, #3						;bit value is multiplied by 8
				ADD		r2, r2, r3					;line*256 is added to DATA_MEM
				ADD		r2, r2, r5					;bit*8 is added to DATA_MEM
				MOV		r0, r2						;DATA_MEM + OFFSET is stored in r0
													;allocated address is returned through r0
Malloc_END
				POP		{r1-r7, pc}
				
				;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------

				PUSH	{r1-r7, lr}
				;r0 holds the current address
				LDR		r1, =DATA_MEM				;r1 holds the DATA_MEM
				LDR		r2, =AT_MEM					;r2 holds the AT_MEM
				
				SUBS	r3, r0, r1					;r3 holds the offset value (current address - DATA_MEM start)
				LDR		r4, =0						;r4 holds the line value
FreeLoop		;finding line value		
				LDR		r7, =256					;
				CMP		r3, r7						;checking if offset is greater than 256(32 * 8B) 
				BLE		FreeLoopEND
				SUBS	r3, r3, r7					;offset = offset - 256
				ADDS	r4, r4, #1					;line++
				B		FreeLoop
FreeLoopEND				
				;finding bit value
				LSRS	r5, r3, #3					;remaining offset value is divided by 8 to find corresponding bit
				;r5 holds the bit value
				
				LSLS	r4, r4, #2					;line value is multiplied by 4 to find the offset in AT_MEM
				ADD		r2, r2, r4					;line offset value is added to AT_MEM start address
				LDR		r6, [r2]					;r6 holds the value in the corresponding line in AT_MEM
				LDR		r7, =1						;1 will be used to make corresponding bit 0
				LSLS	r7, r7, r5					;bit value times left shifting 1
				SUBS	r6, r6, r7					;subtracting left shifted value from r6
				STR		r6, [r2]					;storing r6 back to AT_MEM
				
				LDR		r7, =0						;
				STR		r7, [r0]					;clearing data value in the DATA_MEM
				STR		r7, [r0, #4]				;clearing address value in the DATA_MEM
				
				
				POP		{r1-r7, pc}

;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------	

				PUSH	{r1-r7, lr}
				ADDS	r7, #1
				
				MOV		r1, r0						;data is transferred to r1
				
				BL		Malloc						;a memory node is allocated
				CMP		r0, #0
				BNE		Still_allocable
				
				;no allocable area error
				LDR		r0, =1
				B		Insert_END
Still_allocable

				STR		r1, [r0]					;value is stored in the address given
				LDR		r2, =FIRST_ELEMENT			;r2 holds the address of the pointer
				LDR		r3, [r2]					;r3 holds the address of the first element
				CMP		r3, #0						;checking if first element is NULL
				BNE		Head_Not_NULL
				
				;head is NULL(first element insertion)
				STR		r0, [r2]					;first element now points to the newly inserted data
				LDR		r0, =0
				B		Insert_END

Head_Not_NULL	LDR		r4,[r3] 					;first elements value is stored in r4 
				CMP		r4,r1						; comparison
				BLT		Insertion_Sort				;jump to label if current head is smaller
				BEQ		Duplicate					;if newhead is equal to old head jump
				STR 	r3,[r0,#4]					;newhead_next-> oldhead_address
				STR 	r0,[r2]						;new head insertion
				LDR		r0, =0
				B		Insert_END


Insertion_Sort 	LDR 	r4,[r3,#4]					;address of next value is stored in r4
				CMP		r4,#0						;check if NULL
				MOV		r6,r3
				BEQ		Insert_Value
				LDR		r5,[r4]						;value in the address which r4 stores
				MOV		r3,r4						
				CMP		r5,r1
				BLT		Insertion_Sort
				BEQ		Duplicate
				
;r0=address of to be inserted node
;r1=value of the to be inserted node
;r2=address of FIRST_ELEMENT 
;r3=Address of the next node
;r4=Address of the next node
;r5= value of the previous node
;r6=address of the previous node

Insert_Value	STR		r0,[r6,#4]					;store our inserted node's address at previous node's next
				STR		r4,[r0,#4]		
				LDR		r0, =0
				B 		Insert_END
				
				
Duplicate		LDR		r0, =2						;error code 2 is returned through r0
				B		Insert_END
				


Insert_END				
				POP		{r1-r7, pc}

;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------		

				PUSH	{r1-r6, lr}
				
				LDR		r1, =FIRST_ELEMENT			;r1 holds the first element addres
				LDR		r2, [r1]					;r2 holds the value of FIRST_ELEMENT
				CMP		r2, #0						;checking if head is NULL
				
				MOV		r3, r1						;r3 holds the previous	(will be used for unlinking)
				MOV		r4, r2						;r4	holds the current address
				BNE		RemoveNot_Empty				
				LDR		r0, =3						;list is empty, error code is returned through r0
				B		Remove_END		

				
RemoveNot_Empty	
				;checking if we will delete the first node
				LDR		r5, [r2]					;r5 holds the data of the first node
				CMP		r5, r0						;r5 ?= data to be deleted
				BNE		RemoveNotHead
				LDR		r6, [r2, #4]				;r6 holds the next address of the current node
				STR		r6, [r1]					;next address of the current node is stored in the previous nodes next
				LDR		r0 , =0						;no error
				B 		FreeAddress

RemoveNotHead
;r0 holds the data to be deleted				
;r3 holds the current address
;r4 holds the next address
				
RemoveLoop		
				CMP		r4, #0						;break the loop if next address is NULL
				BEQ		RemoveLoopEND				
				LDR		r5, [r4]					;r5 holds the value in the current address
				CMP		r5, r0						;checks if the current value is greater or equal
				BGE		RemoveLoopEND				;break the loop if next value is greater
				MOV		r3, r4						;r3 = r4
				LDR		r4, [r4, #4]				;r4 = r4->next
				B		RemoveLoop
RemoveLoopEND
				LDR		r5, [r4]					;r5 holds the value of the current address
				CMP		r5, r0						;checks if r5 equals to data to be deleted
				BEQ		DeleteValue					;unlink the node if correct
				LDR		r0, =4						;data is not found, return error code through r0
				B		Remove_END

DeleteValue		
				LDR		r6, [r4, #4]				;r6 holds the next address of the current node
				STR		r6, [r3, #4]				;next address of the current node is stored in the previous nodes next
				LDR		r0 , =0						;no error
				B 		FreeAddress					

FreeAddress		
				PUSH	{r0}
				MOV		r0, r4						;parameter of Free Function
				BL		Free						;calling Free Function with the address to be freed
				POP		{r0}
				
Remove_END
				POP		{r1-r6, pc}

;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------	

				PUSH	{r1-r5, lr}
				
				;clearing ARRAY_MEM area
				BL		Clear_Array
				
				LDR		r1, =FIRST_ELEMENT			;r1 holds the first element addres
				LDR		r2, [r1]					;r2 holds the value of FIRST_ELEMENT
				CMP		r2, #0						;checking if head is NULL
				BNE		List_Not_Empty				
				LDR		r0, =5						;list is empty, error code is returned through r0
				B		LL2Array_END				
List_Not_Empty	
				LDR		r0, =0
				LDR		r3, =ARRAY_MEM				;r3 holds the ARRAY_MEM address
				LDR		r4, =0						;r4 holds the array index(memory offset)
				
LL2Array_Loop	
				LDR		r5, [r2]					;r5 holds the data to be written
				STR		r5, [r3, r4]				;data is written to ARRAY_MEM
				LDR		r5, [r2, #4]				;r5 holds the next address
				CMP		r5, #0						;checking if the next address is NULL
				BEQ		LL2Array_END				;finishing the loop is next address is NULL
				ADDS	r4, #4						;index value is incremented
				LDR		r2, [r2, #4]				;x = x->next
				B		LL2Array_Loop
LL2Array_END
				POP		{r1-r5, pc}		

;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------		

				PUSH	{r4, r5, r6, lr}
				
				LDR		r4, =LOG_MEM				;loading LOG_MEM address to r4
				LDR		r5, =INDEX_ERROR_LOG		;loading INDEX_ERROR_LOG address to r5
				LDR		r5, [r5]					;r5 = error_index
				LDR		r6, =12						;
				MULS	r5, r6, r5					;index_value is multiplied by 12 (for memory operations)
				
				STRH	r0, [r4, r5]				;storing index value to memory 2B
				ADDS	r5, r5, #2					;adding 2 to r5 because of 2B
				
				STRB	r1, [r4, r5]				;storing error code value to memory 1B	
				ADDS	r5, r5, #1					;adding 1 to r5 because of 1B		
				
				STRB	r2, [r4, r5]				;storing operation value to memory 1B
				ADDS	r5, r5, #1					;adding 1 to r5 because of 1B		
				
				STR		r3, [r4, r5]				;storing data value to memory 4B
				ADDS	r5, r5, #4					;adding 4 to r5 because of 4B		
				
				BL		GetNow						;calling GetNow function to get Timestamp
				STR		r0, [r4, r5]				;storing Timestamp value to memory
				
				;updating error index
				LDR		r5, =INDEX_ERROR_LOG		;loading INDEX_ERROR_LOG address to r5
				LDR		r6, [r5]					;r6 = error_index
				ADDS	r6, r6, #1					;error_index value is incremented
				STR		r6, [r5]					;storing updated error_index value
				
				
				POP		{r4, r5, r6, pc}

;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------	

				PUSH	{r1, r2, r3, lr}
				
				LDR		r1, =0xE000E018				;loading the current value register address to r1
				LDR		r1, [r1]					;loading current value registers value to r1
				LDR		r2, =TICK_COUNT				;loading the tick count variable address to r2
				LDR		r2, [r2]					;loading tick count value to r2
				LDR		r3, =722					;loading our timer interrupt period value to r3
				MULS	r2, r3, r2					;multiplying tick count with 722us(our period)
				ADDS	r0, r1, r2					;loading the result to r0
				
				POP		{r1, r2, r3, pc}
				
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															

Clear_Array		FUNCTION			

				PUSH	{r0-r3, lr}
				
				LDR		r0, =0					;r0 holds the line value
				LDR		r1, =NUMBER_OF_AT*32	;loading the address of NUMBER_OF_AT to r1
				LDR		r2, =0					;r2 will be used for resetting
				LDR		r3, =ARRAY_MEM			;loading AT_MEM address to r3

Loop_A
				CMP		r0, r1					;if line < NUMBER_OF_AT
				BGE		Loop_A_end				;line is >= NUMBER_OF_AT
				LSLS	r0, r0, #2				;line is multiplied by 4 to be used in memory operations
				STR		r2, [r3, r0]			;corresponding AT bits are set to 0
				LSRS	r0, r0, #2				;line is divided by 4
				
				ADDS	r0, r0, #1				;line++
				B 		Loop_A
Loop_A_end				
				
				POP		{r0-r3, pc}
			
				ENDFUNC


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

