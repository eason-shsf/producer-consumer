'''
由于上述锁时间太长，严重降低了效率，为此，可以减少锁的范围到if循环体内，
但是此时只锁定了两步，没有锁定判断这一步就会造成不一致的问题。
引入信号量控制位能否写入，让锁控制后两部，这样锁的时间变短了，
判断有信号量单独控制，不会出错（是否会出错再仔细思考和论证）。
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
        readSemaphore.acquire()
        # lock.acquire()
        curValue = arr.pop()
        print('{} popped from list by {}, read position: {}'.format(
            curValue, t.name, len(arr)))
        # lock.release()
        time.sleep(2)
        writeSemaphore.release()
        time.sleep(0.01)


def producer():
    t = threading.current_thread()
    global arr
    while 1:
        writeSemaphore.acquire()
        integer = randint(10, 100)
        # lock.acquire()
        arr.append(integer)
        print('{} appended to list by {}, writePosition: {}'.format(
            integer, t.name, len(arr)-1))
        # lock.release()
        time.sleep(1)
        readSemaphore.release()
        time.sleep(0.01)


stackLength = 10
arr = []
threads = []
lock = threading.Lock()
readSemaphore = threading.Semaphore(0)
writeSemaphore = threading.Semaphore(10)

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
