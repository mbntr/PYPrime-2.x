# How to PYPrime, rev. 1.4

PYPrime 2 is a memory benchmark that scales with latency, the exact scaling end behaviour will vary depending on the architecture used.
In general you should get as high of a clock as possible (with a catch) then tune timings and sub timings.
PYPrime also scales with CPU and Cache clock, this should not be your first priority though.

Due to the nature of many CPU architectures, some cores will be physically closer to the IMC, thus, when setting the affinity to a single core, 
I would suggest choosing the closest one to the memory controller, doing so will result in slightly higher performance (up to 150-200ms); 
don't forget to set the priority to "High" or "Realtime".

Performance will be higher when running dual rank memory at 1T, in most cases the differences will be negligible, but this is something to keep in mind
when overclocking competitively

Some µArchitectures will also perform better than others with the same ram configuration, here they are ordered from fastest to slowest

DDR5

	Alder Lake S

DDR4

	Rocket Lake S Gear 1
	Rocket Lake S Gear 2
	Skylake and derivatives
	Zen 3
	Zen 2
	Zen and Zen +
	
DDR3

	*work in progress*

DDR2

	*work in progress*
	
DDR

	*work in progress*
	
	
If you are benching competitively and your system happens to be extremely unstable, add the line XOC=1 to cpuz.ini, to reduce the stress on the system
and prevent it from crashing when opening CPU-Z

Architectures:

Skylake and derivatives:
  	
	- Run the benchmark on Core #1 (which is the second one, core #0 is the first) with the priority set to "High" for the best possible results
	
	- If you are benching competitively disable Hyperthreading, doing so should boost scores while reducing power consumption
		
	- Try to get as high of a memory clock as possible, then tighten the timings
		
	- When tightening the timings, don't stop at the primaries, tweaking the secondaries and tertiaries will result in significantly higher performance
		
	- The benchmark doesn't scale as well below CL12 with this specific architecture, try tightening other timings.
		
	- Once you hit a wall with memory, overclock your core and cache, while nowhere as beneficial as ram oc and timings
	it can improve your score when memory limited
		
		
Rocket Lake S:
 		
	Rocket Lake S was the first intel architecture to introduce "Gears", at Gear 1 the controller and the memory run at 1:1, while at Gear 2
	they run at a 1:2 ratio, the former will result in overall better performance in this specific banchmark due to the lower memory latency,
	you will be stuck at about 4000 MHz on the RAM though.
	
	To get better performance running at Gear 2 you would have to get the ram to far higher speeds
		
	- Run the benchmark on Core #1 (which is the second one, core #0 is the first) with the priority set to "High" for the best possible results
	
	- If you are benching competitively disable Hyperthreading, doing so should boost scores while reducing power consumption
		
	- Get the RAM to the maximum possible clock your CPU can handle while staying in Gear 1 (this value will be around 3800 and 4000 MHz)
		
	- Tighten the all the timings, including secondaries and tertiaries, as far as possible
		
	- Overclock the CPU and cache (higher uncore frequencies may have more of an effect on RKL-S than on Skylake based architectures)
	
  Alder Lake S:
  
  	Alder Lake is the first x86 architecure (if you don't count Lakefield) to use a hybrid core design, it features at the top end 8 P cores and 8 E cores.
	It's also the first consumer architecture to support DDR5 memory, this does mean though that it behaves quite differently from Rocket Lake and it's predecessors.
	
	For best performance:

	- Run the benchmark with affinity set to any of the P cores
	
	- If benching competitively disable the E cores in BIOS
				
  Zen 2 and 3:
  
  	- Run the benchmark with the affinity set to the one of the "starred cores" (you can find which ones exactly using Ryzen Master) with priority set to "High"


If you have any findings of yours don't hesitate to contact me!
