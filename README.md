# The Sharkey NRL Footy Tipping Competition

## About the Competition

The Sharkey NRL Footy tipping competition was first created in 2006 and ran for 7 years until I accidentally lost the server on which it was hosted. I created the competition as a way of learning Ruby on Rails and to provide my family with a way to show their footy knowledge and stay in touch.

The original system ended up hosting over 100 competitions and I hope to revive many of those when this system is live.

I am setting up this new system with similar goals to the first:

1. Revive the footy tipping competition for the Sharkey Family and anyone else who would like to use it
2. Learn a new language and framework: Elixir/Phoenix

When the system is live I will post the production URL here. You can use the live system to host your own NRL Footy Tipping competition, or you can clone this project and host your own system.

## How to run the code

### Install RethinkDB 

Instructions available [on the RethinkDB website](https://www.rethinkdb.com/docs/install/)

Start RethinkDB on port 8081:

`rethinkdb --http-port 8081`

### Install Elixir

Instructions available [on the Elixir website](http://elixir-lang.org/install.html)

### Run the App

  1. Install dependencies with `mix deps.get`
  2. Start RethinkDB in another terminal with `rethinkdb --http-port 8081`
  3. Start the app with `mix phoenix.server`
  4. Visit [`http://localhost:4000/`](http://localhost:4000) to start using the app
