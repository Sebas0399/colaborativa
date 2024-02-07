model Agents

import "./main.gaml"

global {
	
	float distanceInGraph (point origin, point destination) {
		return (origin distance_to destination using topology(road));	
	}
	
	int numCars;
	
	bool autonomousBikesInUse;
	bool carsInUse;
	
	int numGasStations;
	int gasStationCapacity;

	list<autonomousBike> availableAutonomousBikes(package delivery) {
		if traditionalScenario{
			autonomousBikesInUse <- false;
		} else {
			autonomousBikesInUse <- true;
		}
		return autonomousBike where (each.availableForRideAB());
	}
	
	list<car> availableCars(package delivery) {
		if traditionalScenario{
			carsInUse <- true;
		} else {
			carsInUse <- false;
		}
		return car where (each.availableForRideC());
	}
		
	float autonomousBike_distance <- 0.0;
	
	float car_distance <- 0.0;
		
	int requestBike(package delivery) {
		
		///////FIRST CHECK if the delivery is possible at all///////

		path p_total <- path_between(roadNetwork,delivery.initial_closestPoint,delivery.final_closestPoint);
		float max_s_trip <-0.0;
		
		list<geometry> segments_s <- p_total.segments;
			loop line over: segments_s {
				ask road(p_total agent_from_geometry line) { 
					if snow_level > max_s_trip {
						max_s_trip <- snow_level;
					}
				}
				
		}
				
		 if max_s_trip > 15{
		 	write('Impossible trip!');
		 	return 0;
		 }
		 
		//////////////
    	
		int lengthlist <- 0;
		float tripDistance;
    	
		list<autonomousBike> availableAB <- availableAutonomousBikes(delivery);		
	
		if empty(availableAB) {
				
				return 0;
				
		} else if !empty(availableAB) and delivery != nil{		
				
				list<autonomousBike> b_15 <- availableAB closest_to(delivery.initial_closestPoint,15) using topology(road);
				
				list<autonomousBike> b_15_v1; 
				
				int i <-0;
				loop b over: b_15{
					 if bikeClose(delivery,b){
					 	add b to: b_15_v1;
					 }
					 i <- i+1;
				}
				
				list<autonomousBike> b_15_v2; 
				int j <-0;
				loop b over: b_15_v1{

					 tripDistance <- distanceInGraph(b.location,delivery.initial_closestPoint) + distanceInGraph(delivery.initial_closestPoint,delivery.final_closestPoint);
					 if tripDistance < b.batteryLife{
					 	add b to: b_15_v2;
					 }
					 j <- j+1;
				}
				
				list<autonomousBike> b_15_v3; 	
				int k <- 0;
				loop b over: b_15_v2{
					
					path p <- path_between(roadNetwork,b.location, delivery.initial_closestPoint);
					float max_s <-0.0;
					
					list<geometry> segments <- p.segments;
						loop line over: segments {
							ask road(p agent_from_geometry line) { 
								if snow_level > max_s {
									max_s <- snow_level;
								}
							}
							
					}
							
					 if max_s < 15{
					 	add b to: b_15_v3;
					 }
					 k <- k+1;
				}
				
				
				autonomousBike b_final <- b_15_v3 closest_to(delivery.initial_closestPoint) using topology(road);
				
				if b_final = nil {
					write('No vehicles meet all conditions');
					return 0;
					
				}else{
					b_final.delivery <- delivery;
					
					ask b_final {			
						do pickUp(delivery);
					}
					ask delivery {
						do deliver_ab(b_final);
					}
					return 1;
					
				}				

		}else{
			return 0;
		}
	
}
				
	int requestCar(package delivery){
		
		
		///////FIRST CHECK if the delivery is possible at all///////

		path p_total <- path_between(roadNetwork,delivery.initial_closestPoint,delivery.final_closestPoint);
		float max_s_trip <-0.0;
		
		list<geometry> segments_s <- p_total.segments;
			loop line over: segments_s {
				ask road(p_total agent_from_geometry line) { 
					if snow_level > max_s_trip {
						max_s_trip <- snow_level;
					}
				}
				
		}
				
		 if max_s_trip > 5{
		 	write('Impossible trip!');
		 	return 0;
		 }
		 
		//////////////
		
		int lengthlist <- 0;
		float tripDistance;
		
		list<car> availableC <- availableCars (delivery); 
		
		if empty(availableC) {
				
				return 0;
				
		} else if !empty(availableC) and delivery != nil{		
				
				list<car> c_15 <- availableC closest_to(delivery.initial_closestPoint,15) using topology(road);
				
				list<car> c_15_v1;
				int i <-0;
				
				loop c over: c_15{
					 if carClose(delivery,c){
					 	add c to: c_15_v1;
					 }
					 i <- i+1;
				}
				
				int j <-0;
				list<car> c_15_v2;
				
				loop c over: c_15_v1{

					 tripDistance <- distanceInGraph(c.location,delivery.initial_closestPoint) + distanceInGraph(delivery.initial_closestPoint,delivery.final_closestPoint);
					 if tripDistance < c.fuel{
					 	add c to: c_15_v2;
					 }
					 j <- j+1;
				}
				
				list<car> c_15_v3;
				int k <- 0;
				loop c over: c_15_v2{
					
					path p <- path_between(roadNetwork,c.location, delivery.initial_closestPoint);
					float max_s <-0.0;
					
					list<geometry> segments <- p.segments;
						loop line over: segments {
							ask road(p agent_from_geometry line) { 
								if snow_level > max_s {
									max_s <- snow_level;
								}
							}
							
					}
							
					 if max_s < 5{
					 	add c to: c_15_v3;
					 }
					 k <- k+1;
				}
				
				
				car c_final <- c_15_v3 closest_to(delivery.initial_closestPoint) using topology(road);
				
				if c_final = nil {
					
					return 0;
					write('No vehicles meet all conditions');
					
				}else{
					c_final.delivery <- delivery;
					
					ask c_final {			
						do pickUpPackage(delivery);
					}
					ask delivery {
						do deliver_c(c_final);
					}
					return 2;
					
				}				

		}else{
			return 0;
		}
		

}


    
    
    bool bikeClose(package pack, autonomousBike b){
		float d <- distanceInGraph(b.location,pack.location);
		if d < maxDistancePackage_AutonomousBike { 
			return true;
		}else{
			return false ;
		}
			
	}
	
	 bool carClose(package pack, car c){
		float d <- distanceInGraph(c.location,pack.location);
		if d < maxDistancePackage_Car { 
			return true;
		}else{
			return false ;
		}
			
	}
}


	
species road {
	
	//The snow level
	float snow_level <-0.0001; 
	
	// probability for a agent to choose this road
	float proba_use <- snow_level/maxSnow;
	
	//TODO: review color map
	int colorValue <- int(255*(snow_level*0.1)) update: int(255*(snow_level*0.1));
	rgb color <- rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0)  update: rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0) ;
	
	
	aspect base {
		draw shape color: color;
	}
	
	//It's snowing!
	reflex snow when: every(10#minute){
		snow_level <- snow_level + snowrate/6;
		
		//write('SNOW: '+ snow_level);
	}
	
}

