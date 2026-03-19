#!/bin/sh

dart run build_runner build --delete-conflicting-outputs
flutter build apk
