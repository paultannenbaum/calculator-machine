# Calculator Machine

A phoenix liveview calculator app, using GenStateMachine to control state/transitions.

Demo: [calculator-machine.baumerdesigns.com](https://calculator-machine.baumerdesigns.com/)

Credits:
- [GenStateMachine](https://github.com/ericentin/gen_state_machine): An elixir behaviour module for implementing a state machine using OTP 19.
- Calculator styles copied from Michele Bertoli's [React Caclulator](https://codesandbox.io/s/n5vvn4jrpm)
- State machine logic for a calculator was inspired by Ian Horrocks [calculator implementation](https://www.amazon.co.uk/Constructing-User-Interface-Statecharts-Horrocks/dp/0201342782) 

## Installing Locally
* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.setup`
* Install Node.js dependencies with `npm install --prefix assets`
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

