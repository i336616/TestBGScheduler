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
	@IBOutlet weak var clearButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		BackgroundTaskService.shared.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		didUpdateBackgroundService()
	}
	
	@IBAction func didTapClearButton(_ sender: Any) {
		BackgroundTaskService.shared.tasksExecuted = []
		UserDefaults.standard.set(BackgroundTaskService.shared.tasksExecuted, forKey: "tasksExecuted")
		didUpdateBackgroundService()
	}
	
}

extension ViewController: BackgroundTaskServiceDelegate {
	func didUpdateBackgroundService() {
		DispatchQueue.main.async {
			guard let tasks = UserDefaults.standard.value(forKey: "tasksExecuted") as? [String] else { return }
			print("#",#line,#function,tasks)
			self.textView.text = tasks.joined(separator: "\n")
			self.clearButton.isEnabled = !tasks.isEmpty
		}
	}
}
