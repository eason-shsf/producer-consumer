

import time
from threading import Thread, Lock

value = 0
lock = Lock()


def getlock():
    global value
    lock.acquire()
    new = value + 1
    # for i in range(10000000):
    #     bc = 3*4
    time.sleep(2)
    value = new
    lock.release()


threads = []

for i in range(100):
    t = Thread(target=getlock)
    t.start()
    threads.append(t)

for t in threads:
    t.join()

print(value)
