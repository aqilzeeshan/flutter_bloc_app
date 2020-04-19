import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'CounterRepo.dart';
/*
Event: To show all possible events
State: To show all possible states
Bloc: How to map those events to states
* */

//////////////////////////////////Events/////////////////////////////

/*
Equatable makes our classes equatable/comparable, which is required for the
mapping logic inside the bloc class
* */

/*
Equatable asks you to override the get props
* */
class CounterScreenEvent extends Equatable {
  @override
  List<Object> get props => null;
}

class IncrementCounterValue extends CounterScreenEvent {}

class DecrementCounterValue extends CounterScreenEvent {}

class GenerateRandomCounterValue extends CounterScreenEvent {}

/////////////////////////////States//////////////////////////////////////
/*
Why, just two states?
Well either the user will see the incremented/decremented counter values on the screen, or they’ll see a loading screen while we’re trying to generate a random number simulating a network call.
The ShowCounterValue state will have a counter value associated with it. Hence, we define a property in that class called counterValue to help you pass the counter value to the UI of the application from Bloc.
* */
class CounterScreenState extends Equatable {
  @override
  List<Object> get props => [];
}

class ShowLoadingCounterScreen extends CounterScreenState {
  ShowLoadingCounterScreen();
}

class ShowCounterValue extends CounterScreenState {
  //An important thing to know about bloc is if nextState == currentState evaluates to true, bloc ignores the state transition.
  //If you don’t extend your state class as Equatable, all of the states that you’ll be calling from yield will be treated as unique.
  //If that fits your requirements, you shouldn’t bother much, but if there’s a chance there will be states repeated one after the other, why waste your performance on rebuilding the same state?
  //Hence, we extend Equatable and override the props method.

  //If you don’t override the props method, your bloc won’t know how to compare the two state classes and will probably treat them the same. Hence, you wouldn’t see the new state being triggered.
  @override
  List<Object> get props => [counterValue];

  final int counterValue;
  ShowCounterValue(this.counterValue);
}

//////////////////////////////////////////Bloc////////////////////////
class CounterScreenBloc extends Bloc<CounterScreenEvent, CounterScreenState> {
  //define property which will be used to maintain state of our counter
  int counterValue = 0;

  //When the bloc loads, the initial state will be set to ShowCounterValue(counterValue)
  @override
  CounterScreenState get initialState => ShowCounterValue(counterValue);

  //If your function returns a future value after performing a certain operation, we mark that function as async. These functions return a value only once, and their execution ends with the return statement.
  //The function marked as async*, on the other hand, returns a stream. This function yields different values and doesn’t just return them back. Their execution still continues, and they can yield as many values as you want.
  //That’s why their output is called a stream.
  @override
  Stream<CounterScreenState> mapEventToState(CounterScreenEvent event) async* {
    //TODO: Map event to state
    if (event is IncrementCounterValue) {
      this.counterValue++;
      yield ShowCounterValue(counterValue);
    }

    if (event is DecrementCounterValue) {
      this.counterValue--;
      yield ShowCounterValue(counterValue);
    }

    if (event is GenerateRandomCounterValue) {
      yield ShowLoadingCounterScreen();

      //Created a repository called CounterRepo
      //which is responsible for getting data
      counterValue = await CounterRepo().getRandomValue();

      //Showing the random number
      yield ShowCounterValue(counterValue);
    }
  }
}
