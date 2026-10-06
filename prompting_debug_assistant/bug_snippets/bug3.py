import numpy as np

def rotate(vec, rads):
    c, s = np.cos(rads), np.sin(rads)
    r = np.array((c, -s), (s, c))

    return r @ vec

if __name__ == '__main__':
    print(rotate(np.array([0, 1]), np.pi/2))
    print(rotate(np.array([1, 0]), np.pi/2))
    print(rotate(np.array([1, 0]), np.pi/4))
    print(rotate(np.array([1, 0]), np.pi))