# DermIQ Build Error Fix

## Objective
Fix all compilation errors, analyzer errors, deprecations, warnings, and overflow issues without changing the DermIQ UI.

## Critical Errors

Fix all:

Invalid constant value

Files:

- cart_screen.dart:52
- checkout_screen.dart:107
- checkout_screen.dart:687
- my_orders_screen.dart:29
- my_orders_screen.dart:54
- order_tracking_screen.dart:40
- shop_screen.dart:276
- shop_screen.dart:283
- shop_screen.dart:732

## Invalid Constant Value Rules

Search the entire project.

Remove const from widgets using runtime values.

Examples:

Invalid:

const Text(product.name)

const ProductCard(product: product)

const Icon(dynamicIcon)

Valid:

Text(product.name)

ProductCard(product: product)

## Deprecation Fixes

Replace:

activeColor

with:

activeThumbColor
activeTrackColor

Replace:

dialogBackgroundColor

with:

DialogThemeData.backgroundColor

Replace deprecated ReorderableList callbacks with current Flutter APIs.

## Overflow Validation

Validate:

- Shop Screen
- Cart Screen
- Checkout Screen
- Orders Screen
- Tracking Screen

Ensure:

- No RenderFlex overflow
- No Bottom Overflow
- No yellow/black striped warnings

## Warning Cleanup

Remove:

- unused imports
- unnecessary imports
- unnecessary this qualifiers
- unnecessary underscores
- unused parameters
- null-aware warnings
- curly brace warnings
- prefer_initializing_formals warnings

## Validation Steps

Run:

flutter clean

flutter pub get

dart fix --apply

flutter analyze

flutter run

## Final Goal

Application must:

- Build successfully
- Compile without errors
- Run without overflows
- Maintain the existing DermIQ UI exactly
