# How to PYPrime, rev. 1.1

PYPrime 2 is a memory benchmark that scales with latency, the exact scaling end behaviour will vary depending on the architecture used.
In general you should get as high of a clock as possible (with a catch) then tune timings and sub timings.
PYPrime also scales with CPU and Cache clock, this should not be your first priority though.

Due to the nature of many CPU architectures, some cores will be physically closer to the IMC, thus, when setting the affinity to a single core, 
I would suggest choosing the closest one to the memory controller, doing so will result in slightly higher performance (up to 150-200ms); 
don't forget to set the priority to "High" or "Realtime".

Architectures:

Skylake and derivatives:
  	
	-Run the benchmark on Core #2 with the priority set to "High" for the best possible results
		
	-Try to get as high of a memory clock as possible, then tighten the timings
		
	-When tightening the timings, don't stop at the primaries, tweaking the secondaries and tertiaries will result in significantly higher performance
		
	-The benchmark doesn't scale as well below CL12 with this specific architecture, try tightening other timings.
		
	-Once you hit a wall with memory overclock your core and cache
		
		
Rocket Lake S:
 		
	Rocket Lake S was the first intel architecture to introduce "Gears", basically at Gear 1 the controller and the memory run at 1:1, while at Gear 2
	they run at a 1:2 ratio, the former will result in overall better performance in this specific banchmark due to the lower memory latency,
	but you will be stuck at about 4000 MHz on the RAM.
	To get better performance running at Gear 2 you would have to get the ram to much higher speeds
		
	-Run the benchmark on the lowest latency core (I don't have any data yet to tell you which core will perform the best)
		
	-Get the RAM to the maximum possible clock your CPU can handle while kstaying in Gear 1 (this value will be around 3800 and 4000 MHz)
		
	-Tighten the all the timings as far as possible
		
	-Overclock the CPU and cache (higher uncore frequencies may to have more of an effect on RKL-S than on Skylake based architectures)
				
  Zen 2 and 3:
  
  	*Work In Progress
  

If you have any findings of yours don't hesitate to contact me!
