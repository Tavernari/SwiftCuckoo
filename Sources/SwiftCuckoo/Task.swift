import Foundation

import Foundation

/// A model representing a task for time tracking in the SwiftCuckoo application.
///
/// The `Task` structure is designed to encapsulate the details of a task that
/// includes its start time, optional end time, and the duration calculated
/// from these timestamps. This structure aids in managing and reporting
/// the time spent on various tasks, providing valuable insights for users
/// looking to optimize their productivity.
public struct Task: Identifiable {
    /// A unique identifier for this task. Helps to distinguish
    /// between multiple tasks in the tracking management system.
    public var id: ObjectIdentifier
    
    /// The start time of the task. This indicates when the task
    /// began and is essential for calculating the duration.
    public var startTime: Date
    
    /// The end time of the task, which indicates when the task
    /// was completed. This value is optional as tasks may be
    /// ongoing at the time of tracking.
    public var endTime: Date?
    
    /// The duration of the task, calculated as the time interval
    /// between `endTime` and `startTime`. Returns nil if `endTime` is
    /// not set or if `endTime` occurs before `startTime`,
    /// preventing negative duration values for well-defined task timelines.
    public var duration: TimeInterval? {
        guard let endTime, endTime >= startTime else { return nil }
        
        return endTime.timeIntervalSince(startTime)
    }
    
    /// Initializes a new task with a unique identifier, the start time,
    /// and an optional end time, which is helpful in managing tasks within
    /// the time tracking system.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the task. This helps in managing
    ///          and tracking individual tasks within the SwiftCuckoo system.
    ///   - startTime: The task's start time, indicating when the task begins.
    ///   - endTime: The task's end time, representing when the task is completed.
    ///              This parameter is optional and defaults to nil for ongoing tasks.
    package init(id: ObjectIdentifier, startTime: Date, endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}
