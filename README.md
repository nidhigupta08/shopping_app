# Shopping App

A simple Shopping App built using Flutter and Dart. The application demonstrates product listing, product details, navigation, cart management, quantity updates, item removal, and total price calculation.

## Features

* Display 8 products with images, names, and prices
* View product details
* Add products to the cart
* Increase product quantity
* Decrease product quantity
* Remove products from the cart
* View total cart amount
* Display cart item count on the Product List screen
* Display an empty cart state
* Navigate between Product List, Product Details, and Cart screens

## Tech Stack

* Flutter
* Dart
* Riverpod
* Material 3

## State Management

Riverpod is used for cart state management.

The cart state handles:

* Adding products to the cart
* Increasing product quantity
* Decreasing product quantity
* Removing products from the cart
* Calculating the total cart amount

## Project Structure

```text
lib/
├── data/
│   └── products.dart
├── models/
│   ├── product.dart
│   └── cart_item.dart
├── providers/
│   └── cart_provider.dart
├── screens/
│   ├── product_list_screen.dart
│   ├── product_details_screen.dart
│   └── cart_screen.dart
├── widgets/
│   └── product_card.dart
└── main.dart
```

## Flutter Version

Flutter: `3.41.6`

## Dependencies

* `flutter_riverpod: 3.3.2`

## How to Run

1. Make sure Flutter is installed and configured.
2. Clone or download the project.
3. Open the project in Android Studio or VS Code.
4. Run the following command to install dependencies:

```bash
flutter pub get
```

5. Run the application on a connected Android device or Chrome:

```bash
flutter run
```

## Testing

The application was tested on:

* Physical Android device
* Google Chrome

The project was checked using:

```bash
flutter analyze
```

Result:

```text
No issues found!
```
