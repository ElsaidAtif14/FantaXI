# iOS Launch Image

This image set supplies the `LaunchImage` referenced by `ios/Runner/Base.lproj/LaunchScreen.storyboard`. iOS displays it centered on the launch screen's white background while the Flutter app starts.

To replace the launch artwork, update all three scale variants and keep the filenames listed in `Contents.json`:

- `LaunchImage.png` (1x)
- `LaunchImage@2x.png` (2x)
- `LaunchImage@3x.png` (3x)

Use artwork with the same aspect ratio across the variants. To change the layout or background color, edit `LaunchScreen.storyboard` in Xcode. Open the iOS workspace with `open ios/Runner.xcworkspace`, then select `Runner/Assets.xcassets` in the Project Navigator to manage the image set.
