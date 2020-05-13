//
//  ViewController.swift
//  TestBGScheduler
//
//  Created by Dunne, Liam on 13/05/2020.
//  Copyright © 2020 Lmd64. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var textView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		BackgroundTaskService.shared.delegate = self
		
		
	}
}

extension ViewController: BackgroundTaskServiceDelegate {
	func didUpdateBackgroundService() {
		DispatchQueue.main.async {
			let tasks = BackgroundTaskService.shared.tasksExecuted
			print("#",#line,#function,tasks)
			self.textView.text = tasks.joined(separator: "\n")
		}
	}
}
