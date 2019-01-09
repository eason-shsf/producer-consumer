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


def consumer():
    t = threading.current_thread()
    global arr
    global readPos
    while 1:
        time.sleep(2)
        curValue = arr[readPos]
        print('{} popped from list by {}, read position: {}'.format(
            curValue, t.name, readPos))
        readPos += 1


def producer():
    t = threading.current_thread()
    global arr
    global writePos
    while 1:
        time.sleep(1)
        integer = randint(10, 100)
        arr[writePos] = integer
        print('{} appended to list by {}, writePosition: {}'.format(
            integer, t.name, writePos))
        writePos += 1


stackLength = 10
arr = [0]*stackLength
threads = []
readPos = 0
writePos = 0

t = threading.Thread(name="consumer", target=consumer)
t.daemon = True
t.start()
threads.append(t)

p = threading.Thread(name='pro', target=producer)
p.daemon = True
p.start()
threads.append(p)

time.sleep(100)
