import time
import threading


def consumer(cond):
    t = threading.current_thread()
    with cond:
        cond.wait()  # wait()方法创建了一个名为waiter的锁，并且设置锁的状态为locked。这个waiter锁用于线程间的通讯
        # time.sleep(2)
        print('{}: Resource is available to consumer'.format(t.name))


def producer(cond):
    t = threading.current_thread()
    with cond:
        print('{}: Making resource available'.format(t.name))
        # cond.acquire()
        cond.notifyAll()  # 释放waiter锁，唤醒消费者
        # time.sleep(5)
        # cond.release()


condition = threading.Condition()

c1 = threading.Thread(name='c1', target=consumer, args=(condition,))
c2 = threading.Thread(name='c2', target=consumer, args=(condition,))
p = threading.Thread(name='p', target=producer, args=(condition,))

c2.start()
time.sleep(1)
c1.start()
time.sleep(1)
p.start()
