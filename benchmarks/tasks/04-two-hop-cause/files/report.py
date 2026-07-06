from metrics import avg_by


def summary(rows):
    return {
        "price": avg_by(rows, "price"),
        "priority": avg_by(rows, "priority"),
    }
