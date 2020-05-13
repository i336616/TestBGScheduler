- Build and run
- Background it to schedule the task
- Hit the pause button in the debugger
- Simulate a receiving an event in console:

e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.Lmd64.TestBGScheduler.refresh"]

- Bring app to the foreground again
