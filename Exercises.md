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
bin/TestExercise1
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

The first exercise is to properly initialize the system. The initial state of the system should be that the car light is in `LIGHT_GREEN` and the pedestrian light is in `LIGHT_RED`, both of which are provided compile definition that expand to integers. To write to output ports within a reaction, use `lf_set(OutputPortName, Value);`. 

Run your implementation, press Play or run from the terminal with:

```sh
lfc src/Main.lc
bin/Main
```

Verify your implementation with opening [TestExercise1.lf](src/test/TestExercise1.lf) and pressing play, or from the command line:

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

Several future events can be scheduled on an action. E.g. this code creates an additional event in 200 msec with
the value 38.

```
reaction(startup) -> a {=
  lf_schedule_int(a, MSEC(100), 42);
  lf_schedule_int(a, MSEC(200), 32);
=}
```

Compile and run [TestExercise2](src/test/TestExercise2.lf) to verify your solution.

### References
- [Actions](https://www.lf-lang.org/docs/reference/target-language-details#actions)

## Exercise 3: Throttling!

If you are practicing Test-Driven Development and came up with the minimal implementation passing the test,
you will now have a more functional, but still not really working, traffic light controller. You also need to
handle the scenario when a pedestrian repeatedly presses the button.

If the pedestrian presses the button at time `t`, then the controller shall discard any requests arriving up until and including `t + 13 sec`, which is the time the controller turns the CarLight back to green again.  

The easiest way to achieve this is to introduce a state variable to the Controller reactor. Reactions within a reactor
can all read and write to the state variable of the reactor. In the following program a state variable `cnt` is defined and modified from a 
reaction. State variables can be accessed from the C code through the `self->` pointer.

```
reactor R {
  state cnt: int = 0
  reaction(startup) {=
    self->cnt++;
   =}
```


Compile and run [TestExercise3](src/test/TestExercise3.lf) to verify your solution.


## Exercise 4: Modal reactors

A reactor that has several modes of operation can be captured with Modal Reactors. In this exercise,
You will rewrite the Controller reactor using modes instead of the state variable and possibly several actions.

Mode changes are done from reactions, and reactions declare mode switches as effects. The following code switches from `m_first` to `m_second`
in the startup reaction.

```
reactor Modal {
  initial mode m_first {
    reaction(startup) -> m_second {=
      lf_set_mode(m_second);
    =}
  }
  mode Second {
  ...
  }
}
```

When in a particular mode, only reactions defined within that mode (or defined outside all modes) are executed. As such you can
decide how to (or not to) react to inputs by creating different reactions triggered by this input in different reactions.
```
reactor Modal {
 input in: int 
 output out: int
 initial mode m_multiply_by_2 {
    reaction(in) -> out {=
      lf_set(out, in->value * 2);
    =}
  }
  mode m_divide_by_3 {
    reaction(in) -> out {=
      lf_set(out, in->value / 3);
    =}
  }
}
```

A mode can either be changed with a reset transition or a history transition. For simplicity, we will only consider reset transitions.
With a reset transition, the mode is reset each time it is transitioned, timers will be reset and start triggering relative to the current logical time.
A special trigger called `reset` will also be present the very first logical instance of the mode. Finally, state variables within the mode that is marked for automatic reset will be set back to their initial value.

```
reactor Modal {
 input in: int 
 output out: int
 initial mode m_accepting {
    reaction(reset) {=
      // Invoked when we transition back to m_accepting
    =}

    reaction(in) -> reset(m_processing) {=
      lf_set_mode(m_processing);
    =}
  }
  mode m_processing {
    reset state cnt: int = 0
    logical action a
    reaction(reset) -> a {=
      // self->cnt is always 0 here.
      lf_schedule(a, MSEC(300));
  
    =}
    reaction(a) -> reset(m_accepting) {=
      lf_set_mode(m_accepting);
      self->cnt = 24;
    =}
  }
}
```
This program performs reset transitions between the two modes. The `reaction(reset)` reactions are triggered on mode switches. The state variable `cnt` 
is marked for automatic reset and the runtime sets it back to 0 upon a mode transition to `m_processing`.

Run the program:
Compile and run [TestExercise4](src/test/TestExercise4.lf) to verify your solution.

### References
- [Modal Reactors](https://www.lf-lang.org/docs/writing-reactors/modal-models)
