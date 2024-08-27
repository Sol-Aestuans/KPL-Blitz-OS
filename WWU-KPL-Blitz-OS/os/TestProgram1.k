code TestProgram1

-----------------------------  TestProgram1  ---------------------------------

  const
    FILENAME = "MyFileName"
    NAME_OF_PROGRAM2 = "TestProgram2"

  var 
    buff: array [10] of char = new array of char { 10 of 'x' }
    arr1: array [10000] of char = new array of char { 10000 of '?' }
    arr2: ptr to array of char
    arr3: array [2048] of char = new array of char { 2048 of '?' }
    
  function main ()
    --
    -- This program is used to make sure parameters can be passed to and from
    -- the kernel during the syscalls.  It is also used to test the "Exec" syscall.
    --
      arr2 = "Is this an arg?"
      print ("\nUser-level program 'TestProgram1' is running...\n")
      TestSyscallParameterPassing ()
      TestSyscallErrors()
      --TestExec ()
      Sys_Shutdown ()
    endFunction

------------------------  TestSyscallParameterPassing  ----------------------------

  function TestSyscallParameterPassing ()
    --
    -- This function calls each of the kernel functions.  Arguments are passed
    -- to the kernel function to make sure that the syscall mechanism is working
    -- properly and that arguments can be passed and results returned.  However,
    -- the arguments that are passed are meaningless values.
    --
    -- This function contains a lot of print statements, designed to make
    -- the output easier to check.
    --
      var i: int
          fileNamePtr: String
	  fp: String
	  sb: statInfo

      print ("\n***** Testing Syscall Parameter Passing *****\n")

      -- The array "arr1" is so big it must contain a page boundary.  Find
      -- a page boundary within arr1 and set p to point 8 bytes before it.
      i = (& arr1[9900]) asInteger
      i = (i & 0xffffe000) - 8

      -- Copy string plus length so that the characters cross the page boundary.
      MemoryCopy (i, FILENAME asInteger, FILENAME arraySize+4)

      -- Set "fileNamePtr" to point the string "MyFileName", which happens to
      -- cross a page boundary.
      fileNamePtr = i asPtrTo array of char

      print ("\n***** About to call Sys_Fork...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Fork invoked!\n\n")

      i = Sys_Fork ()
      if i != 100
        print ("\n*************** ERROR: Bad return value from Sys_Fork\n")
        printIntVar ("  return value", i)
      endIf

      print ("\n***** About to call Sys_Join...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Join invoked!\n")
      print ("*****     processID = 1111\n\n")

      i = Sys_Join (1111) 
      if i != 200
        print ("\n*************** ERROR: Bad return value from Sys_Join\n")
        printIntVar ("  return value", i)
      endIf

      print ("\n***** About to call Sys_Open...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Open invoked!\n")
      print ("*****     filename virtual Addr = ") printHex(fileNamePtr asInteger) nl()
      print ("*****     filename = MyFileName\n")
      print ("*****     flags = 7\n")
      print ("*****     mode = 7\n\n")

      i = Sys_Open (fileNamePtr, O_RDWR|O_CREATE, 7)
      if i != 300
        print ("\n*************** ERROR: Bad return value from Sys_Open\n")
        printIntVar ("  return value", i)
      endIf

      print ("\n***** About to call Sys_Read...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Read invoked!\n")
      print ("*****     fileDesc = 2222\n")
      print ("*****     buffer virtual addr = ") printHex ((&buff[0]) asInteger) nl()
      print ("*****     sizeInBytes = 3333\n\n")

      i = Sys_Read (2222, &buff[0], 3333)
      if i != 400
        print ("\n*************** ERROR: Bad return value from Sys_Read\n")
        printIntVar ("  return value", i)
      endIf

      print ("\n***** About to call Sys_Write...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Write invoked!\n")
      print ("*****     fileDesc = 4444\n")
      print ("*****     virt addr of buffer = 0x") printHex ((&buff[0]) asInteger) nl()
      print ("*****     sizeInBytes = 5555\n\n")

      i = Sys_Write (4444, &buff[0], 5555)
      if i != 500
        print ("\n*************** ERROR: Bad return value from Sys_Write\n")
        printIntVar ("  return value", i)
      endIf

      print ("\n***** About to call Sys_Seek...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Seek invoked!\n")
      print ("*****     fileDesc = 6666\n")
      print ("*****     newCurrentPos = 7777\n\n")

      i = Sys_Seek (6666, 7777)
      if i != 600
        print ("\n*************** ERROR: Bad return value from Sys_Seek\n")
        printIntVar ("  return value", i)
      endIf

      fp = "StatFileName"
      print ("\n***** About to call Sys_Stat...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Stat invoked!\n")
      printHexVar ("*****     filename virtual addr", fp asInteger)
      print ("*****     filename = StatFileName\n")
      print ("*****     statBuf = 0x") printHex ((&sb) asInteger) nl() nl()

      i = Sys_Stat (fp, &sb)

      if i != 700
        print ("\n*************** ERROR: Bad return value from Sys_Stat\n")
        printIntVar ("  return value", i)
      endIf

      fp = "DirName"
      print ("\n***** About to call Sys_Chdir...\n")
      print ("***** Should print:\n")
      print ("*****     Handle_Sys_Chdir invoked!\n")
      print ("*****     filename virtual addr = ") printHex (fp asInteger) nl()
      print ("*****     filename = DirName\n\n")

      i = Sys_Chdir (fp)

      if i != 800
        print ("\n*************** ERROR: Bad return value from Sys_ChDir\n")
        printIntVar ("  return value", i)
      endIf

      print ("\n***** Syscall Test Complete *****\n")

    endFunction

