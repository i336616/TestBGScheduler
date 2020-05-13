# TestBGScheduler

This app illustrates how to perform `BGAppRefreshTasks` & `BGProcessingTasks` when the application is backgrounded. using the `BGTaskScheduler` from the `BackgroundTasks.framework`.

- `BGAppRefreshTasks` get a maximum of 30 seconds execution time
- `BGProcessingTasks` get longer periods

To simulate long-lived background tasks, we're using the sleep function from UNIX for our test background operations:

	do { sleep(seconds) }

These operations will be completed on the thread they were executed on (which will be a background thread, so don't do any UI updates here)

The app is set to trigger the background task 60 seconds after backgrounding by default. The background task triggers 3 test operations, each test operation is set to 2 seconds long.

The background task is set to repeat every 60 seconds. On re-entering the app, the text view should be populated with multiple repeated descriptions of the test operations.

**A few caveats:**
- The background scheduler can only be run on a hardware device, it will not work on the simulator
- When debugging an app from Xcode, the app will not go into the background, even if the user taps the home button/task switcher
- To test background scheduling while in tethered debug mode, the tester will need follow the steps below to simulate launching the app in the background with the specified identifier 

Outstanding Issue:
- We can trigger the background tasks manually when tehtered to Xcode. However, we haven't been able to get the background tasks to work when the app is run standalone.  

## Usage

- Build and run
- Background it to schedule the task
- Pause debugger
- Simulate a receiving an event in console:

	`e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.Lmd64.TestBGScheduler.refresh"]`

- Unpause debugger
- Bring app to foreground again

UI should be updated with messages from the background tasks, and the text view should be populated with the three operation descriptions, eg:

	BGProcessingTask-BlockOperation-1-2020-05-13 17:54:47 +0000
	BGProcessingTask-BlockOperation-2-2020-05-13 17:54:47 +0000
	BGProcessingTask-BlockOperation-3-2020-05-13 17:54:47 +0000

