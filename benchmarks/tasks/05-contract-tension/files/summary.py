from text import truncate


def preview(text):
    return truncate(text, 20) + "..."
