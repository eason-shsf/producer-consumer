'''
基于事件的生产者消费者模式的实现
这个代码演示了在stack无限大情况下，不限制生产者的行为，
但是两个消费者不能同时操作的情形
这是一种不标准的实现，因为这个时候存在生产者和某个消费者同时在操作stack的可能性
需要格外注意
目前计划在实现中首先做出基本的一个多线程的生产者消费者模型代码，运行后提出一个竞争的问题、堆栈深度不能无限的问题
然后提出解决这两个问题的方法引入锁、信号量、条件、事件等
在依次引入这四个方式的同时，对这四个类型的竞争解决方案，在其代码示例中分别演示单生产者单消费者、
单生产者多消费者、多生产者单消费者、多生产者多消费者四种情况
当然看情况也可以分开演示
'''

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
