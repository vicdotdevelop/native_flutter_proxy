# Contribution Guide

Feel free to contribute to this project. If you want to contribute, please follow the steps below:

1. Fork the project
2. Commit your changes
3. Create a pull request

Please make sure that your code is well tested.

## Running Tests 🧪

Install lcov:

```sh
brew install lcov
```

Run and open the report using the following command:

```sh
flutter test --coverage --test-randomize-ordering-seed random && genhtml coverage/lcov.info -o coverage/ && open coverage/index.html
```

Everything should be green! 🎉
