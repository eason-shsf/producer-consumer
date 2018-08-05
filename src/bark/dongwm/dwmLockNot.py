

import time
from threading import Thread, Lock

value = 0


def getlock():
    global value

    new = value + 1
    time.sleep(0.0001)
    value = new


threads = []

for i in range(100):
    t = Thread(target=getlock)
    t.start()
    threads.append(t)

for t in threads:
    t.join()

print(value)
