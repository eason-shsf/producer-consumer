# coding=utf-8
import time
import threading
from random import randint


TIMEOUT = 200


def consumer(event, l):
    t = threading.current_thread()
    while 1:
        event_is_set = event.wait(TIMEOUT)
        if event_is_set:
            try:
                integer = l.pop()
                time.sleep(3)
                print('{} popped from list by {}'.format(integer, t.name))
                event.clear()  # 重置事件状态
            except IndexError:  # 为了让刚启动时容错
                pass


def producer(event, l):
    t = threading.current_thread()
    while 1:
        integer = randint(10, 100)
        l.append(integer)
        print('{} appended to list by {}'.format(integer, t.name))
        event.set()	 # 设置事件
        time.sleep(1)


event = threading.Event()
l = []

threads = []

for name in ('consumer1', 'consumer2'):
    t = threading.Thread(name=name, target=consumer, args=(event, l))
    t.daemon = True
    t.start()
    threads.append(t)

p = threading.Thread(name='pro', target=producer, args=(event, l))
p.daemon = True
p.start()
threads.append(p)

# for t in threads:
#     t.join()
print('endings...')
time.sleep(10)
