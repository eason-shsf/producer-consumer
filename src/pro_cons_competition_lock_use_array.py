'''

'''

# coding=utf-8
import time
import threading
from random import randint


TIMEOUT = 200


def consumer():
    t = threading.current_thread()
    global arr
    while 1:
        lock.acquire()
        if (len(arr) > 0):
            curValue = arr.pop()
            print('{} popped from list by {}, read position: {}'.format(
                curValue, t.name, len(arr)))
            time.sleep(2)
        lock.release()
        time.sleep(0.5)


def producer():
    t = threading.current_thread()
    global arr
    while 1:
        lock.acquire()
        if (len(arr) < 10):
            integer = randint(10, 100)
            arr.append(integer)
            print('{} appended to list by {}, writePosition: {}'.format(
                integer, t.name, len(arr) - 1))
            time.sleep(1)
        lock.release()
        time.sleep(0.5)


stackLength = 10
arr = []
threads = []
lock = threading.Lock()

t = threading.Thread(name="consumer1", target=consumer)
t.daemon = True
t.start()
threads.append(t)


t2 = threading.Thread(name="consumer2", target=consumer)
t2.daemon = True
t2.start()
threads.append(t2)

p = threading.Thread(name='pro', target=producer)
p.daemon = True
p.start()
threads.append(p)

time.sleep(100)