species building {
    aspect type {
		draw shape color: color_map_2[type]-75 ;
	}
	string type; 
}

species chargingStation{
	
	list<autonomousBike> autonomousBikesToCharge;
	
	rgb color <- #deeppink;
	
	float lat;
	float lon;
	int capacity;
	
	aspect base{
		draw hexagon(25,25) color:color border:#black;
	}
	
	reflex chargeBikes {
		ask capacity first autonomousBikesToCharge {
			batteryLife <- batteryLife + step*V2IChargingRate;
		}
	}
}


species snowPlowTruck skills: [moving,advanced_driving]{
	
	rgb color <- #orange;
	road currentRoad; 
	
	aspect base{
		draw square(40) color:color border:#black;
	}
	
	reflex move {
			// move randomly on the network, using proba_use_road to define the probability to choose a road.
			do wander on: roadNetwork proba_edges: proba_use_road speed: 20/3.6 #m/#s;	
	}
	
	reflex plow{
		
		//Plow the snow
		currentRoad <- road closest_to self;
		currentRoad.snow_level <- 0.0;
	}

}
species restaurant{
	
	rgb color <- #transparent;
	
	float lat;
	float lon;
	point rest;
	
	aspect base{
		draw circle(10) color:color;
	}
}

species gasstation{
	
	rgb color <- #hotpink;
	
	list<car> carsToRefill;
	float lat;
	float lon;
	int capacity;
	
	aspect base{
		draw circle(30) color:color border:#black;
	}
	reflex refillCars {
		ask gasStationCapacity first carsToRefill {
			fuel <- fuel + step*refillingRate;
		}
	}	
}


