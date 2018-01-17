# 'Reactive' Architecture Example
This app is nothing more than an example of how to architect a mobile application to best use
[Reactive](https://github.com/ReactiveX/RxSwift) style programming. This is very close to
a MVVM (Model View ViewModel) application. This is a port from
the original [MVVMReactive](https://github.com/HIFILEO/ReactiveArchitecture)

Reactive architecture breaks an application's interactions into single stream events. Instead of creating impure
side effects on a stream, reactive architecture focuses on slamming asynchronous events into synchronous state events that update
the UI. Reactive state event updates is very similar to REDUX.

Reactive architecture is built on MVVM. MVVM breaks down an application into more testable components keeping your internal
business objects and data separate from the external UI or external data.

The app simply loads a list of "Now Playing" movies based on [The Movie Database API](https://developers.themoviedb.org/3/movies/get-now-playing).

The requirements for the app:
1. As a user, show a list of "Now Playing" movies. Poster, Title, Release Date, & Rating.
2. As a user, any rating at eight or above should be stared.
3. As a user, I only want to see ratings rounded to the nearest whole digit.
4. As a user, while scrolling, keep loading "Now Playing" movies until you hit the last page.

### Demo
<img align="center" src="Doc/demo_single_scroll.gif" alt="Demo of the app."/>

### Rainy Day Scenario (Failure + Restore - Filter)
<img align="center" src="doc/error_restore.gif" alt="Rainy Day Scenario"/>

The application architecture is as followed:

![Alt text](/doc/mvvm_reactive_redux_architecture.png?raw=true "App MVVM Architecture")

Note - the application packages are TYPE defined for ease of learning.

## Usage

Apache License 2.0. Free to use & distribute.

### Documentation

Please review all documentation in **docs/**. The following summaries describe their purpose:

| Name                                                                                          | Summary                                                     |
| :--------------------------------------------------------------------------------------------:|:------------------------------------------------------------|
| [AUTHORS.md](https://github.com/HIFILEO/ReactiveArchitectureSwift/blob/master/Doc/AUTHORS.md)                | History of past and present contributors                    |
| [BUILDS.md](https://github.com/HIFILEO/ReactiveArchitectureSwift/blob/master/Doc/BUILDS.md)                  | Description of official builds                              |
| [DEPENDENCIES.md](https://github.com/HIFILEO/ReactiveArchitectureSwift/blob/master/Doc/DEPENDENCIES.md)      | How to generate a list of all major third party dependencies|
| [STYLE.md](https://github.com/HIFILEO/ReactiveArchitectureSwift/blob/master/Doc/STYLE.md)                    | Description of Code Style and Static Analysis tools         |

### Build Types and Flavors

Only the original build types are release / debug. Use Debug since this
not an app for the google play store. There are no flavors.

### Tests

This project supports the following type of tests:

Unit Tests


### Standards

There are style standards in this app as examples of how to maintain clean code.

#### Checkstyle

None


#### Run All

N/A

## Resources

1. [Medium - Reactive Redux Simply Managing State](https://medium.com/@zeyad.gasser/reactive-redux-simply-managing-state-with-rxjava-8d6b25849068)
2. [Github - Use Cases](https://github.com/Zeyad-37/UseCases)
3. [Medium - Don't Break the Chain](http://blog.danlew.net/2015/03/02/dont-break-the-chain/)
4. [Medium - State propagation in Android with RxJava Subjects](https://proandroiddev.com/state-propagation-in-android-with-rxjava-subjects-81db49a0dd8e)
5. [Youtube - Managing State with RxJava by Jake Wharton](https://www.youtube.com/watch?v=0IKHxjkgop4&t=1828s&list=PL6LUvCSPzQMbfOQkSLAINzmXQPDdxWv3P&index=6)
6. [Thoughts on Clean Architecture](https://android.jlelse.eu/thoughts-on-clean-architecture-b8449d9d02df)
