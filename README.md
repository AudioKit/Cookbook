<img src="images/CookbookMac.png" alt="Cookbook" />

# AudioKit Cookbook for iOS and macOS (via Catalyst)

[![Build Status](https://github.com/AudioKit/Cookbook/workflows/CI/badge.svg)](https://github.com/AudioKit/Cookbook/actions?query=workflow%3ACI)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/AudioKit/AudioKit/blob/v5-main/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit.svg?style=flat)](https://github.com/AudioKit/AudioKit/)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitPro.svg?style=social)](http://twitter.com/AudioKitPro)

## Canonical Examples for Using the AudioKit 5 Swift Package

Most of the examples that were inside of [AudioKit](https://github.com/AudioKit/AudioKit/) are now in this single iOS / macOS Catalyst application.

## Top Level Overview

* `ContentView.swift` contains the menu screen.
* `Recipes/` contain all of the one-screen demos.
* `Resources/`, `Samples`, and `Sounds` contain shared audio and MIDI content.
* `Reusable Components/` contains the code widgets that are shared between recipes.

## Recipes

Each recipe is one file that contains a few related objects:

* `Conductor` sets up all the AudioKit signal processing.
* `Data` is a structure that holds the state of the demo. It is used by both the view and the conductor.
* `View` creates the SwiftUI user interface for the recipe.

## On-going development

Since this is the primary example for AudioKit, it will continue to evolve as AudioKit does. There are plenty of opportunities to help out.
Check out [Github Issues](https://github.com/AudioKit/Cookbook/issues) for some specific requests.

<img src="https://github.com/AudioKit/Cookbook/blob/main/images/Cookbook.png" alt="Cookbook" width="200" align=left />
<img src="https://github.com/AudioKit/Cookbook/blob/main/images/Cookbook2.png" alt="Cookbook" width="200"/>
