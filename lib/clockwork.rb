include Clockwork

every(4.minutes, 'Queueing interval job') { Delayed::Job.enqueue IntervalJob.new }
every(1.day, 'Queueing scheduled job', :at => '14:17') { Delayed::Job.enqueue ScheduledJob.new }
