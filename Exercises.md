# LF Traffic Light Controller exercises

## Introduction

I these exercises you will build a simple traffic light controller in the Lingua Franca C-target. Through three exercises you will incrementally build the timed
behavior required of a traffic light controller.

To run your controller do:
```sh
lfc src/Main.lf
bin/Main
```

The state of the two lights will be printed to the terminal, to request a 
green light for the pedestrian, hit `Enter` in the terminal window.

Nothing happens? This is because it is your job to implement the controller!

To validate your controller for each exercise we provide a simple test harness,
that simulates pedestrian requests and asserts the correct behavior of the lights.

You can try running the test program from exercise already:

```sh
lfc src/test/TestExercise1.lf
bin TestExercise1
```

It will naturally fail.


## References
Refer to the [LF Handbook](https://www.lf-lang.org/docs/) for documentation on
the LF syntax and target language API. 


## Exercise 0: Hello World!

## Exercise 1: Initialize correctly
Open the [Main.lf](src/Main.lf) and inspect the generated diagrams. Here you will
see the structure of the program. There are three reactors 
a CarTrafficLight and PedestrianTrafficLight, both imported from [TrafficLight.lf](src/lib/TrafficLight.lf), these files
should not be modified and emulate the actuators at an actual traffic light. Your job is to finish the last reactor, [Controller.lf](src/Controller.lf). This reactor has an input port where pedestrian requests will arrive, and two output port, one to each of the lights setting their color.

The first exercise is to properly initialize the system. The initial state of the system should be that the car light is in `LIGHT_GREEN` and the pedestrian light is in `LIGHT_RED`.

### References
- [Startup and Shutdown](https://www.lf-lang.org/docs/writing-reactors/time-and-timers#startup-and-shutdown)
- [Input and Output Declarations](https://www.lf-lang.org/docs/writing-reactors/inputs-and-outputs#input-and-output-declarations)

## Exercise 2: Handle requests


## Exercise 3: Throttling!


## Exercise 4 (optional): Federated execution
