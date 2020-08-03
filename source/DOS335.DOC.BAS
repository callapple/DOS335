 5  HOME 
 10  FOR I = 1 TO 6
 20  READ A$
 30  PRINT A$
 40  PRINT 
 50  IF I = 4 AND  PEEK (33) = 40 THEN  PRINT "press a key": WAIT  - 16384,128: PRINT 
 60  NEXT 
 100  READ A$
 110  PRINT A$
 7000  END 
 10000  DATA     "DOS3.3.5 is copyright 1987 by Arjay Enterprises"
 10020  DATA " This DOS will allow you to read and    write files using 3 1/2in drives on your Apple //GS.  It will not work on other Apple //'s  because it needs the 65816  chip. THIS DISK HAS NO DOS"
 10040  DATA " DOS3.3.5 can also initialize a bootable 3 1/2in disk wi|h the normal command.  It will not initialize a 5 1/4in floppy, but will read and write them."   
 10050  DATA " Device #1 is S5,D1 for the first 400K  and ,D2 for the next 400K.  You continue in this way for as many devices as you have.  The RAM drive is initialized only if it has at least 400K." 
 10070  DATA  " To make a version of FID that will     work properly, you type EXECFID335MAKER and follow instructions."
 10080  DATA "  The boot option for DOS335PATCH will  attempt to boot a DOS3.5 disk in ,S5,D1 and modify the DOS on the fly. This may allow some commercial software to work  but I offer no guarantees."   
 10090  DATA " This program is supposed to be transparant; the less documentation to confuse  things the better."
