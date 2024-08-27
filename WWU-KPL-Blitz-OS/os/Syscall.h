-- -*-Fundamental-*-

header Syscall


  enum SYSCALL_EXIT = 1,
       SYSCALL_GETERROR,
       SYSCALL_SHUTDOWN,
       SYSCALL_YIELD,
       SYSCALL_GETPID,
       SYSCALL_GETPPID,
       SYSCALL_FORK,
       SYSCALL_JOIN,
       SYSCALL_EXEC,

       -- File System System calls
       SYSCALL_OPEN,
       SYSCALL_READ,
       SYSCALL_WRITE,
       SYSCALL_SEEK,
       SYSCALL_CLOSE,
       SYSCALL_STAT,
       SYSCALL_CHMODE,
       SYSCALL_LINK,
       SYSCALL_UNLINK,
       SYSCALL_MKDIR,
       SYSCALL_RMDIR,
       SYSCALL_CHDIR,
       SYSCALL_OPENDIR,
       SYSCALL_READDIR,
       SYSCALL_GETDISKINFO,

       SYSCALL_PIPE,
       SYSCALL_DUP


  -- Errors
  enum  E_No_Error = 0,
        E_No_Child,
        E_No_Entry,
	E_No_Space,
	E_No_Resource,
	E_Not_A_Directory,
	E_Bad_Address,
	E_Read_Only_Memory,
	E_Bad_FD,
	E_Bad_Value,
	E_Permissions,
	E_Exists,
	E_User_Process,
	E_No_Reader,
	E_Not_Empty,
	E_Not_Imp
  
  type

     statInfo = record
		  inodeNum: int
		  nlinks: int
		  mode: int
		  fsize: int
		  balloc: int
                endRecord

      dirEntry = record
      	           inodeNum: int
		   name: array [255] of char
                 endRecord

      diskInfo = record
                   diskSize: int
		   totalInodes: int
		   freeInodes: int
		   totalDblocks: int
		   freeDblocks: int
		 endRecord

  const

     -- Flags for the open system call
     O_READ      = 1
     O_WRITE     = 2
     O_RDWR      = 3
     O_CREATE    = 4
     O_MAYCREATE = 8

     -- Modes
     TYPE_FILE     = 16   -- 0x10
     TYPE_DIR      = 32   -- 0x20
     TYPE_TERMINAL = 64   -- 0x40

     MODE_READ  = 4
     MODE_WRITE = 2
     MODE_EXE   = 1

  functions
      entSize (numChars: int) returns int

endHeader
