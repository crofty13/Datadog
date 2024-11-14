#!/opt/homebrew/bin/python3


import time
import ddtrace

def function_one():
	print(f"This is my first function")
	time.sleep(2)


def function_two():
	print(f"This is my second function")
	time.sleep(2)


def function_three():
	print(f"This is my third function")
	time.sleep(2)

while(1):
	function_one()
	function_two()
	function_three()


