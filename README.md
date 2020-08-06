# Minesweeper
The typical minesweeper game. Built with Rails, VueJS and a few cups of coffee.

### Design & ideas
The game is controlled by 2 main services: `GameService::Game` and `GameService::Cell` in the backend.
These two are responsible for checking the game logic, so it's difficult to cheat, and multiple clients can be added.

Note: performance is not the best, maybe the persistence layer of the game is too much for what's needed. I'm sure it can be improved.

Element.io was added for frontend components.

### Install
- clone the repo
- `bundle install`
- `rails db:create db:migrate`

### Run
- `rails s`
- open http://localhost:3000

### Demo
A working demo is found here: https://pakerimus-minesweeper.herokuapp.com/

### Test
Test suite is in rspec
```
rspec spec/
```

### API documentation
Can be found in here: https://app.swaggerhub.com/apis/pakerimus/minesweeper/1.0.0
