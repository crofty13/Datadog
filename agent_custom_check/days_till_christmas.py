from datadog_checks.base import AgentCheck
import os
import datetime

class DaysTillChristmasCheck(AgentCheck):
	def check(self, instance):
		path = instance.get('path', '/') # variable you can put in the conf.d/daystillchristmas file if you want.
		try:
			today = datetime.date.today()
			christmas = datetime.date(today.year, 12, 25)

			# If today is after Christmas, calculate for next year
			if today > christmas:
				christmas = datetime.date(today.year + 1, 12, 25)

			days_until_christmas = (christmas - today).days
			self.gauge('days_until_christmas', days_until_christmas)
		except Exception as e:
			self.log.error(f"Christmas is cancelled : {e}")