species package control: fsm skills: [moving] {

	rgb color;
	
    map<string, rgb> color_map <- [
    	
    	"generated":: #transparent,
    	
    	"firstmile":: #lightsteelblue,
    	
    	"requestingDeliveryMode"::#red,
    	
		"awaiting_autonomousBike":: #red,
		"awaiting_car":: #red,
		
		"delivering_autonomousBike":: #cyan,
		"delivering_car"::#cyan,
		
		"lastmile"::#lightsteelblue,
		
		"retry":: #red,
		
		"delivered":: #transparent
	];
	
	packageLogger logger;
    packageLogger_trip tripLogger;
    
	date start_hour;
	float start_lat; 
	float start_lon;
	float target_lat; 
	float target_lon;
	int day;
	
	point start_point;
	point target_point;
	int start_day;
	int start_h;
	int start_min;
	int mode; // 1 <- Autonomous Bike || 2 <- Car || 0 <- None
	
	autonomousBike autonomousBikeToDeliver;
	car carToDeliver;
	
	point final_destination; 
    point target; 
    point initial_closestPoint;
    point final_closestPoint;
    point closestPoint;
    float waitTime;
    float tripdistance;
    int choice;
        
	aspect base {
    	color <- color_map[state];
    	draw square(15) color: color border: #black;
    }
    
	action deliver_ab(autonomousBike ab){
		autonomousBikeToDeliver <- ab;
	}
	
	action deliver_c(car c){
		carToDeliver <- c;
	}
		
	//bool timeToTravel { return ((current_date.hour = start_h and current_date.minute >= start_min) or (current_date.hour > start_h)) and !(self overlaps target_point); }
	bool timeToTravel { return ((current_date.day= start_day and current_date.hour = start_h and current_date.minute >= start_min) or (current_date.day= start_day  and current_date.hour > start_h)) and !(self overlaps target_point); }
	
	int register <- 1;
	
	state generated initial: true {
    	
    	enter {    		
    		if register = 1 and (packageEventLog or packageTripLog) {ask logger { do logEnterState;}}
    		target <- nil;
    	}
    	transition to: requestingDeliveryMode when: timeToTravel() {
    		final_destination <- target_point;
    	}
    	exit {
			if register = 1 and (packageEventLog) {ask logger { do logExitState; }}
		}
    }
    
    state requestingDeliveryMode {
    	
    	enter {
    		target <- self.initial_closestPoint;
    		if register = 1 and (packageEventLog or packageTripLog) {ask logger { do logEnterState; }}  
    		
    		
    		if traditionalScenario{
    			choice <- host.requestCar(self);
    		}else{
    			choice <- host.requestBike(self);
    		}  		
    		
    		if choice = 0 {
    			register <- 0;
    		} else {
    			register <- 1;
    		}
    	}
    	transition to: firstmile when: (choice != 0){}
    	transition to: unserved when: choice =0 {}
    	//transition to: retry when: choice = 0 {target <- nil;}
    	exit {
    		//if register = 1 and packageEventLog {ask logger { do logExitState; }}
    		if packageEventLog {ask logger { do logExitState; }}
		}
    }
    
    state unserved { //TODO: review if trips are saved
	    enter{
	    	if packageEventLog or packageTripLog {ask logger{ do logEnterState;}}
	    }
    	do die;
    }
    
    /*state retry {
    	transition to: requestingDeliveryMode when: timeToTravel() {target <- nil;}
    }*/

	
	state firstmile {
		enter{
			if packageEventLog or packageTripLog {ask logger{ do logEnterState;}}
		}
		transition to: awaiting_autonomousBike when: choice = 1 and location = target{mode <- 1;}
		transition to: awaiting_car when: choice = 2 and location = target{mode <- 2;}
		exit {
			if packageEventLog {ask logger{do logExitState;}}
		}
		do goto target: target on: roadNetwork;
	}
	
	state awaiting_autonomousBike{
		enter {
			if packageEventLog or packageTripLog {ask logger { do logEnterState( "awaiting " + string(myself.autonomousBikeToDeliver) ); }}
		}
		transition to: delivering_autonomousBike when: autonomousBikeToDeliver.state = "in_use_packages" {target <- nil;}
		exit {
			if packageEventLog {ask logger { do logExitState; }}
		}
	}
	
	state awaiting_car {
		enter {
			if packageEventLog or packageTripLog {ask logger { do logEnterState( "awaiting " + string(myself.carToDeliver) ); }}
		}
		transition to: delivering_car when: carToDeliver.state = "in_use_packages" {target <- nil;}
		exit {
			if packageEventLog {ask logger { do logExitState; }}
		}
	}
	
	state delivering_autonomousBike {
		enter {
			if packageEventLog or packageTripLog {ask logger { do logEnterState( "delivering " + string(myself.autonomousBikeToDeliver) ); }}
		}
		transition to: lastmile when: autonomousBikeToDeliver.state != "in_use_packages" {
			target <- final_destination;
		}
		exit {
			if packageEventLog {ask logger { do logExitState; }}
			autonomousBikeToDeliver<- nil;
		}
		location <- autonomousBikeToDeliver.location; 
	}
	
	state delivering_car {
		enter {
			if packageEventLog or packageTripLog {ask logger { do logEnterState( "delivering " + string(myself.carToDeliver) ); }}
		}
		transition to: lastmile when: carToDeliver.state != "in_use_packages" {
			target <- final_destination;
		}
		exit {
			if packageEventLog {ask logger { do logExitState; }}
			carToDeliver<- nil;
		}
		location <- carToDeliver.location;
	}
	
	state lastmile {
		enter{
			if packageEventLog or packageTripLog {ask logger{ do logEnterState;}}
		}
		transition to: delivered when: location = target{}
		exit {
			if packageEventLog {ask logger{do logExitState;}}
		}
		do goto target: target on: roadNetwork;
	}
	
	state delivered {
		enter{
			tripdistance <- (self.start_point distance_to self.initial_closestPoint) + host.distanceInGraph(self.initial_closestPoint,self.final_closestPoint) + (self.final_closestPoint distance_to target_point);
			if packageEventLog or packageTripLog {ask logger{ do logEnterState;}}
		}
		do die;
	}
}

