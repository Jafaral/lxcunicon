LXCUnicon:
	A Unicon library for managing LXC containers
	Version 0.1

Example:

```unicon
import LXC
procedure main(arg)
    name := arg[1] | "unicon-tainer"
   LXC("./lxcunicon.so")     # initialize the libaray
   c := LXC.Container(name)  # initialize a Unicon container object
   if c.Exist() then
      stop("container ", name, " already exists")

   write("creating a container named ", name, "...")
   c.Create() | stop("can't create container ", name)

   write("booting ", name, "...");
   c.Start() | stop("couldn't do it")
   
   write("loop for 20 seconds report the state every 5 seconds")
   every 1 to 4 do {
      write(c.name, " is ", image(c.State()))
      delay(5000)
     }

   # stop the conainter
   c.Stop()

   # report the container state one more time
   write(c.name, " is ", image(c.State()))

   write("Time for cleanup, destroying ", name)
   c.Destroy() | stop("couldn't destroy ", name)
   
   write("All OK, Goodbye!")
end
```
