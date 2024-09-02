# Crash Resolution

If a sample app crash can't automatically be symbolicated in the Xcode organizer, do the following.

1. Download the artifacts for the crashing build from Xcode Cloud. Locate the `.dSYM` file
2. Right click on the unsymbolicated crash in the crashes list in the Xcode organizer.
3. Show package contents and locate the relevant `.crash` file.
4. Make sure your `DEVELOPER_DIR` environmental variable is set. It should be `export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer/`.
5. Run `/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash whatever.crash whatever.app.dSYM > symbolicated_crash.txt`
