#! /opt/local/bin/python
#Fibonacci Programs...

def fib(n):
    a,b = 0,1
    while b<n:
        a,b=b,a+b
        print(a,b,end="  ")
    print("")
fib(10)