species autonomousBike control: fsm skills: [moving] {
	
	//----------------Display-----------------
	rgb color;
	
	map<string, rgb> color_map <- [
		"wandering"::#violet,
		
		"low_battery":: #red,
		"getting_charge":: #red,

		
		"picking_up_packages"::#lightsteelblue,
		"in_use_packages"::#cyan
	];
	
	aspect realistic {
		color <- color_map[state];
		draw triangle(35) color:color border:color rotate: heading + 90 ;
	} 

	autonomousBikeLogger_roadsTraveled travelLogger;
	autonomousBikeLogger_chargeEvents chargeLogger;
	autonomousBikeLogger_event eventLogger;
	    
	/* ========================================== PUBLIC FUNCTIONS ========================================= */
	
	package delivery;
	
	list<string> rideStates <- ["wandering"]; 
	bool lowPass <- false;

	bool availableForRideAB {
		return (state in rideStates) and self.state="wandering" and !setLowBattery() and delivery = nil and autonomousBikesInUse=true;
	}
	
	action pickUp(package pack) { 
		if pack !=nil {
			delivery <- pack;
		}
	}
	
	/* ========================================== PRIVATE FUNCTIONS ========================================= */
	//---------------BATTERY-----------------
	
	bool setLowBattery { 
		if batteryLife < minSafeBatteryAutonomousBike { return true; } 
		else {
			return false;
		}
	} 
	
	float energyCost(float distance) {
		return distance;
	}
	action reduceBattery(float distance) {
		batteryLife <- batteryLife - energyCost(distance); 
	}
	//----------------MOVEMENT-----------------
	point target;
	point origin_closestPoint;
		
	float batteryLife min: 0.0 max: maxBatteryLifeAutonomousBike; 
	float distancePerCycle;
	
	path travelledPath; 
	path Path;
	
	
	bool canMove {
		return ((target != nil and target != location)) and batteryLife > 0; //TODO: ADAPT FOR WANDERING!
	}
		
	path moveTowardTarget {
		if (state="in_use_packages"){return goto(on:roadNetwork, target:target, return_path: true, speed:RidingSpeedAutonomousBike);}
		return goto(on:roadNetwork, target:target, return_path: true, speed:PickUpSpeedAutonomousBike);
	}
	
	reflex move when: canMove() {
		
		travelledPath <- moveTowardTarget();
		
		float distanceTraveled <- host.distanceInGraph(travelledPath.source,travelledPath.target);
		
		do reduceBattery(distanceTraveled);
		
		//Snow cleaning by bikes 
		list<geometry> segments <- travelledPath.segments;
		loop line over: segments {
			ask road(travelledPath agent_from_geometry line) { 
				snow_level <- 0.0;
			}
		}
	}
				
	/* ========================================== STATE MACHINE ========================================= */
	state wandering initial: true {
		enter {
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}
			target <- nil;
		}
		transition to: picking_up_packages when: delivery != nil{}
		transition to: low_battery when: setLowBattery() {}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
		}
	}
	
	state low_battery {
		enter{
			target <- (chargingStation closest_to(self) using topology(road)).location; 
			point target_closestPoint <- (road closest_to(target) using topology(road)).location;
			autonomousBike_distance <- host.distanceInGraph(target_closestPoint,self.location);
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState(myself.state); }
				ask travelLogger { do logRoads(autonomousBike_distance);}
			}
		}
		transition to: getting_charge when: self.location = target {}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
		}
	}
	
	
	state getting_charge {
		enter {
			if stationChargeLogs{
				ask eventLogger { do logEnterState("Charging at " + (chargingStation closest_to myself)); }
				ask travelLogger { do logRoads(0.0);}
			}		
			target <- nil;
			ask chargingStation closest_to(self) {
				autonomousBikesToCharge <- autonomousBikesToCharge + myself;
			}
		}
		transition to: wandering when: batteryLife >= maxBatteryLifeAutonomousBike {}
		exit {
			if stationChargeLogs{ask eventLogger { do logExitState("Charged at " + (chargingStation closest_to myself)); }}
			ask chargingStation closest_to(self) {
				autonomousBikesToCharge <- autonomousBikesToCharge - myself;
			}
		}
	}

	state picking_up_packages {
			enter {
				target <- delivery.initial_closestPoint;
				autonomousBike_distance <- host.distanceInGraph(target,self.location);
				if autonomousBikeEventLog {
					ask eventLogger { do logEnterState("Picking up " + myself.delivery); }
					ask travelLogger { do logRoads(autonomousBike_distance);}
				}
			}
			transition to: in_use_packages when: (location = target and delivery.location = target) {}
			exit{
				if autonomousBikeEventLog {ask eventLogger { do logExitState("Picked up " + myself.delivery); }}
			}
	}
	
	state in_use_packages {
		enter {
			target <- delivery.final_closestPoint;  
			autonomousBike_distance <- host.distanceInGraph(target,self.location);
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState("In Use " + myself.delivery); }
				ask travelLogger { do logRoads(autonomousBike_distance);}
			}
		}
		transition to: wandering when: location=target {
			delivery <- nil;
		}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState("Used" + myself.delivery); }}
		}
	}
}

