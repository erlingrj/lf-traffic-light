# LF Traffic Light Controller exercises

## Introduction

In these exercises, you will build a simple traffic light controller in the Lingua Franca C-target. Through three exercises, you will incrementally build the timed
behavior required of a traffic light controller.

To run your controller, either press the play button in VSCode while [Main.lf](src/Main.lf) is open, or do:
```sh
lfc src/Main.lf
bin/Main
```

The state of the two lights will be printed to the terminal to request a 
green light for the pedestrian, hit `Enter` in the terminal window.

Nothing happens? This is because it is your job to implement the controller!

To validate your controller for each exercise, we provide a simple test harness,
that simulates pedestrian requests and asserts the correct behavior of the lights.

You can try running the test program from the exercise already, either by pressing
the play button or running:

```sh
lfc src/test/TestExercise1.lf
bin TestExercise1
```

It will naturally fail.


## References
Refer to the [LF Handbook](https://www.lf-lang.org/docs/) for documentation on
the LF syntax and target language API. 


## Exercise 0: Hello, World!
Before starting, make sure that your setup works by compiling and running 

## Exercise 1: Initialize correctly
Open the [Main.lf](src/Main.lf) and inspect the generated diagrams. Here, you will
see the structure of the program. There are three reactors 
a CarTrafficLight and PedestrianTrafficLight, both imported from [TrafficLight.lf](src/lib/TrafficLight.lf), these files
should not be modified and emulate the actuators at an actual traffic light. Your job is to finish the last reactor, [Controller.lf](src/Controller.lf). This reactor has an input port where pedestrian requests will arrive and two output ports, one to each of the lights setting their color.

The first exercise is to properly initialize the system. The initial state of the system should be that the car light is in `LIGHT_GREEN` and the pedestrian light is in `LIGHT_RED`.

Run your implementation:

```sh
lfc src/Main.lc
bin/Main
```

Verify your implementation with:

```sh
lfc src/test/TestExercise1.lf
bin/TestExercise1
```

### References
- [Reactions](https://www.lf-lang.org/docs/writing-reactors/reactions)
- [Startup and Shutdown](https://www.lf-lang.org/docs/writing-reactors/time-and-timers#startup-and-shutdown)
- [Input and Output Declarations](https://www.lf-lang.org/docs/writing-reactors/inputs-and-outputs#input-and-output-declarations)

## Exercise 2: Handle requests
This traffic light is not very functional since it does not handle pedestrian requests yet. Your next task is to
handle events on the `ped_request` input port. Upon receiving such an event at `time=t`, the controller should do the following.
- At `t + 1sec`, switch the CarTrafficLight to red
- At `t + 2sec`, switch the PedestrianTrafficLight to green.
- At `t + 12sec`, switch the PedestrianTrafficLight back to red.
- At `t + 13sec`, switch the CarTrafficLight back to green again.

In Lingua Franca, the standard way of achieving a timed behavior is to schedule future events using
a `logical action`. A logical action can have a type, deciding the payload of the event. Consider the
following code:

```
logical action a: int
reaction(startup) -> a {=
  lf_schedule_int(a, MSEC(100), 42);
=}
reaction(a) {=
  lf_print("Got  %d", a->value);
=}
```

Here, an event with value 42 is scheduled 100 msec into the future. A reaction can declare
an action as a trigger and access its value. The program above will print "Got 42" 100 msec after startup.


Run the program:
```sh
lfc src/Main.lc
bin/Main
```

Verify your implementation with:

```sh
lfc src/test/TestExercise2.lf
bin/TestExercise2
```

### References
- [Actions](https://www.lf-lang.org/docs/reference/target-language-details#actions)

## Exercise 3: Throttling!

If you are practicing Test-Driven Development and came up with the minimal implementation passing the test,
you will now have a more functional, but still not really working, traffic light controller. You also need to
handle the scenario when a pedestrian repeatedly presses the button.

If the pedestrian presses the button at time `t`, then the controller shall discard any requests arriving up until and including `t + 13 sec`, which is the time the controller turns the CarLight back to green again.  

The easiest way to achieve this is to introduce a state variable to the Controller reactor. Reactions within a reactor
can all read and write to the state variable of the reactor.

Run the program:
```sh
lfc src/Main.lc
bin/Main
```

Verify your implementation with:
```sh
lfc src/test/TestExercise3.lf
bin/TestExercise3
```

## Exercise 4: Modal reactors

A reactor that has several modes of operation can be captured with Modal Reactors. In this exercise,
You will rewrite the Controller reactor using modes instead of the state variable and possibly several actions.

Run the program:
```sh
lfc src/Main.lc
bin/Main
```

Verify your implementation with:
```sh
lfc src/test/TestExercise3.lf
bin/TestExercise3
```

### References
- [Modal Reactors](https://www.lf-lang.org/docs/writing-reactors/modal-models)
