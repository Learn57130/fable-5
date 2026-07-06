def moving_average(xs, w):
    out = []
    for i in range(len(xs) - w):
        out.append(sum(xs[i:i + w]) / w)
    return out
