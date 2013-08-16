Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
#Delayed::Worker.max_run_time = 10.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.raise_signal_exceptions = true
#Delayed::Worker.delay_jobs = !Rails.env.test?