------------------------  TestSyscallParameterPassing  ----------------------------
  function Check(val, required: int,  msg: String)
      if val == required
         print ("Okay.\n")
      else
        print ("*****  ERROR: ")
	print (msg)
        printInt (val)
        print (" should be ")
	printInt (required)
	print (".  *****\n")
      endIf
 
    endFunction

  function TestSyscallErrors()
    var ret: int
        addr: int
	sb: statInfo
      -- Calculate interesting values
      addr = (& addr) asInteger
      addr = addr / 8192
      addr = (addr + 1) * 8192 - 10 

      print ("\n***** Starting Syscall Error Tests *****\n")

      print ("Testing Sys_Open\n")
      ret = Sys_Open (null, 0, 0)
      Check(ret,-1,"Sys_Open return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Open error code ")
      endIf

      print ("Testing Sys_Read\n")
      ret = Sys_Read(0, null, 10)
      Check(ret,-1,"Sys_Read return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Read error code ")
      endIf
      ret = Sys_Read(0, addr asPtrTo char, 20)
      Check(ret,-1,"Sys_Read return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Read error code ")
      endIf
      ret = Sys_Read(0, addr asPtrTo char, -2)
      Check(ret,-1,"Sys_Read return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Value,"Sys_Read error code ")
      endIf
      ret = Sys_Read(0, 10 asPtrTo char, 10)
      Check(ret,-1,"Sys_Read return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Read_Only_Memory,"Sys_Read error code ")
      endIf
      
       print ("Testing Sys_Write\n")
      ret = Sys_Write(0, null, 10)
      Check(ret,-1,"Sys_Write return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Write error code ")
      endIf
      ret = Sys_Write(0, addr asPtrTo char, 20)
      Check(ret,-1,"Sys_Write return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Write error code ")
      endIf
      ret = Sys_Write(0, addr asPtrTo char, -2)
      Check(ret,-1,"Sys_Write return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Value,"Sys_Write error code ")
      endIf
     
      print ("Testing Sys_Stat\n")
      ret = Sys_Stat (null, &sb)
      Check(ret,-1,"Sys_Stat return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Stat error code ")
      endIf
      ret = Sys_Stat ("Testing", addr asPtrTo statInfo)
      Check(ret,-1,"Sys_Stat return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Stat error code ")
      endIf
      ret = Sys_Stat ("Testing", 10 asPtrTo statInfo)
      Check(ret,-1,"Sys_Stat return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Read_Only_Memory,"Sys_Stat error code ")
      endIf

      print ("Testing Sys_Chdir\n")
      ret = Sys_Chdir (null)
      Check(ret,-1,"Sys_Chdir return value ")
      if (ret == -1)
         ret = Sys_GetError()
	 Check(ret,E_Bad_Address,"Sys_Chdir error code ")
      endIf

      print ("\n***** Syscall Error Tests Complete *****\n")
    endFunction
    
-----------------------------  TestExec  ---------------------------------

  function TestExec ()
    --
    -- This function is used to test the "Exec" syscall.  It will execute an
    -- Exec syscall.  If there are no errors, it should not return.  If there
    -- are errors, it will print the error code and the invoke the "Shutdown"
    -- syscall.
    --
      var i: int
          fileNamePtr: String
        ArgList: array [5] of ptr to array of char
	ArgList2: array [2] of ptr to array of char
	ArgList3: array [3] of ptr to array of char
        ArgList = new array [5] of ptr to array of char { "Arg0",
             "This is a string longer than 20 chars",
	     "arg2", "arg3", "arg4 with more" }
	ArgList2 = new array [2] of ptr to array of char { 2 of null}
	ArgList3 = new array [3] of ptr to array of char { 3 of null}

      print ("\n***** Testing Exec Syscall *****\n")

      print ("\n***** About to call Sys_Exec with a non-existant file...\n")
      print ("***** Should print:\n")
      print ("*****     Okay\n\n")
      Sys_Exec ("GarbageFilename", null)
      i = Sys_GetError()
      if i != E_No_Entry
	print ("***************** ERROR: Bad error code, not E_No_Entry\n")
      else
        print ("Okay\n")
      endIf

      print ("\n***** About to call Sys_Exec with an overly long file name...\n")
      print ("***** Should print:\n")
      print ("*****     Okay\n\n")
      -- This name of this file exceeds the maximum length (MAX_STRING_SIZE)
      -- so Exec should fail.
      Sys_Exec ("FileWithVeryLongName012345678901234567890123456789", &ArgList)
      i = Sys_GetError()
      if i != E_Bad_Value
	print ("***************** ERROR: Bad error code, not E_Bad_Value\n")
      else
        print ("Okay\n")
      endIf

      -- Test bad command line arguments
      print ("\n***** About to call Sys_Exec with bad argument pointers...\n")
      print ("***** Should print:\n")
      print ("*****     Okay\n\n")
      ArgList3[0] = arr2
      ArgList3[1] = ((&i) asInteger + 8192) asPtrTo array of char
      ArgList3[2] = null

      Sys_Exec ("TestProgram2", &ArgList3)
      i = Sys_GetError()
      if i != E_Bad_Address
	print ("***************** ERROR: Bad error code, not E_Bad_Address\n")
      else
        print ("Okay\n")
      endIf

      print ("\n***** About to call Sys_Exec with too many argument characters...\n")
      print ("***** Should print:\n")
      print ("*****     Okay\n\n")
      ArgList2[0] = &arr3
      ArgList2[1] = &buff

      Sys_Exec ("TestProgram2", &ArgList2)
      i = Sys_GetError()
      if i != E_No_Space
	print ("***************** ERROR: Bad error code, not E_No_Space\n")
	printIntVar ("  Error code int value: ", i)
      else
        print ("Okay\n")
      endIf

      -- The array "arr1" is so big it must contain a page boundary.  Find
      -- a page boundary within arr1 and set p to point 8 bytes before it.
      i = (& arr1[9900]) asInteger
      i = (i & 0xffffe000) - 8

      -- Copy string plus length so that the characters cross the page boundary.
      MemoryCopy (i, NAME_OF_PROGRAM2 asInteger, NAME_OF_PROGRAM2 arraySize+4)

      -- Set "fileNamePtr" to point the string "TestProgram2", which happens to
      -- cross a page boundary.
      fileNamePtr = i asPtrTo array of char

      print ("\n***** About to perform a successful Exec and jump to TestProgram2...\n")
      print ("***** Should print:\n")
      print ("*****     User-level program 'TestProgram2' is running!\n\n")

      Sys_Exec (fileNamePtr, &ArgList)

      printIntVar ("***************  ERROR IN EXEC; return code", i)

    endFunction

endCode
