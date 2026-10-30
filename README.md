# Daily Goods

A small Flutter storefront backed by [DummyJSON](https://dummyjson.com).

## Run

```sh
flutter pub get
flutter run
```

The sign-in screen is prefilled with the DummyJSON test account `emilys` / `emilyspass`. The app posts credentials to `/auth/login` and stores the returned access token with `flutter_secure_storage`. A saved session opens the catalog directly; use the sign-out button to clear it.

## Structure and decisions

- `lib/data/` contains the HTTP client, product model, and repository. Keeping API parsing out of widgets makes endpoints and paging behavior easy to change.
- `lib/screens/` contains the login, product catalog, and product detail screens. Local `StatefulWidget` state is enough for this small, linear flow, so there is no additional state-management framework.
- The catalog requests `/products` in pages of 20, loads another page near the bottom, and supports pull-to-refresh. It has explicit loading, error, and empty UI states.
- The API client and repository are injected into the screens, so they can be replaced with fakes if the app grows to need automated UI tests.

The API is public demo data; the token is stored securely on-device, but this app does not implement a production account system.
