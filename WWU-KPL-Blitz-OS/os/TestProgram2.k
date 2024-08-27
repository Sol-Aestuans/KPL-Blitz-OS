code TestProgram2

-----------------------------  TestProgram2  ---------------------------------

  function main ()

    var ix: int

      print ("User-level program 'TestProgram2' is running!\n")

      print ("Command line arguments:\n")
      if cmdArgs == null
        print ("   None provided.\n")
      else
        if cmdArgs arraySize == 5 
          for ix = 0 to cmdArgs arraySize - 1
             print ("   arg[") printInt(ix) print("] is ") print (cmdArgs[ix]) nl()
          endFor
	  print ("\n***** Testing Sys_Exec with a null argument list.\n")
	  print ("*****  TestProgram2 should run a second time.\n\n")
	  Sys_Exec ("TestProgram2", null)
          print ("***** ERROR: Could not exec TestProgram2 from TestProgram2\n")
	else
	  print ("***** ERROR: Only successful calls should have no args or 5.\n")
	endIf
      endIf

      print ("\n***** About to call Sys_Shutdown...\n")
      print ("***** Should print:\n")
      print ("*****     \"Syscall 'Shutdown' was invoked by a user thread\"\n\n")

      Sys_Shutdown ()

      print ("\n*************** ERROR: Execution should not continue after Shutdown\n")

    endFunction

endCode
