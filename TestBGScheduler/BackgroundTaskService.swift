//
//  BackgroundTaskService.swift
//  ENA
//
//  Created by Dunne, Liam on 13/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

/*

Build and run your app
Background it to schedule the task
Bring the app to the foreground again
Hit the pause button in the debugger
Simulate a receiving an event in console:

(llbd) e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.Lmd64.TestBGScheduler.refresh"]

*/


import Foundation
import BackgroundTasks
import UserNotifications

extension Date {
	func roundedDate(byAdding minutes: TimeInterval) -> Date {
		let date = Date().addingTimeInterval(minutes)
		let calendar = Calendar.current
		let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
		let roundedDate = calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: date) ?? date
		return roundedDate
	}
}

protocol BackgroundTaskServiceDelegate {
	func didUpdateBackgroundService()
}
	
class BackgroundTaskService {

	var delegate: BackgroundTaskServiceDelegate?
	
	static let shared = BackgroundTaskService()
	let refreshBGIdentifier = "com.Lmd64.TestBGScheduler.refresh"
	
	var tasksExecuted = [String]()
	
	func registerLaunchHandlers() {
		print("#",#line,#function,"refreshBGIdentifier:",refreshBGIdentifier)

		let didRegisterRefreshBGIdentifier = BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshBGIdentifier, using: nil) { task in
			print("#",#line,#function,"forTaskWithIdentifier: refreshBGIdentifier called")
			guard let task = task as? BGAppRefreshTask else { return }
			self.handleAppRefresh(task: task)
		}

		print("#",#line,#function,"didRegisterRefreshBGIdentifier =",didRegisterRefreshBGIdentifier)
	}

    func scheduleAppRefresh() {
		print("#",#line,#function)

		let scheduleDate = Date().roundedDate(byAdding: 1 * 60)
		print("#",#line,#function,"now          :",Date())
		print("#",#line,#function,"scheduleDate :",scheduleDate)

		let request = BGAppRefreshTaskRequest(identifier: refreshBGIdentifier)
		//let request = BGProcessingTaskRequest(identifier: refreshBGIdentifier)
		//request.requiresExternalPower = true
		//request.requiresNetworkConnectivity = true
        request.earliestBeginDate = scheduleDate
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
		print()
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
		print("#",#line,#function)
        scheduleAppRefresh()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operations = [
			BlockOperation {
				print("#",#line,#function,"BlockOperation-1")
				self.tasksExecuted.append("BlockOperation-1-\(Date())")
			},
			BlockOperation {
				print("#",#line,#function,"BlockOperation-2")
				self.tasksExecuted.append("BlockOperation-2-\(Date())")
			},
			BlockOperation {
				print("#",#line,#function,"BlockOperation-3")
				self.tasksExecuted.append("BlockOperation-3-\(Date())")
			}
		]

		guard let lastOperation = operations.last else { return }

        task.expirationHandler = {
			print("#",#line,#function,"task.expirationHandler")
            queue.cancelAllOperations()
        }
        lastOperation.completionBlock = {
			print("#",#line,#function, "lastOperation.completionBlock")
            task.setTaskCompleted(success: !lastOperation.isCancelled)
			self.delegate?.didUpdateBackgroundService()
        }
        queue.addOperations(operations, waitUntilFinished: false)
    }

	func cancelAllTaskRequests() {
		print("#",#line,#function)
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

}

