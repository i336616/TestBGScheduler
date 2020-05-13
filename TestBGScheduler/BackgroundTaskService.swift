//
//  BackgroundTaskService.swift
//  ENA
//
//  Created by Dunne, Liam on 13/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

/*

- Build and run your app
- Background it to schedule the task
- Pause the debugger
- Simulate a receiving an event in console:
    e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.Lmd64.TestBGScheduler.refresh"]
- Unpause the debugger
- Bring the app to the foreground again

UI should be updated with messages from the background tasks

*/


import Foundation
import BackgroundTasks
import UserNotifications

protocol BackgroundTaskServiceDelegate {
	func didUpdateBackgroundService()
}
	
class BackgroundTaskService {

	var delegate: BackgroundTaskServiceDelegate?
	
	static let shared = BackgroundTaskService()
	let refreshBGIdentifier = "com.Lmd64.TestBGScheduler.refresh"
	
	var tasksExecuted = [String]()
	
	func registerLaunchHandlers() {
		cancelAllTaskRequests()

		BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshBGIdentifier, using: DispatchQueue.global()) { task in
			self.handleTask(task: task)
		}

	}

	var taskRequest: BGTaskRequest?
	
    func scheduleAppRefresh() {
		BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: refreshBGIdentifier)

		//let request = appRefreshTaskRequest()
		let request = processingTaskRequest()
		
		print("#",#line,#function,"scheduling ",NSStringFromClass(type(of: request)))
		
		taskRequest = request
		do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
	
	func appRefreshTaskRequest(timeInterval: Int = 10) -> BGTaskRequest {
		let scheduleDate = Calendar.current.date(byAdding: .second, value: timeInterval, to: Date())
		let request = BGAppRefreshTaskRequest(identifier: refreshBGIdentifier)
		request.earliestBeginDate = scheduleDate
		return request
    }

	func processingTaskRequest(timeInterval: Int = 10) -> BGTaskRequest {
		let scheduleDate = Calendar.current.date(byAdding: .second, value: timeInterval, to: Date())
		let request = BGProcessingTaskRequest(identifier: refreshBGIdentifier)
		request.earliestBeginDate = scheduleDate
		request.requiresExternalPower = false
		request.requiresNetworkConnectivity = true
		return request
	}

    func handleTask(task: BGTask) {
        
		scheduleAppRefresh()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operations = [
			operation(message: "\(NSStringFromClass(type(of: task)))-BlockOperation-1-\(Date())"),
			operation(message: "\(NSStringFromClass(type(of: task)))-BlockOperation-2-\(Date())"),
			operation(message: "\(NSStringFromClass(type(of: task)))-BlockOperation-3-\(Date())")
		]

		guard let lastOperation = operations.last else {
			task.setTaskCompleted(success: true)
			return
		}

        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        lastOperation.completionBlock = {
            task.setTaskCompleted(success: !lastOperation.isCancelled)
			self.delegate?.didUpdateBackgroundService()
			queue.cancelAllOperations()
			task.setTaskCompleted(success: true)
        }
        queue.addOperations(operations, waitUntilFinished: true)
    }

	
	func cancelAllTaskRequests() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

	func operation(message: String, seconds: UInt32 = 2) -> BlockOperation {
		return BlockOperation {
			do { sleep(seconds) }
			self.tasksExecuted.append(message)
			self.delegate?.didUpdateBackgroundService()
		}
	}

}