species car control: fsm skills: [moving] {
	
	//----------------Display-----------------
	rgb color;
	
	map<string, rgb> color_map <- [
		"wandering"::#violet,
		
		"low_fuel"::#red,
		"getting_fuel"::#pink,
		
		"picking_up_packages"::#lightsteelblue,
		"in_use_packages"::#lime
	];
	
	aspect realistic {
		color <- color_map[state];
		draw triangle(35) color:color border:color rotate: heading + 90 ;
	} 

	carLogger_roadsTraveled travelLogger;
	carLogger_fuelEvents fuelLogger;
	carLogger_event eventLogger;
	    
	/* ========================================== PUBLIC FUNCTIONS ========================================= */
	// these are how other agents interact with this one. Not used by self

	package delivery;
	
	list<string> rideStates <- ["wandering"]; //This defines in which state the cars have to be to be available for a ride
	bool lowPass <- false;

	bool availableForRideC {
		return (state in rideStates) and self.state="wandering" and !setLowFuel() and delivery=nil and carsInUse=true;
	}
	
	action pickUpPackage(package pack){
		delivery <- pack;
	}
	
	/* ========================================== PRIVATE FUNCTIONS ========================================= */	
	//----------------BATTERY-----------------
	
	bool setLowFuel { //Determines when to move into the low_fuel state
		if fuel < minSafeFuelCar { return true; } 
		else {
			return false;
		}
	}

	float energyCost(float distance) {
		return distance;
	}
	action reduceFuel(float distance) {
		fuel <- fuel - energyCost(distance); 
	}
	//----------------MOVEMENT-----------------
	point target;
	
	
	float fuel min: 0.0 max: maxFuelCar; //Number of meters we can travel on current fuel
	float distancePerCycle;
	
	path travelledPath; //preallocation. Only used within the moveTowardTarget reflex
	
	bool canMove {
		return ((target != nil and target != location)) and fuel > 0;
	}
		
	path moveTowardTarget {
		if (state="in_use_packages"){return goto(on:roadNetwork, target:target, return_path: true, speed:RidingSpeedCar);}
		return goto(on:roadNetwork, target:target, return_path: true, speed:RidingSpeedCar);
	}
	
	reflex move when: canMove() {
		
		travelledPath <- moveTowardTarget();
		
		float distanceTraveled <- host.distanceInGraph(travelledPath.source,travelledPath.target);
						
		do reduceFuel(distanceTraveled);
	}
				
	/* ========================================== STATE MACHINE ========================================= */
	state wandering initial: true {
		enter {
			if carEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}
			target <- nil;
		}
		transition to: picking_up_packages when: delivery != nil{}
		transition to: low_fuel when: setLowFuel() {}

		exit {
			if carEventLog {ask eventLogger { do logExitState; }}
		}
	}
	
	state low_fuel {
		enter{
			target <- (gasstation closest_to(self) using topology(road)).location;
			point target_closestPoint <- (road closest_to(target) using topology(road)).location;
			car_distance <- host.distanceInGraph(target_closestPoint,self.location);
			if carEventLog {
				ask eventLogger { do logEnterState(myself.state); }
				ask travelLogger { do logRoads(car_distance);}
			}
		}
		transition to: getting_fuel when: self.location = target {}
		exit {
			if carEventLog {ask eventLogger { do logExitState; }}
		}
	}
	

	state getting_fuel {
		enter {
			if gasstationFuelLogs{
				ask eventLogger { do logEnterState("Refilling at " + (gasstation closest_to myself)); }
				ask travelLogger { do logRoads(0.0);}
			}		
			target <- nil;
			ask gasstation closest_to(self) {
				carsToRefill <- carsToRefill + myself;
			}
		}
		transition to: wandering when: fuel >= maxFuelCar {}
		exit {
			if gasstationFuelLogs{ask eventLogger { do logExitState("Refilled at " + (gasstation closest_to myself)); }}
			ask gasstation closest_to(self) {
				carsToRefill <- carsToRefill - myself;
			}
		}
	}
	
	state picking_up_packages {
		enter {
			target <- delivery.initial_closestPoint; 
			car_distance <- host.distanceInGraph(target,self.location);
			if carEventLog {
				ask eventLogger { do logEnterState("Picking up " + myself.delivery); }
				ask travelLogger { do logRoads(car_distance);}
			}
		}
		transition to: in_use_packages when: (location = target and delivery.location = target) {}
		exit{
			if carEventLog {ask eventLogger { do logExitState("Picked up " + myself.delivery); }}
		}
	}
	
	state in_use_packages {
		enter {
			target <- delivery.final_closestPoint; 
			car_distance <- host.distanceInGraph(target,self.location);
			
			if carEventLog {
				ask eventLogger { do logEnterState("In Use " + myself.delivery); }
				ask travelLogger { do logRoads(car_distance);}
			}
		}
		transition to: wandering when: location=target {
			delivery <- nil;
		}
		exit {
			if carEventLog {ask eventLogger { do logExitState("Used " + myself.delivery); }}
		}
	}
}